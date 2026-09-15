// Presentation only: the settings controls and their existing callbacks remain authoritative.
const form=document.getElementById('form');
const create=(tag,className,text)=>{const el=document.createElement(tag);if(className)el.className=className;if(text)el.textContent=text;return el;};
const sections={};
for(const [index,name] of ['Footing','Reinforcement','Steps','Piers'].entries()){
  const section=create('section','setting-section'),heading=create('div','section-heading'),title=create('h2');
  title.append(create('span','section-number',String(index+1).padStart(2,'0')),document.createTextNode(name));
  heading.append(title);section.append(heading);const grid=create('div','section-grid');section.append(grid);fields.append(section);sections[name]=grid;
}
const move=(section,keys,source=controls)=>{for(const key of keys)sections[section].append(source[key].parentElement);};
move('Footing',['width_mm','depth_mm']);move('Footing',['concrete'],materials);
move('Reinforcement',['reinforcement']);move('Reinforcement',['mesh','chairs','spacers'],materials);
const advanced=create('details','help wide');advanced.append(create('summary',null,'Advanced reinforcement'),controls.double_mesh.parentElement);
sections.Reinforcement.append(advanced);
for(const option of controls.double_mesh.options)option.textContent={none:'Off',top:'Top',bottom:'Bottom',top_bottom:'Both'}[option.value];
advanced.append(create('p',null,'Two strips set out at 50 mm side cover, with no more than 100 mm clear between strips. Overlapping strips stack within the layer.'));
advanced.open=controls.double_mesh.value!=='none';
const doubleState=()=>{controls.double_mesh.disabled=controls.reinforcement.value==='none';};
controls.reinforcement.addEventListener('change',doubleState);doubleState();
move('Steps',['step_height_mm','include_step_z_bars','step_z_threshold_mm']);move('Steps',['z_bars'],materials);
move('Piers',['include_piers']);sections.Piers.append(pierFields);
pierFields.prepend(materials.pier_concrete.parentElement);
const zFields=create('div','optional-fields');sections.Steps.append(zFields);
zFields.append(controls.step_z_threshold_mm.parentElement,materials.z_bars.parentElement);
const showZ=()=>{zFields.hidden=!controls.include_step_z_bars.checked;};
controls.include_step_z_bars.addEventListener('change',showZ);showZ();
for(const [key,input] of Object.entries(controls)){
  input.id=key;input.parentElement.htmlFor=key;
  if(input.type==='checkbox')input.parentElement.classList.add('check');
}
controls.reinforcement.parentElement.classList.add('wide');
const meshLabels={none:'No mesh',bottom:'Bottom layer',top_bottom:'Top and bottom layers'};
for(const option of controls.reinforcement.options)option.textContent=meshLabels[option.value];
for(const [role,input] of Object.entries(materials)){
  input.id='material_'+role;input.parentElement.htmlFor=input.id;input.parentElement.classList.add('wide');
  const meta=create('span','material-meta');input.parentElement.append(meta);
  const update=()=>{
    const item=data.materials[role].find(row=>String(row.id)===input.value),d=item?.dimensions_mm??{};
    const parts=[];
    if(d.bars)parts.push(`${d.bars} bars`);
    if(d.diameter)parts.push(`Diameter ${d.diameter} mm`);
    if(d.width)parts.push(`Width ${d.width} mm`);
    if(d.height)parts.push(`Height ${d.height} mm`);
    meta.textContent=parts.join(' / ');meta.hidden=!parts.length;
  };
  input.addEventListener('change',update);form.addEventListener('input',update);form.addEventListener('change',update);update();
}
const hints={width_mm:'Overall concrete width. Clear cover is fixed at 50 mm.',depth_mm:'Overall concrete depth. Default step overlap is 1.5 times this depth.',step_height_mm:'Vertical increment used when stepping the drawing up or down.',step_z_threshold_mm:'Z bars are included only when the step exceeds this height, not when it equals it.',pier_spacing_mm:'Maximum distance between pier centres along the footing.',pier_bar_below_mm:'Defaults to pier depth less 100 mm.',pier_bar_above_mm:'Defaults to half the footing depth.',pier_bar_cog_mm:'Defaults to half the footing width less 50 mm.'};
for(const [key,text] of Object.entries(hints))controls[key].title=text;
const reference=create('aside','reference');reference.setAttribute('aria-label','Footing section preview');
const referenceTop=create('div','reference-top');referenceTop.append(create('h2',null,'Cross section'),create('small',null,'Indicative'));
const canvas=create('canvas');canvas.setAttribute('role','img');canvas.setAttribute('aria-label','Footing cross section');
const facts=create('dl');reference.append(referenceTop,canvas,facts);form.append(reference);
function setupCanvas(target,height){
  const width=Math.max(180,target.getBoundingClientRect().width),ratio=window.devicePixelRatio||1;
  target.width=Math.round(width*ratio);target.height=height*ratio;const c=target.getContext('2d');c.scale(ratio,ratio);c.font='11px Segoe UI, sans-serif';c.lineWidth=1;return {c,width,height};
}
function line(c,points,color='#70867a',width=1){c.beginPath();c.strokeStyle=color;c.lineWidth=width;points.forEach(([x,y],i)=>i?c.lineTo(x,y):c.moveTo(x,y));c.stroke();}
function dimension(c,x1,y1,x2,y2,text){line(c,[[x1,y1],[x2,y2]],'#7f8b85');c.fillStyle='#46534e';c.textAlign='center';
  if(y1===y2){line(c,[[x1,y1-3],[x1,y1+3]]);line(c,[[x2,y2-3],[x2,y2+3]]);c.fillText(text,(x1+x2)/2,y1-6);}
  else{line(c,[[x1-3,y1],[x1+3,y1]]);line(c,[[x2-3,y2],[x2+3,y2]]);c.save();c.translate(x1+13,(y1+y2)/2);c.rotate(-Math.PI/2);c.fillText(text,0,0);c.restore();}}
