import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
const require=createRequire(import.meta.url);
const {chromium}=require(process.env.PLAYWRIGHT_PACKAGE||'playwright');
const browser=await chromium.launch({headless:true});
try{
  const page=await browser.newPage(),errors=[];
  page.on('pageerror',e=>errors.push(e.message));
  await page.addInitScript(()=>{
    window.created=[];window.profileCalls=[];window.stored=[];
    window.sketchup={
      create:json=>window.created.push(JSON.parse(json)),
      profiles:json=>{
        const req=JSON.parse(json);window.profileCalls.push(req);
        if(req.action==='save'){
          window.stored=window.stored.filter(p=>p.name!==req.previous_name);
          window.stored.push({name:req.name,settings:req.settings});
          profileResponse({profiles:window.stored,selected:req.name});
        }else{window.stored=window.stored.filter(p=>p.name!==req.name);profileResponse({profiles:window.stored,selected:''});}
      }
    };
  });
  for(const width of [1020,390]){
    await page.setViewportSize({width,height:850});
    await page.goto(new URL('../tmp/flashing-production.html',import.meta.url).href);
    assert.equal(await page.locator('#match-status').textContent(),'Matched');
    assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
    await page.getByLabel('Folds',{exact:true}).selectOption('0');
    await page.getByLabel('Length A',{exact:true}).fill('125');
    assert.equal(await page.locator('#legs tr').count(),1);
    const target=await page.evaluate(()=>anchorTargets[1]);
    await page.locator('#profile').click({position:{x:target[0],y:target[1]}});
    assert.equal(await page.locator('#profile').getAttribute('data-anchor-index'),'1');
    const pixels=await page.locator('#profile').evaluate(c=>{const d=c.getContext('2d').getImageData(0,0,c.width,c.height).data;let n=0;for(let i=0;i<d.length;i+=4)if(d[i]<60&&d[i+1]>70&&d[i+1]<150&&d[i+3])n++;return n;});
    assert.ok(pixels>100,'Visible profile pixels');
    await page.getByRole('button',{name:'Change material',exact:true}).click();
    const overrideId=await page.locator('#material-override optgroup option').first().getAttribute('value');
    await page.getByLabel('Takeoff material override',{exact:true}).selectOption(overrideId);
    assert.equal(await page.locator('#match-status').textContent(),'Manual override');
    await page.locator('.saved-profiles summary').click();
    await page.getByLabel('Profile name',{exact:true}).fill('Flat 125');
    await page.getByRole('button',{name:'Save new',exact:true}).click();
    assert.equal(await page.locator('#profile-status').textContent(),'Profile saved.');
    await page.getByLabel('Length A',{exact:true}).fill('150');
    await page.getByRole('button',{name:'Update',exact:true}).click();
    assert.equal(await page.evaluate(()=>profileCalls.at(-1).previous_name),'Flat 125');
    await page.getByRole('button',{name:'Reset profile'}).click();
    await page.getByLabel('Saved profile',{exact:true}).selectOption('');
    await page.getByLabel('Saved profile',{exact:true}).selectOption('Flat 125');
    assert.equal(await page.getByLabel('Length A',{exact:true}).inputValue(),'150');
    await page.getByRole('button',{name:'Draw flashing',exact:true}).click();
    const created=await page.evaluate(()=>window.created.at(-1));
    assert.deepEqual(created.lengths_mm,[150]);assert.deepEqual(created.angles_deg,[]);
    assert.equal(created.material_id,overrideId);assert.equal(created.anchor_index,1);
    await page.screenshot({path:`tmp/flashing-production-${width}.png`,fullPage:true});
    page.once('dialog',dialog=>dialog.accept());
    await page.getByRole('button',{name:'Delete',exact:true}).click();
    assert.equal(await page.locator('#profile-status').textContent(),'Profile deleted.');
  }
  assert.deepEqual(errors,[]);
  console.log('Production flashing dialog passed desktop/mobile, flat profile pixels, anchor, override and native create/profile callbacks.');
}finally{await browser.close();}
