# frozen_string_literal: true

require "json"

module Basegrid
  # A local account/status window. OAuth passwords and tokens stay out of HTML.
  class ConnectionDialog
    def initialize(status_provider: nil, &action)
      @action = action
      @status_provider = status_provider
      @state = {}
    end

    def update(title:, message:, action: nil, signed_in: false)
      @state = { title: title, message: message, action: action, signed_in: signed_in }
      render if @dialog
    end

    def show
      if @dialog
        @dialog.bring_to_front
        return
      end
      @dialog = UI::HtmlDialog.new(dialog_title: "Basegrid Connections & Activity", preferences_key: "basegrid_connection",
        scrollable: true, resizable: true, width: 580, height: 650, style: UI::HtmlDialog::STYLE_DIALOG)
      @dialog.add_action_callback("ready") { @rendered = nil; render }
      @dialog.add_action_callback("connect") { @action.call(@state[:action]) if @state[:action] }
      @dialog.add_action_callback("signOut") { @action.call("sign_out") }
      @dialog.add_action_callback("syncMaterials") { @action.call("sync_materials") }
      @dialog.add_action_callback("disconnectCloud") { @action.call("disconnect_cloud") }
      @dialog.add_action_callback("close") { @dialog.close }
      @dialog.set_on_closed do
        UI.stop_timer(@timer) if @timer
        @timer = nil
        @dialog = nil
      end
      @dialog.set_html(<<~HTML)
        <!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <style>
          *{box-sizing:border-box}body{margin:0;padding:28px;background:#f5f6f4;color:#18211d;font:14px -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}
          .brand{font-size:12px;letter-spacing:0;font-weight:700;color:#53715f}h1{font-size:23px;margin:20px 0 12px}p{line-height:1.6;white-space:pre-line;overflow-wrap:anywhere}
          h2{font-size:14px;margin:20px 0 10px}dl{display:grid;grid-template-columns:130px minmax(0,1fr);gap:10px;margin:20px 0}dt{color:#59645f}dd{margin:0;overflow-wrap:anywhere}#events{padding-left:18px;font-size:12px;color:#59645f;max-height:150px;overflow:auto;overflow-wrap:anywhere}footer{display:flex;flex-wrap:wrap;gap:10px;align-items:center;margin-top:22px}button{font:inherit;padding:10px 15px;border:1px solid #b8c5bc;border-radius:5px;cursor:pointer;background:white;color:inherit}
          #connect{background:#244d37;color:white;border-color:#244d37}#signout{padding:4px;border:0;background:none;font-size:12px;margin-top:18px;text-decoration:underline}[hidden]{display:none!important}
        </style></head><body>
          <div class="brand">BASEGRID</div><h1 id="title">Basegrid connection</h1><p id="message" role="status"></p>
          <dl id="activity" aria-live="polite"></dl><h2>Recent activity</h2><ol id="events"></ol>
          <footer><button id="connect" hidden onclick="sketchup.connect()"></button><button id="close" onclick="sketchup.close()">Close</button></footer>
          <footer><button onclick="sketchup.syncMaterials()">Sync materials</button><button id="disconnect" hidden onclick="sketchup.disconnectCloud()">Disconnect cloud</button></footer>
          <button id="signout" hidden onclick="sketchup.signOut()">Sign out of Basegrid</button>
          <script>
            const previous = new Map();
            window.updateConnection = data => {
              document.getElementById('title').textContent = data.title;
              document.getElementById('message').textContent = data.message;
              const button = document.getElementById('connect');
              button.hidden = !data.action;
              button.textContent = data.action === 'sign_in' ? 'Sign in to Basegrid' : 'Reconnect';
              document.getElementById('signout').hidden = !data.signed_in;
              document.getElementById('close').textContent = data.signed_in ? 'Close' : 'Work offline';
              document.getElementById('disconnect').hidden = !data.details?.cloud_running;
              const activity=document.getElementById('activity');activity.replaceChildren();
              for(const row of data.details?.rows||[]){const dt=document.createElement('dt'),dd=document.createElement('dd');dt.textContent=row.label;dd.textContent=row.value;activity.append(dt,dd);if(previous.get(row.label)!==row.value){previous.set(row.label,row.value);const li=document.createElement('li');li.textContent=new Date().toLocaleTimeString()+' - '+row.label+': '+row.value;const events=document.getElementById('events');events.prepend(li);while(events.children.length>20)events.lastChild.remove();}}
            };
            document.addEventListener('DOMContentLoaded', () => sketchup.ready());
          </script>
        </body></html>
      HTML
      @dialog.show
      @timer = UI.start_timer(0.5, true) { render } if @status_provider
    end

    private

    def render
      return unless @dialog
      value = @state.merge(details: @status_provider ? @status_provider.call : {})
      return if value == @rendered
      @rendered = value
      @dialog.execute_script("window.updateConnection(#{JSON.generate(value).gsub('<', '\\u003c')})")
    end
  end
end
