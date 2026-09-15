import test from 'node:test';
import assert from 'node:assert/strict';
import {execFileSync} from 'node:child_process';
import {runInNewContext} from 'node:vm';

function dialog(saved={},catalog={}) {
  const ruby=process.env.RUBY || (process.platform==='win32'?'C:/Ruby34-x64/bin/ruby.exe':'ruby');
  const html=execFileSync(ruby,['-I.','-e',`require 'ostruct'; require './basegrid/strip_footing_tool'; library=OpenStruct.new(material_types: [],materials: [],concrete_materials: []); puts Basegrid::StripFootingTool.new(library: library).send(:settings_html,JSON.parse(ARGV[0]))`,JSON.stringify(saved)],{encoding:'utf8'});
  class Element {
    children=[];listeners={};value='';checked=false;disabled=false;hidden=false;
    constructor(tag){this.tag=tag;}
    append(...items){for(const item of items){if(item.parentElement)item.parentElement.children=item.parentElement.children.filter(x=>x!==item);this.children.push(item);item.parentElement=this;}}
    addEventListener(name,handler){(this.listeners[name]??=[]).push(handler);}
    fire(name){for(const handler of this.listeners[name]??[])handler();}
  }
  const ids=Object.fromEntries(['fields','form','error'].map(id=>[id,new Element('div')]));
  const scope={document:{getElementById:id=>ids[id],createElement:tag=>new Element(tag)},sketchup:{drawFooting:value=>scope.submitted=JSON.parse(value)}};
  const script=html.match(/<script>([\s\S]*?)<\/script>/)[1].replace('; const fields=',`; Object.assign(data.materials,${JSON.stringify(catalog)}); const fields=`);
  runInNewContext(script+';globalThis.controlsForTest=controls;globalThis.materialsForTest=materials;',scope);
  return {controls:scope.controlsForTest,materials:scope.materialsForTest,submit:()=>{ids.form.onsubmit({preventDefault(){}});return scope.submitted;}};
}

test('trench mesh supports default only when no previous selection exists',()=>{
  const catalog={chairs:[{id:'support-1',name:'Trench Mesh Support'},{id:'support-2',name:'Alternative Support'}]};
  assert.equal(dialog({},catalog).submit().materials.chairs,'support-1');
  assert.equal(dialog({materials:{chairs:'support-2'}},catalog).materials.chairs.value,'support-2');
  assert.equal(dialog({materials:{chairs:''}},catalog).materials.chairs.value,'');
  assert.equal(dialog({materials:{chairs:'removed'}},catalog).materials.chairs.value,'');
  assert.equal(dialog().materials.chairs.value,'');
});

test('double mesh defaults off and restores the saved layer selection',()=>{
  assert.equal(dialog().submit().settings.double_mesh,'none');
  for(const mode of ['top','bottom','top_bottom']){
    assert.equal(dialog({settings:{double_mesh:mode}}).submit().settings.double_mesh,mode);
  }
});

test('pier concrete follows footing until separately selected and preserves saved choice',()=>{
  const rows=[{id:'c25',name:'25 MPa'},{id:'c32',name:'32 MPa'}],catalog={concrete:rows,pier_concrete:rows};
  const {materials:m}=dialog({materials:{concrete:'c25'}},catalog);
  assert.equal(m.pier_concrete.value,'c25');
  m.concrete.value='c32';m.concrete.fire('change');assert.equal(m.pier_concrete.value,'c32');
  m.pier_concrete.value='c25';m.pier_concrete.fire('change');
  m.concrete.fire('change');assert.equal(m.pier_concrete.value,'c25');
  assert.equal(dialog({materials:{concrete:'c25',pier_concrete:'c32'}},catalog).materials.pier_concrete.value,'c32');
});

test('pier options gate fields and submit typed settings',()=>{
  const {controls:c,materials:m,submit}=dialog();
  assert.equal(c.include_piers.checked,false);
  assert.equal(c.pier_spacing_mm.disabled,true);
  c.include_piers.checked=true;c.include_piers.fire('change');
  assert.equal(c.pier_spacing_mm.disabled,false);
  assert.equal(c.pier_bar_above_mm.disabled,true);
  c.pier_add_bar.checked=true;c.pier_add_bar.fire('change');
  assert.equal(m.pier_bar.disabled,false);
  assert.equal(c.pier_bar_above_mm.value,225);
  assert.equal(c.pier_bar_below_mm.value,500);
  assert.equal(c.pier_bar_cog_mm.value,175);
  const result=submit();
  assert.equal(result.settings.include_piers,true);
  assert.equal(result.settings.pier_add_bar,true);
  assert.equal(result.settings.pier_bar_above_mm,225);
});

test('derived starter defaults update but manual lengths persist',()=>{
  const {controls:c}=dialog({settings:{depth_mm:450,pier_depth_mm:600,width_mm:450,pier_bar_above_mm:225,pier_bar_below_mm:500,pier_bar_cog_mm:175}});
  c.depth_mm.value=600;c.depth_mm.fire('input');
  c.pier_depth_mm.value=900;c.pier_depth_mm.fire('input');
  c.width_mm.value=600;c.width_mm.fire('input');
  assert.equal(c.pier_bar_above_mm.value,300);
  assert.equal(c.pier_bar_below_mm.value,800);
  assert.equal(c.pier_bar_cog_mm.value,250);
  c.pier_bar_above_mm.value=180;c.pier_bar_above_mm.fire('input');
  c.depth_mm.value=450;c.depth_mm.fire('input');
  assert.equal(c.pier_bar_above_mm.value,180);
});
