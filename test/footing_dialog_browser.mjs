import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {execFileSync} from 'node:child_process';
import {mkdirSync} from 'node:fs';
const require=createRequire(import.meta.url);
const {chromium}=require(process.env.PLAYWRIGHT_PACKAGE||'playwright');
const ruby=process.env.RUBY||(process.platform==='win32'?'C:/Ruby34-x64/bin/ruby.exe':'ruby');
const html=execFileSync(ruby,['-I.','-e',`require 'ostruct';require './basegrid/strip_footing_tool';library=OpenStruct.new(material_types:[],materials:[],concrete_materials:[]);puts Basegrid::StripFootingTool.new(library:library).send(:settings_html,{})`],{encoding:'utf8'});
const browser=await chromium.launch({headless:true});
mkdirSync('tmp',{recursive:true});
try{
  const page=await browser.newPage(),errors=[];page.on('pageerror',e=>errors.push(e.message));
  for(const width of [820,390,320]){
    await page.goto('about:blank');await page.setViewportSize({width,height:760});await page.setContent(html);
    assert.deepEqual(errors,[]);
    assert.match(await page.locator('.reference canvas').getAttribute('aria-label'),/4 bars per layer/);
    await page.locator('#width_mm').fill('300');
    assert.match(await page.locator('.reference canvas').getAttribute('aria-label'),/3 bars per layer/);
    await page.locator('#width_mm').fill('450');
    await page.evaluate(()=>{
      data.materials.mesh.push({id:'test-mesh',name:'3L11',dimensions_mm:{bars:3,diameter:11}});
      const option=new Option('3L11','test-mesh');materials.mesh.append(option);
    });
    await page.locator('#material_mesh').selectOption('test-mesh');
    assert.match(await page.locator('.reference canvas').getAttribute('aria-label'),/3 bars per layer/);
    await page.locator('#material_mesh').selectOption('');
    await page.getByText('Advanced reinforcement',{exact:true}).click();
    await page.locator('#double_mesh').selectOption('top_bottom');
    assert.equal(await page.locator('#pier_spacing_mm').isVisible(),false);
    assert.equal(await page.locator('#step_z_threshold_mm').isVisible(),false);
    await page.locator('#include_piers').check();await page.locator('#pier_add_bar').check();
    await page.locator('#depth_mm').fill('600');
    assert.equal(await page.locator('#pier_bar_above_mm').inputValue(),'300');
    await page.locator('#pier_bar_above_mm').fill('180');await page.locator('#depth_mm').fill('450');
    assert.equal(await page.locator('#pier_bar_above_mm').inputValue(),'180');
    await page.locator('#include_step_z_bars').check();
    await page.getByText('Step and Z-bar detail',{exact:true}).click();
    await page.locator('#step_height_mm').fill('300');
    assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
    assert.equal(await page.evaluate(()=>Array.from(document.querySelectorAll('input,select')).filter(e=>e.getBoundingClientRect().width).every(e=>{const r=e.getBoundingClientRect();return r.left>=0&&r.right<=innerWidth;})),true);
    const nonblank=await page.locator('.reference canvas').evaluate(el=>{const p=el.getContext('2d').getImageData(0,0,el.width,el.height).data;let n=0;for(let i=3;i<p.length;i+=4)if(p[i])n++;return n>1000;});assert.equal(nonblank,true);
    await page.evaluate(()=>scrollTo(0,0));await page.screenshot({path:`tmp/footing-ui-${width}.png`,fullPage:true});
    await page.evaluate(()=>{window.sketchup={drawFooting:raw=>window.submitted=JSON.parse(raw)};});
    await page.getByRole('button',{name:'Start drawing'}).click();
    const submitted=await page.evaluate(()=>window.submitted);assert.equal(submitted.settings.pier_bar_above_mm,180);assert.equal(submitted.settings.include_piers,true);assert.equal(submitted.settings.step_height_mm,300);
    assert.equal(submitted.settings.double_mesh,'top_bottom');
  }
  assert.deepEqual(errors,[]);console.log('Dialog browser checks passed: 820, 390 and 320 px; controls, diagrams, submission, overflow.');
}finally{await browser.close();}
