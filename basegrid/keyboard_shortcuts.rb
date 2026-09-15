# frozen_string_literal: true

require "json"

module Basegrid
  module KeyboardShortcuts
    ACTIONS = {
      "step_down" => { "label" => "Step down", "default" => "[" },
      "step_up" => { "label" => "Step up", "default" => "]" },
      "step_height" => { "label" => "Change step height", "default" => "" }
    }.freeze
    # Single keys on English-layout laptop keyboards, excluding native tools,
    # inference, measurement characters and operating-system modifier chords.
    KEYS = %w[D J N U V W X Y [ ] ; \\].freeze
    WINDOWS_CODES = { "[" => 219, "]" => 221, ";" => 186, "\\" => 220 }.freeze
    PREFERENCE_KEY = "drawing_keyboard_shortcuts"
    module_function

    def defaults = ACTIONS.transform_values { |action| action.fetch("default") }

    def saved
      raw = JSON.parse(Sketchup.read_default("Basegrid", PREFERENCE_KEY, "{}"))
      raw.is_a?(Hash) ? defaults.merge(raw.slice(*ACTIONS.keys)) : defaults
    rescue JSON::ParserError, TypeError
      defaults
    end

    def registered
      return {} unless Sketchup.respond_to?(:get_shortcuts)
      Sketchup.get_shortcuts.each_with_object({}) do |entry, result|
        key, command = entry.split("\t", 2)
        next unless key && command
        result[key.strip.upcase] = command
      end
    rescue StandardError
      nil
    end

    def problems(bindings, shortcuts = registered)
      return ["SketchUp shortcuts could not be checked. Reopen this dialog before saving."] unless shortcuts
      errors = []
      ACTIONS.each do |action, definition|
        key = bindings[action]
        next if key == ""
        if !KEYS.include?(key)
          errors << "#{definition['label']}: choose an available key or Disabled."
        elsif shortcuts.key?(key)
          errors << "#{definition['label']}: #{key} is assigned to #{shortcuts[key]}."
        elsif bindings.values.count(key) > 1
          errors << "#{definition['label']}: #{key} is also used by another Basegrid action."
        end
      end
      errors
    end

    def save(raw)
      raise "Invalid shortcut settings." unless raw.is_a?(Hash) && raw.keys.sort == ACTIONS.keys.sort
      errors = problems(raw)
      raise errors.join("\n") unless errors.empty?
      Sketchup.write_default("Basegrid", PREFERENCE_KEY, JSON.generate(raw))
    end

    def effective
      bindings, shortcuts = saved, registered
      return ACTIONS.transform_values { "" } unless shortcuts
      bindings.transform_values do |key|
        KEYS.include?(key) && !shortcuts.key?(key) && bindings.values.count(key) == 1 ? key : ""
      end
    end

    def action_for(key_code, mac:)
      effective.find do |_, key|
        !key.empty? && (mac ? key.ord : WINDOWS_CODES.fetch(key, key.ord)) == key_code
      end&.first
    end

    def label(action) = effective.fetch(action).then { |key| key.empty? ? "Unassigned" : key }

    def show
      @dialog&.close
      @dialog = UI::HtmlDialog.new(dialog_title: "Basegrid Keyboard Shortcuts", preferences_key: "basegrid_keyboard_shortcuts",
        scrollable: true, resizable: true, width: 580, height: 600, style: UI::HtmlDialog::STYLE_DIALOG)
      @dialog.add_action_callback("saveShortcuts") do |_, encoded|
        begin
          save(JSON.parse(encoded))
          @dialog.close
        rescue StandardError => e
          @dialog.execute_script("showError(#{JSON.generate(e.message)});")
        end
      end
      @dialog.add_action_callback("cancelShortcuts") { @dialog.close }
      @dialog.set_html(html)
      @dialog.show
    end

    def html
      payload = JSON.generate(actions: ACTIONS, keys: KEYS, saved: saved, shortcuts: registered).gsub("<", "\\u003c")
      <<~HTML
        <!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <style>
        *{box-sizing:border-box;letter-spacing:0}body{margin:0;color:#202827;background:#fff;font:13px -apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif}
        header{padding:20px 24px;border-bottom:1px solid #d9dfdc}header small{color:#176b56;font-weight:700;font-size:10px}h1{font-size:22px;font-weight:600;margin:5px 0 0}
        main{padding:20px 24px 100px}h2{font-size:14px;margin:0 0 14px}section{padding-bottom:20px;margin-bottom:20px;border-bottom:1px solid #d9dfdc}
        .row{display:grid;grid-template-columns:minmax(0,1fr) 150px;gap:16px;align-items:center;margin:12px 0}label{font-size:13px}select{width:100%;height:36px;min-width:0;border:1px solid #b7c3bd;border-radius:4px;padding:6px;background:#fff;color:#202827;font:inherit}
        button{font:600 12px -apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;padding:10px 14px;border:1px solid #b7c3bd;border-radius:4px;background:white;color:#202827;cursor:pointer}
        button.primary{background:#176b56;color:white;border-color:#176b56}button:disabled{opacity:.5;cursor:default}button:focus-visible,select:focus-visible,summary:focus-visible{outline:2px solid #176b56;outline-offset:3px}
        footer{position:fixed;bottom:0;left:0;right:0;padding:14px 24px;background:#fff;border-top:1px solid #d9dfdc;display:flex;gap:8px;justify-content:flex-end}footer button:first-child{margin-right:auto}
        dl{display:grid;grid-template-columns:1fr auto;gap:10px;font-size:12px;margin:0}dt{color:#63706c}dd{margin:0;text-align:right}summary{color:#176b56;cursor:pointer;font-size:12px}details p{color:#63706c;line-height:1.6}
        #error{color:#a32424;white-space:pre-line;overflow-wrap:anywhere;font-size:12px;line-height:1.5}#error:empty{display:none}
        @media(max-width:390px){header,main{padding-left:16px;padding-right:16px}.row{grid-template-columns:minmax(0,1fr) 110px}footer{padding:12px 16px;gap:6px}button{padding:9px 10px}}
        </style></head><body><header><small>BASEGRID</small><h1>Keyboard shortcuts</h1></header>
        <form id="form"><main><section><h2>Strip footing</h2><div id="actions"></div><p id="error" role="alert" aria-live="polite"></p></section>
        <section><h2>Shared drawing keys</h2><dl><dt>Inference locking</dt><dd>Arrows / Shift</dd><dt>Cycle anchor</dt><dd>Tab</dd><dt>Undo point</dt><dd>Backspace / Delete</dd></dl></section>
        <details><summary>Tool-launch shortcuts and key conflicts</summary><p>Assign Basegrid menu commands in SketchUp Settings / Preferences &gt; Shortcuts. SketchUp checks launch-key conflicts. In-tool keys are checked against registered SketchUp shortcuts; private key handling in other extensions may not be detectable. Shared drawing keys and measurement entry are reserved. Available keys target English-layout Mac and Windows laptop keyboards.</p></details>
        </main><footer><button id="reset" type="button">Restore defaults</button><button id="cancel" type="button">Cancel</button><button id="save" class="primary" type="submit">Save</button></footer></form>
        <script>
        const data=#{payload},controls={};
        const showError=text=>{document.getElementById('error').textContent=text;document.getElementById('save').disabled=false;};
        function validate(){
          const errors=[],keys=Object.values(controls).map(input=>input.value);
          if(!data.shortcuts)errors.push('SketchUp shortcuts could not be checked. Reopen this dialog before saving.');
          for(const [action,input] of Object.entries(controls)){
            const key=input.value;if(!key)continue;
            if(!data.keys.includes(key))errors.push(data.actions[action].label+': choose an available key or Disabled.');
            else if(data.shortcuts?.[key])errors.push(data.actions[action].label+': '+key+' is assigned to '+data.shortcuts[key]+'.');
            else if(keys.filter(value=>value===key).length>1)errors.push(data.actions[action].label+': '+key+' is also used by another Basegrid action.');
          }
          document.getElementById('error').textContent=errors.join('\\n');document.getElementById('save').disabled=errors.length>0;return !errors.length;
        }
        for(const [action,definition] of Object.entries(data.actions)){
          const row=document.createElement('div');row.className='row';const label=document.createElement('label');label.htmlFor=action;label.textContent=definition.label;
          const input=document.createElement('select');input.id=action;input.add(new Option('Disabled',''));
          for(const key of data.keys){const option=new Option(key+(data.shortcuts?.[key]?' (in use)':''),key);input.add(option);}
          if(data.saved[action]&&!data.keys.includes(data.saved[action]))input.add(new Option('Unavailable key',data.saved[action]));
          input.value=data.saved[action];controls[action]=input;input.addEventListener('change',validate);row.append(label,input);document.getElementById('actions').append(row);
        }
        document.getElementById('reset').onclick=()=>{for(const [action,input] of Object.entries(controls))input.value=data.actions[action].default;validate();};
        document.getElementById('cancel').onclick=()=>{if(window.sketchup)sketchup.cancelShortcuts();};
        document.getElementById('form').onsubmit=event=>{event.preventDefault();if(!validate())return;if(!window.sketchup){showError('Open this dialog in SketchUp to save shortcuts.');return;}document.getElementById('save').disabled=true;sketchup.saveShortcuts(JSON.stringify(Object.fromEntries(Object.entries(controls).map(([action,input])=>[action,input.value]))));};
        validate();
        </script></body></html>
      HTML
    end
  end
end
