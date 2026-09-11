# frozen_string_literal: true

require "sketchup.rb"
require_relative "material_library"
require_relative "oauth_connection"
require_relative "takeoff"
require_relative "material_appearance"
require_relative "concrete_slab_tool"
require_relative "local_api"
require_relative "cloud_connection"

module Basegrid
  module Main
    module_function

    def start
      return if @started

      menu = UI.menu("Extensions").add_submenu("Basegrid")
      menu.add_item("Account and Connection") { CloudDrawing.status }
      cloud_menu = menu.add_submenu("Cloud Drawing")
      cloud_menu.add_item("Connect") { CloudDrawing.connect }
      cloud_menu.add_item("Disconnect") { CloudDrawing.stop }
      cloud_menu.add_item("Status") { CloudDrawing.status }
      materials_menu = menu.add_submenu("Materials")
      materials_menu.add_item("Open Connection Page") { open_material_connections }
      materials_menu.add_item("Connect") { connect_materials }
      materials_menu.add_item("Connect with Token") { connect_materials_with_token }
      materials_menu.add_item("Sync") { sync_materials }
      materials_menu.add_item("Disconnect") { disconnect_materials }
      menu.add_separator
      menu.add_item("Create Concrete Slab from Face") { concrete_slab_tool.run }
      @takeoff_command = takeoff_command
      menu.add_item(@takeoff_command)
      @appearance_command = appearance_command
      menu.add_item(@appearance_command)
      menu.add_separator
      menu.add_item("Set Default Slab Tag Folder") { tag_folder_settings }
      create_toolbar
      api_menu = menu.add_submenu("MCP API")
      api_menu.add_item("Start") { LocalAPI.start }
      api_menu.add_item("Stop") { LocalAPI.stop }
      api_menu.add_item("Permissions") { LocalAPI.configure_permissions }
      UI.start_timer(1.0, false) { LocalAPI.start }
      restored = false
      UI.start_timer(2.0, false) do
        next if restored
        restored = true
        CloudDrawing.restore
      end
      @started = true
    end

    def sync_materials
      token = material_sync_token
      return connect_materials if token.empty?

      result = sync_with_token(token)
      message = result[:changed] ? "Basegrid library updated." : "Basegrid library is already current."
      message += "\n\n#{result[:materials]} materials are cached."
      message += "\n#{result[:takeoff_groups]} takeoff groups are cached."
      unless result[:warnings].empty?
        message += "\n\nTexture warnings:\n- #{result[:warnings].join("\n- ")}"
      end
      UI.messagebox(message)
    rescue StandardError => e
      UI.messagebox("Materials could not be synced. The last valid cache was kept.\n\n#{e.message}\n\nUse Materials > Connect to sign in again.")
    end

    def open_material_connections
      UI.openURL(MaterialLibrary::CONNECTION_URL)
    end

    def connect_materials(&connected)
      CloudDrawing.sign_in(&connected)
    end

    def connect_materials_with_token
      values = UI.inputbox(["Paste connection token"], [""], "Connect Materials")
      return unless values

      token = values.first.to_s.strip
      if token.empty?
        UI.messagebox("Paste the token created on the Materials Connection web page.")
        return
      end

      result = sync_with_token(token)
      Sketchup.write_default("Basegrid", "materials_sync_token", token)
      UI.messagebox("Materials are connected. #{result[:materials]} materials were synced.")
    rescue StandardError => e
      UI.messagebox("Materials could not be connected. The token was not saved.\n\n#{e.message}")
    end

    def disconnect_materials
      if !oauth_connection.connected? && legacy_material_sync_token.empty?
        UI.messagebox("Materials are already disconnected.")
        return
      end

      answer = UI.messagebox(
        "Disconnect this SketchUp installation from the Materials web app? Existing cached materials will remain available.",
        MB_YESNO
      )
      return unless answer == IDYES

      Sketchup.write_default("Basegrid", "materials_sync_token", "")
      CloudDrawing.stop
      oauth_connection.disconnect
      UI.messagebox("Materials are disconnected. Cached materials remain available offline.")
    end

    def tag_folder_settings
      current = Sketchup.read_default("Basegrid", "slab_concrete_folder", ConcreteSlabTool::DEFAULT_FOLDER_PATH).to_s
      values = UI.inputbox(["Folder path (use / between folders)"], [current], "Default Slab Tag Folder")
      return unless values

      Sketchup.write_default("Basegrid", "slab_concrete_folder", values[0].to_s.strip)
      UI.messagebox("The folder preference will be used when Slab | Concrete is first created in a model.")
    end

    def show_takeoff
      records = Takeoff.records(Sketchup.active_model)
      rows = Takeoff.summary_rows(records)
      grouped_rows = Takeoff.grouped_rows(records)
      if rows.empty?
        UI.messagebox("No concrete slab takeoff records were found in this model.")
        return
      end

      @takeoff_dialog ||= create_takeoff_dialog
      @takeoff_dialog.set_html(takeoff_html(records, rows, grouped_rows))
      @takeoff_dialog.show
    end

    def takeoff_command
      command = UI::Command.new("Concrete Takeoff") { show_takeoff }
      command.tooltip = "Concrete Takeoff"
      command.status_bar_text = "Review and export concrete quantities in the model."
      command.menu_text = "Concrete Takeoff"
      command
    end

    def create_takeoff_dialog
      dialog = UI::HtmlDialog.new(
        dialog_title: "Concrete Takeoff",
        preferences_key: "basegrid_concrete_takeoff",
        scrollable: true,
        resizable: true,
        width: 680,
        height: 470,
        style: UI::HtmlDialog::STYLE_DIALOG
      )
      dialog.add_action_callback("refresh") { |_context| show_takeoff }
      dialog.add_action_callback("exportCsv") { |_context| export_takeoff_csv }
      dialog
    end

    def takeoff_html(records, rows, grouped_rows)
      payload = JSON.generate(
        "object_count" => records.length,
        "material_count" => rows.length,
        "total_m3" => rows.select { |row| row["unit"] == "m3" }.sum { |row| row["quantity"] },
        "rows" => rows,
        "group_count" => grouped_rows.map { |row| row["group_id"] }.uniq.length,
        "grouped_rows" => grouped_rows
      ).gsub("<", "\\u003c")
      <<~HTML
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            :root { color-scheme: light dark; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; }
            body { margin: 0; color: #202124; background: #f4f5f6; }
            header { padding: 22px 24px 18px; color: white; background: #263238; }
            h1 { margin: 0 0 5px; font-size: 21px; font-weight: 650; }
            header p { margin: 0; color: #cfd8dc; font-size: 13px; }
            main { padding: 18px 24px 24px; }
            .metrics { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 16px; }
            .metric { padding: 13px 14px; border: 1px solid #d8dcdf; border-radius: 6px; background: white; }
            .metric strong { display: block; font-size: 20px; }
            .metric span { color: #687078; font-size: 12px; }
            .table-wrap { overflow: hidden; border: 1px solid #d8dcdf; border-radius: 6px; background: white; }
            table { width: 100%; border-collapse: collapse; }
            th, td { padding: 11px 13px; border-bottom: 1px solid #e5e7e9; text-align: left; }
            th { color: #687078; background: #fafafa; font-size: 11px; text-transform: uppercase; letter-spacing: .04em; }
            td { font-size: 13px; }
            tr:last-child td { border-bottom: 0; }
            .number { text-align: right; font-variant-numeric: tabular-nums; }
            footer { display: flex; justify-content: flex-end; gap: 8px; margin-top: 16px; }
            button { padding: 8px 14px; border: 1px solid #aeb4b8; border-radius: 4px; background: white; color: #202124; cursor: pointer; }
            button.primary { border-color: #1769aa; color: white; background: #1769aa; }
          </style>
        </head>
        <body>
          <header><h1>Concrete takeoff</h1><p>Live quantities from Basegrid-generated objects in this model.</p></header>
          <main>
            <section class="metrics">
              <div class="metric"><strong id="total"></strong><span>Total concrete</span></div>
              <div class="metric"><strong id="objects"></strong><span>Generated objects</span></div>
              <div class="metric"><strong id="materials"></strong><span>Materials</span></div>
              <div class="metric"><strong id="groups"></strong><span>Takeoff groups</span></div>
            </section>
            <div class="table-wrap">
              <table><thead><tr><th>Takeoff group</th><th>Material</th><th class="number">Quantity</th><th>Unit</th></tr></thead><tbody id="rows"></tbody></table>
            </div>
            <footer><button onclick="sketchup.refresh()">Refresh</button><button class="primary" onclick="sketchup.exportCsv()">Export CSV</button></footer>
          </main>
          <script>
            const data = #{payload};
            const text = value => document.createTextNode(value);
            document.getElementById("total").textContent = data.total_m3.toFixed(3) + " m³";
            document.getElementById("objects").textContent = data.object_count;
            document.getElementById("materials").textContent = data.material_count;
            document.getElementById("groups").textContent = data.group_count;
            data.grouped_rows.forEach(row => {
              const tr = document.createElement("tr");
              [row.group_name, row.material_name, Number(row.quantity).toFixed(3), row.unit === "m3" ? "m³" : row.unit].forEach((value, index) => {
                const td = document.createElement("td");
                if (index === 2) td.className = "number";
                td.appendChild(text(value)); tr.appendChild(td);
              });
              document.getElementById("rows").appendChild(tr);
            });
          </script>
        </body>
        </html>
      HTML
    end

    def export_takeoff_csv
      rows = Takeoff.summary_rows(Takeoff.records(Sketchup.active_model))
      return UI.messagebox("There is no concrete takeoff to export.") if rows.empty?

      path = UI.savepanel("Export Concrete Takeoff", nil, "concrete-takeoff.csv")
      return unless path

      path += ".csv" unless File.extname(path).downcase == ".csv"
      File.open(path, "w:UTF-8") { |file| file.write(Takeoff.grouped_csv(Takeoff.records(Sketchup.active_model))) }
      UI.messagebox("Concrete takeoff exported to:\n#{path}")
    rescue StandardError => e
      UI.messagebox("Concrete takeoff could not be exported.\n\n#{e.message}")
    end

    def appearance_command
      command = UI::Command.new("Switch Material Texture") { toggle_material_appearance }
      icon = File.join(__dir__, "icons", "switch_texture.png")
      command.small_icon = icon
      command.large_icon = icon
      command.tooltip = "Switch Material Texture"
      command.status_bar_text = "Switch generated materials between model and display textures."
      command.menu_text = "Switch Material Texture"
      command.set_validation_proc do
        MaterialAppearance.mode(Sketchup.active_model) == MaterialAppearance::DISPLAY_MODE ? MF_CHECKED : MF_UNCHECKED
      end
      command
    end

    def create_toolbar
      @toolbar = UI::Toolbar.new("Basegrid")
      @toolbar.add_item(@takeoff_command)
      @toolbar.add_item(@appearance_command)
      @toolbar.restore
    end

    def toggle_material_appearance
      result = MaterialAppearance.new.toggle(Sketchup.active_model)
      label = result[:mode] == MaterialAppearance::DISPLAY_MODE ? "Display" : "Model"
      message = "Material appearance: #{label}. #{result[:changed]} generated object#{result[:changed] == 1 ? '' : 's'} updated."
      unless result[:missing_material_ids].empty?
        message += "\n\n#{result[:missing_material_ids].length} material binding#{result[:missing_material_ids].length == 1 ? '' : 's'} could not be resolved from the local cache."
      end
      UI.messagebox(message)
      Sketchup.active_model.active_view.invalidate
    rescue StandardError => e
      UI.messagebox("Material appearance could not be switched.\n\n#{e.message}")
    end

    def material_sync_token
      oauth_token = oauth_connection.access_token
      return oauth_token unless oauth_token.empty?

      legacy_material_sync_token
    end

    def legacy_material_sync_token
      Sketchup.read_default("Basegrid", "materials_sync_token", "").to_s.strip
    end

    def oauth_connection
      @oauth_connection ||= OAuthConnection.new
    end

    def sync_with_token(token)
      MaterialLibrary.new.sync!(url: material_library_url, token: token)
    end

    def material_library_url
      url = Sketchup.read_default("Basegrid", "material_library_url", MaterialLibrary::DEFAULT_URL).to_s
      # Repair the former production default without replacing development URLs.
      if url == "https://basegrid.overlandbuilders.co/api/v1/material-library"
        url = MaterialLibrary::DEFAULT_URL
      end
      url
    end

    def cloud_connection_status = CloudDrawing.connection_status

    def concrete_slab_tool
      @concrete_slab_tool ||= ConcreteSlabTool.new
    end
  end
end

Basegrid::Main.start
