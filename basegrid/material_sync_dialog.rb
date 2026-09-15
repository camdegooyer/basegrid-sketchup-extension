# frozen_string_literal: true
require "json"
require "thread"
require_relative "material_library"

module Basegrid
  class MaterialSyncDialog
    def initialize(token_provider:, url_provider:, connect:, library: MaterialLibrary.new)
      @token_provider, @url_provider, @connect, @library = token_provider, url_provider, connect, library
      @state = { status: "idle", message: "Ready to sync" }
      @running = false
    end

    def show
      if @dialog
        @dialog.show
        start_sync unless @running
        return
      end
      dialog = UI::HtmlDialog.new(dialog_title: "Material Sync", preferences_key: "basegrid_material_sync",
                                  width: 500, height: 440, scrollable: true, resizable: true,
                                  style: UI::HtmlDialog::STYLE_DIALOG)
      @dialog = dialog
      dialog.add_action_callback("ready") { |_| @running ? render : start_sync }
      dialog.add_action_callback("sync") { |_| start_sync }
      dialog.add_action_callback("connect") { |_| @connect.call unless @running }
      dialog.set_on_closed { @dialog = nil if @dialog.equal?(dialog) }
      dialog.set_html(html)
      dialog.show
    end

    def status_snapshot = @state.dup

    def start_sync
      return if @running
      @running = true
      @state = { status: "running", stage: "connect", message: "Checking connection" }
      render
      token = @token_provider.call.to_s
      raise "Sign in to Basegrid, then retry syncing." if token.empty?
      url = @url_provider.call
      @events = Queue.new
      events = @events
      library = @library
      # Only plain Ruby network/file work runs here. All SketchUp/UI calls stay on the main thread.
      @worker = Thread.new do
        begin
          result = library.sync!(url: url, token: token) { |event| events << event.merge(status: "running") }
          events << { status: "complete", message: result[:changed] ? "Library updated" : "Library already current", result: result }
        rescue StandardError => e
          events << { status: "error", message: e.message }
        end
      end
      @timer = UI.start_timer(0.15, true) { poll }
    rescue StandardError => e
      @running = false
      @state = { status: "error", message: e.message }
      render
    end

    def poll
      latest = nil
      begin
        loop { latest = @events.pop(true) }
      rescue ThreadError
        # Queue is drained; render once per UI tick, even for a large library.
      end
      return unless latest
      @state = latest
      if %w[complete error].include?(@state[:status])
        @running = false
        UI.stop_timer(@timer) if @timer
        @timer = nil
      end
      render
    end

    def render
      @dialog&.execute_script("updateSync(#{JSON.generate(@state).gsub('<','\\u003c')})")
    end

    def html
      <<~HTML
        <!doctype html><html><head><meta charset="utf-8"><style>
        *{box-sizing:border-box}body{font:13px -apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;margin:22px;color:#25282b;background:#fff}h1{font-size:20px;margin:0 0 20px}h2{font-size:15px;margin:0 0 10px}progress{width:100%;height:12px;accent-color:#246c52}#detail{margin:10px 0;overflow-wrap:anywhere;color:#5f6368;min-height:36px}dl{display:grid;grid-template-columns:1fr auto;gap:8px;margin:18px 0}dt,dd{margin:0}dd{font-variant-numeric:tabular-nums}#warnings{padding-left:18px;color:#8b4a0b;overflow-wrap:anywhere}#error{color:#b42318;overflow-wrap:anywhere}footer{display:flex;gap:10px;margin-top:18px}button{padding:8px 14px;border:1px solid #bcc2c7;border-radius:3px;background:#fff;color:#25282b;cursor:pointer}button.primary{background:#246c52;color:#fff;border-color:#246c52}button:disabled{opacity:.5;cursor:default}[hidden]{display:none!important}
        </style></head><body><h1>Material sync</h1><h2 id="status" role="status" aria-live="polite">Connecting</h2><progress id="progress" aria-label="Sync progress"></progress><div id="detail"></div>
        <dl id="counts" hidden><dt>Materials cached</dt><dd id="materials"></dd><dt>Takeoff groups</dt><dd id="groups"></dd></dl>
        <div id="error" role="alert" hidden></div><ul id="warnings" hidden></ul><footer><button id="sync" class="primary" disabled onclick="sketchup.sync()">Sync again</button><button id="connect" hidden onclick="sketchup.connect()">Sign in</button></footer>
        <script>
        const el=id=>document.getElementById(id);
        function updateSync(data){const running=data.status==='running',failed=data.status==='error',done=data.status==='complete';el('sync').disabled=running;el('sync').textContent=failed?'Retry':'Sync again';el('connect').hidden=!failed;el('progress').hidden=failed;el('error').hidden=!failed;el('counts').hidden=!done;el('warnings').hidden=true;el('warnings').replaceChildren();el('status').textContent=failed?'Sync failed':done?data.message:({connect:'Connecting',cache:'Reading cache',download:'Downloading library',materials:'Library received',textures:'Syncing textures',save:'Saving cache'}[data.stage]||'Syncing');el('detail').textContent=running?(data.stage==='textures'?`${data.completed} of ${data.total} textures · ${data.message}`:data.message):'';el('error').textContent=failed?data.message+' The last valid material cache was kept.':'';if(done){el('progress').max=1;el('progress').value=1;el('materials').textContent=data.result.materials;el('groups').textContent=data.result.takeoff_groups;(data.result.warnings||[]).forEach(warning=>{const li=document.createElement('li');li.textContent=warning;el('warnings').append(li);});el('warnings').hidden=!(data.result.warnings||[]).length;}else if(data.stage==='textures'&&data.total>0){el('progress').max=data.total;el('progress').value=data.completed;}else el('progress').removeAttribute('value');}
        sketchup.ready();
        </script></body></html>
      HTML
    end
  end
end
