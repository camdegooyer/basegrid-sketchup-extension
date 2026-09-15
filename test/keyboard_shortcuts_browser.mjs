import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {execFileSync} from 'node:child_process';
import {mkdirSync} from 'node:fs';
const require=createRequire(import.meta.url);
const {chromium}=require(process.env.PLAYWRIGHT_PACKAGE||'playwright');
const ruby=process.env.RUBY||(process.platform==='win32'?'C:/Ruby34-x64/bin/ruby.exe':'ruby');
const html=execFileSync(ruby,['-I.','-e',`require './basegrid/keyboard_shortcuts';module Sketchup;def self.read_default(*);'{}';end;def self.get_shortcuts;["U\\tExtensions/Other Tool"];end;end;puts Basegrid::KeyboardShortcuts.html`],{encoding:'utf8'});
mkdirSync('tmp',{recursive:true});
const browser=await chromium.launch({headless:true});
try{
  const page=await browser.newPage(),errors=[];page.on('pageerror',error=>errors.push(error.message));
  for(const width of [580,360]){
    await page.goto('about:blank');await page.setViewportSize({width,height:650});await page.setContent(html);
    assert.deepEqual(errors,[]);
    assert.equal(await page.locator('#step_up').inputValue(),']');
    await page.locator('#step_up').selectOption('U');
    assert.match(await page.locator('#error').textContent(),/Other Tool/);
    assert.equal(await page.locator('#save').isDisabled(),true);
    await page.locator('#step_up').selectOption('[');
    assert.match(await page.locator('#error').textContent(),/another Basegrid/);
    await page.getByRole('button',{name:'Restore defaults'}).click();
    assert.equal(await page.locator('#save').isDisabled(),false);
    await page.locator('#step_down').selectOption('J');
    await page.locator('#step_height').selectOption('N');
    await page.locator('#step_up').selectOption('');
    assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
    await page.screenshot({path:`tmp/keyboard-shortcuts-${width}.png`,fullPage:true});
    await page.evaluate(()=>{window.sketchup={saveShortcuts:raw=>window.saved=JSON.parse(raw),cancelShortcuts:()=>window.cancelled=true};});
    await page.getByRole('button',{name:'Save',exact:true}).click();
    assert.deepEqual(await page.evaluate(()=>window.saved),{step_down:'J',step_up:'',step_height:'N'});
    await page.evaluate(()=>showError('Shortcut changed in SketchUp.'));
    assert.equal(await page.locator('#save').isDisabled(),false);
    await page.getByRole('button',{name:'Cancel',exact:true}).click();assert.equal(await page.evaluate(()=>window.cancelled),true);
  }
  assert.deepEqual(errors,[]);console.log('Keyboard dialog passed desktop/narrow layout, conflicts, reset, disable, save and cancel checks.');
}finally{await browser.close();}
