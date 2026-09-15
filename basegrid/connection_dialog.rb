# frozen_string_literal: true

require "json"

module Basegrid
  # A local account/status window. OAuth passwords and tokens stay out of HTML.
  class ConnectionDialog
    def initialize(&action)
      @action = action
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
      @dialog = UI::HtmlDialog.new(dialog_title: "Basegrid", preferences_key: "basegrid_connection",
        scrollable: true, resizable: true, width: 440, height: 340, style: UI::HtmlDialog::STYLE_DIALOG)
      @dialog.add_action_callback("ready") { render }
      @dialog.add_action_callback("connect") { @action.call(@state[:action]) if @state[:action] }
      @dialog.add_action_callback("signOut") { @action.call("sign_out") }
      @dialog.add_action_callback("close") { @dialog.close }
      @dialog.set_on_closed { @dialog = nil }
      @dialog.set_html(<<~HTML)
        <!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <style>
          *{box-sizing:border-box}body{margin:0;padding:28px;background:#f5f6f4;color:#18211d;font:14px -apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif}
          .brand{font-size:12px;letter-spacing:2px;font-weight:700;color:#53715f}h1{font-size:23px;margin:20px 0 12px}p{line-height:1.6;min-height:70px;white-space:pre-line}
          footer{display:flex;gap:10px;align-items:center;margin-top:22px}button{font:inherit;padding:10px 15px;border:1px solid #b8c5bc;border-radius:5px;cursor:pointer;background:white;color:inherit}
          #connect{background:#244d37;color:white;border-color:#244d37}#signout{padding:4px;border:0;background:none;font-size:12px;margin-top:18px;text-decoration:underline}[hidden]{display:none!important}
        </style></head><body>
          <div class="brand">BASEGRID</div><h1 id="title">Basegrid connection</h1><p id="message" role="status"></p>
          <footer><button id="connect" hidden onclick="sketchup.connect()"></button><button id="close" onclick="sketchup.close()">Close</button></footer>
          <button id="signout" hidden onclick="sketchup.signOut()">Sign out of Basegrid</button>
          <script>
            window.updateConnection = data => {
              document.getElementById('title').textContent = data.title;
              document.getElementById('message').textContent = data.message;
              const button = document.getElementById('connect');
              button.hidden = !data.action;
              button.textContent = data.action === 'sign_in' ? 'Sign in to Basegrid' : 'Reconnect';
              document.getElementById('signout').hidden = !data.signed_in;
              document.getElementById('close').textContent = data.signed_in ? 'Close' : 'Work offline';
            };
            document.addEventListener('DOMContentLoaded', () => sketchup.ready());
          </script>
        </body></html>
      HTML
      @dialog.show
    end

    private

    def render
      @dialog.execute_script("window.updateConnection(#{JSON.generate(@state).gsub('<', '\\u003c')})")
    end
  end
end