const number=key=>Math.max(0,Number(controls[key].value)||0);
function drawSection(){
  const h=window.innerWidth<=680?170:230,{c,width}=setupCanvas(canvas,h),w=number('width_mm'),d=number('depth_mm');
  c.clearRect(0,0,width,h);if(!w||!d)return;
  const scale=Math.min((width-82)/w,(h-66)/d),rw=w*scale,rh=d*scale,x=(width-rw)/2-6,y=(h-rh)/2+10;
  c.fillStyle='#dde5df';c.fillRect(x,y,rw,rh);c.strokeStyle='#859b8f';c.strokeRect(x,y,rw,rh);
  dimension(c,x,y-15,x+rw,y-15,`${w} mm`);dimension(c,x+rw+15,y,x+rw+15,y+rh,`${d} mm`);
  const mesh=data.materials.mesh.find(item=>String(item.id)===materials.mesh.value)?.dimensions_mm??{};
  const count=Math.max(1,Math.min(30,Number(mesh.bars)||(w>=450?4:3))),dia=Number(mesh.diameter)||data.mesh_diameter_mm;
  const inset=(50+dia/2)*scale,rows=controls.reinforcement.value==='none'?[]:controls.reinforcement.value==='bottom'?[y+rh-inset]:[y+inset,y+rh-inset];
  let gapWarning='';
  if(rw>inset*2&&rh>inset*2)for(const [rowIndex,cy] of rows.entries()){
    const top=rows.length===2&&rowIndex===0,mode=controls.double_mesh.disabled?'none':controls.double_mesh.value;
    const doubled=mode==='top_bottom'||mode===(top?'top':'bottom');
    const span=Number(mesh.width)||((count-1)*100),offset=(w-100-dia-span)/2;
    const offsets=doubled?[-offset,offset]:[0];
    if(doubled&&(offset<0||2*offset-span-dia>100))gapWarning='Double mesh does not fit';
    for(const [index,strip] of offsets.entries()){
      const center=x+rw/2+strip*scale,left=doubled?center-span*scale/2:x+inset,right=doubled?center+span*scale/2:x+rw-inset;
      const yBar=cy+(doubled&&2*offset<=span+dia?index*(dia+8)*scale*(top?1:-1):0);
      line(c,[[left,yBar],[right,yBar]],'#246c86',1.5);
      for(let i=0;i<count;i++){c.beginPath();c.fillStyle='#246c86';c.arc(count===1?center:left+i*(right-left)/(count-1),yBar,Math.max(2,dia*scale/2),0,Math.PI*2);c.fill();}
    }
  }
  canvas.setAttribute('aria-label',`${w} mm wide by ${d} mm deep footing, 50 mm clear cover, ${meshLabels[controls.reinforcement.value].toLowerCase()}${rows.length?`, ${count} bars per layer`:''}.`);
  facts.replaceChildren();for(const [label,value] of [['Clear cover','50 mm'],['Step overlap',`${d*1.5} mm`]])facts.append(create('dt',null,label),create('dd',null,value));
  if(gapWarning)facts.append(create('dt',null,'Check'),create('dd',null,gapWarning));
}
function help(section,title,text,draw){
  const details=create('details','help'),summary=create('summary',null,title);details.append(summary,create('p',null,text));
  if(draw){const target=create('canvas');target.setAttribute('role','img');target.setAttribute('aria-label',title+' schematic');details.append(target);const render=()=>{if(details.open)draw(target);};details.addEventListener('toggle',render);form.addEventListener('input',render);form.addEventListener('change',render);window.addEventListener('resize',render);}
  sections[section].append(details);
}
help('Footing','Cover and setout','Clear cover is 50 mm on all faces. Drawing starts from the top-left anchor.');
help('Steps','Step and Z-bar detail','Overlap defaults to 1.5 times the footing depth. Optional Z bars apply only above the nominated threshold. Deformed-bar legs lap 50 times the selected bar diameter.',target=>{
  const {c,width}=setupCanvas(target,160),left=24,right=width-24,mid=width/2;
  c.fillStyle='#dde5df';c.beginPath();[[left,40],[mid,40],[mid,75],[right,75],[right,135],[mid,135],[mid,100],[left,100]].forEach(([x,y],i)=>i?c.lineTo(x,y):c.moveTo(x,y));c.closePath();c.fill();
  line(c,[[left+8,86],[mid+20,86]],'#246c86',2);line(c,[[mid-20,121],[right-8,121]],'#246c86',2);
  if(controls.include_step_z_bars.checked&&number('step_height_mm')>number('step_z_threshold_mm'))line(c,[[left+12,76],[mid-12,76],[mid+12,111],[right-12,111]],'#a35b36',3);
  c.fillStyle='#63706c';c.textAlign='left';c.fillText(`Step ${number('step_height_mm')} mm`,left,22);c.textAlign='right';c.fillText('Schematic',right,22);
});
help('Piers','Pier starter detail','Starter defaults: below pier top = pier depth less 100 mm; into footing = half footing depth; upper cog = half footing width less 50 mm. Individual piers remain editable inside the footing group.',target=>{
  const {c,width}=setupCanvas(target,160),mid=width/2;
  c.fillStyle='#dde5df';c.fillRect(24,30,width-48,50);c.fillRect(mid-32,80,64,64);
  if(controls.pier_add_bar.checked)line(c,[[mid,132],[mid,55],[mid+40,55]],'#a35b36',3);
  c.fillStyle='#63706c';c.textAlign='left';c.fillText('Footing',30,21);c.fillText('Pier',mid+42,121);c.textAlign='right';c.fillText('Schematic',width-24,21);
});
const footer=create('div','footer'),submit=form.querySelector('[type=submit]');footer.append(create('small',null,'Dimensions in millimetres'),submit);form.append(footer);
const error=document.getElementById('error');error.setAttribute('role','alert');error.setAttribute('aria-live','assertive');
form.addEventListener('input',drawSection);form.addEventListener('change',drawSection);window.addEventListener('resize',drawSection);drawSection();
const submitSettings=form.onsubmit;
form.onsubmit=event=>{
  event.preventDefault();if(submit.disabled)return;
  if(!window.sketchup?.drawFooting){error.textContent='Open this tool in SketchUp to start drawing.';return;}
  error.textContent='';submit.disabled=true;
  try{submitSettings(event);}catch(e){error.textContent=e.message;submit.disabled=false;}
};
