import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { createDispatcher, TOOLS } from '../mcp/server.mjs';

const request = (method, params = {}, id = 1) => ({ jsonrpc: '2.0', id, method, params });

test('flashing profiles and override schemas are discoverable and relayed', async () => {
  const schema=TOOLS.find(t=>t.name==='basegrid_create_flashing').inputSchema;
  assert.equal(schema.properties.settings.properties.lengths_mm.minItems,1);
  assert.equal(schema.properties.settings.properties.angles_deg.minItems,0);
  assert.equal(schema.properties.settings.properties.material_id.type,'string');
  assert.equal(schema.properties.profile_name.type,'string');
  const calls=[];
  const dispatch=createDispatcher({requestBridge:async (_,body)=>{calls.push(body);return {ok:true};}});
  for(const [name,args] of [
    ['basegrid_list_flashing_profiles',{}],
    ['basegrid_save_flashing_profile',{name:'Flat',previous_name:'Old',settings:{lengths_mm:[100],angles_deg:[],material_id:'stock'}}],
    ['basegrid_delete_flashing_profile',{name:'Flat'}]
  ]){
    assert.ok(TOOLS.find(t=>t.name===name));
    const result=await dispatch(request('tools/call',{name,arguments:args}));
    assert.equal(result.result.isError,false);
    assert.deepEqual(calls.at(-1),{name,arguments:args});
  }
});

test('recent drawing endpoints are discoverable and relayed intact', async () => {
  const names = ['basegrid_create_strip_footing', 'basegrid_create_starter_bars', 'basegrid_create_step_z_bars',
    'basegrid_create_concrete_pier', 'basegrid_create_flashing', 'basegrid_create_structural_steel'];
  const calls = [];
  const dispatch = createDispatcher({ requestBridge: async (path, body) => { calls.push({ path, body }); return { ok: true }; } });
  for (const name of names) {
    assert.ok(TOOLS.find(t => t.name === name)?.inputSchema.required.includes('model_guid'));
    const args = { model_guid: 'model', points_mm: [[0,0,0],[1000,0,0]], settings: { bar_material: 'bar' } };
    const result = await dispatch(request('tools/call', { name, arguments: args }));
    assert.equal(result.result.isError, false);
    assert.deepEqual(calls.at(-1), { path: '/basegrid/call', body: { name, arguments: args } });
  }
});

test('standalone discovery provides native geometry and Basegrid tools without a bridge', async () => {
  const dispatch = createDispatcher({ requestBridge: async () => { throw new Error('discovery must work offline'); } });
  const response = await dispatch(request('tools/list'));
  assert.equal(response.result.tools.length, TOOLS.length);
  assert.ok(response.result.tools.some(tool => tool.name === 'basegrid_create_slab'));
  assert.ok(response.result.tools.some(tool => tool.name === 'basegrid_batch'));
  const init = await dispatch(request('initialize', { protocolVersion: '2025-06-18' }));
  assert.equal(init.result.serverInfo.name, 'basegrid');
  assert.equal(init.result.protocolVersion, '2025-06-18');
  assert.match(init.result.instructions, /footprint/);
});

test('native face references pass into the actual Basegrid slab command', async () => {
  const calls = [];
  const dispatch = createDispatcher({ requestBridge: async (path, body) => {
    calls.push({ path, body });
    return body.name === 'basegrid_batch'
      ? { ok: true, result: [{ id: 'face', result: { $ref: 'bg_test_1' } }] }
      : { ok: true, result: { entity: { $ref: 'bg_test_2' }, takeoff: { quantity: 3.6 } } };
  }});
  const footprint = await dispatch(request('tools/call', { name: 'basegrid_batch', arguments: { model_guid: 'm1', calls: [] } }));
  const face = JSON.parse(footprint.result.content[0].text).result[0].result.$ref;
  const args = { model_guid: 'm1', face_ref: face, thickness_mm: 150, material_id: 'n25', takeoff_group_id: 'slabs' };
  const slab = await dispatch(request('tools/call', { name: 'basegrid_create_slab', arguments: args }));
  assert.equal(slab.result.isError, false);
  assert.deepEqual(calls[1], { path: '/basegrid/call', body: { name: 'basegrid_create_slab', arguments: args } });
  assert.equal(JSON.parse(slab.result.content[0].text).result.takeoff.quantity, 3.6);
});

test('captures become MCP images with concise accompanying text', async () => {
  const dispatch = createDispatcher({ requestBridge: async () => ({ ok: true, result: { width: 1200, height: 800, image: { data: 'cG5n', mimeType: 'image/png' } } }) });
  const response = await dispatch(request('tools/call', { name: 'basegrid_capture_view' }));
  assert.equal(response.result.content[1].type, 'image');
  assert.equal(response.result.content[1].data, 'cG5n');
  assert.match(response.result.content[0].text, /PNG attached/);
});

test('API errors and connection failures are MCP tool errors', async () => {
  const fail = createDispatcher({ requestBridge: async () => ({ ok: false, error: { code: 'INVALID_MATERIAL' } }) });
  assert.equal((await fail(request('tools/call', { name: 'basegrid_status' }))).result.isError, true);
  const disconnected = createDispatcher({ requestBridge: async () => { throw new Error('fetch failed', { cause: { code: 'ECONNREFUSED' } }); } });
  const response = await disconnected(request('tools/call', { name: 'basegrid_status' }));
  assert.equal(response.result.isError, true);
  assert.match(response.result.content[0].text, /Start SketchUp/);
});

test('remote addresses are refused before sending the local token', async () => {
  const previous = process.env.BASEGRID_API_URL;
  try {
    process.env.BASEGRID_API_URL = 'https://example.com';
    const dispatch = createDispatcher({ requestBridge: async () => { throw new Error('must not connect'); } });
    const result = await dispatch(request('tools/call', { name: 'basegrid_model' }));
    assert.match(result.result.content[0].text, /loopback/);
  } finally {
    if (previous === undefined) delete process.env.BASEGRID_API_URL;
    else process.env.BASEGRID_API_URL = previous;
  }
});

test('invalid JSON-RPC, unknown methods and notifications behave correctly', async () => {
  const dispatch = createDispatcher();
  assert.equal((await dispatch(null)).error.code, -32600);
  assert.equal(await dispatch({ jsonrpc: '2.0', method: 'notifications/initialized' }), null);
  assert.deepEqual((await dispatch(request('ping'))).result, {});
  assert.equal((await dispatch(request('missing'))).error.code, -32601);
  assert.equal((await dispatch(request('tools/call', { name: 'missing' }))).result.isError, true);
});

test('real standalone stdio transport starts and lists tools', async () => {
  const child = spawn(process.execPath, [fileURLToPath(new URL('../mcp/server.mjs', import.meta.url))], { stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env } });
  let output = '';
  let errors = '';
  child.stdout.on('data', data => { output += data; });
  child.stderr.on('data', data => { errors += data; });
  child.stdin.end('invalid\n' + JSON.stringify(request('initialize')) + '\n' + JSON.stringify(request('tools/list', {}, 2)) + '\n');
  const code = await new Promise((resolve, reject) => { child.on('error', reject); child.on('close', resolve); });
  assert.equal(code, 0, errors);
  const replies = output.trim().split('\n').map(JSON.parse);
  assert.equal(replies[0].error.code, -32700);
  assert.equal(replies[1].result.serverInfo.name, 'basegrid');
  assert.equal(replies[2].result.tools.length, TOOLS.length);
});
