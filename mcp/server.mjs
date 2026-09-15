#!/usr/bin/env node
// Basegrid's standalone MCP server. Node 18+, no external packages.
import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import readline from 'node:readline';

export const TOOLS = JSON.parse(readFileSync(new URL('../config/basegrid_api_tools.json', import.meta.url), 'utf8'));
const NAMES = new Set(TOOLS.map(tool => tool.name));
const VERSIONS = ['2025-11-25', '2025-06-18', '2025-03-26', '2024-11-05'];
const INSTRUCTIONS = `Basegrid connects to the live SketchUp model and its own construction tools.
Call basegrid_status and basegrid_model first. Read basegrid_native_api to discover native classes and methods.
Use basegrid_invoke or basegrid_batch for ordinary geometry such as edges, faces, groups and transformations.
Native targets are {"$root":"active_model"}, {"$ref":"bg_..."} or {"$result":"earlier-call-id"} (batch only).
Typed points: {"$type":"Point3d","x":6000,"y":0,"z":0,"unit":"mm"}; lengths: {"$type":"Length","value":150,"unit":"mm"}.
Returned points and lengths are millimetres. Plain numeric API results use SketchUp internal inches, square inches or cubic inches.
To create a slab, draw the footprint in active_entities through basegrid_batch, then pass the resulting face's $ref as face_ref to basegrid_create_slab.
Always use the Basegrid slab tool for Basegrid slabs: it writes material IDs, tags and takeoff. Read basegrid_list_materials for real eligible IDs.
Use model_guid from basegrid_status for edits. Every geometry batch and slab creation has its own Undo operation.
Extension 0.3.5+ supports flat flashing, settings.material_id overrides, and named flashing profiles. List/save/delete flashing profiles target SketchUp preferences, not geometry; profile_name supplies defaults for create_flashing and explicit settings override them.
Verify with basegrid_takeoff and basegrid_capture_view. Takeoff is stored at creation and does not recalculate after manual/native edits.
Extension 0.3.2+ implements slabs, strip footings, starter bars/pins, Step Z bars, concrete piers, flashing and structural steel members. The catalogue identifies planned tools as definition_only and returns full schemas for implemented tools.
Use basegrid_list_materials with concrete_only=false for non-slab materials and their dimensions. New create tools accept replace_ref with complete geometry/settings to replace a same-tool group in the active context. All drawing commands require model_guid.
Use basegrid_create_strip_footing for connected X/Y paths with optional mesh, support blocks and paired-bar spacers. Repeated parts use component instances; reinforcement connections are not detailed.
If materials are disconnected, the user connects in Extensions > Basegrid > Materials > Connect.
Methods needing more permission must be enabled by the user in Extensions > Basegrid > MCP API > Permissions.
After an execution timeout, inspect the model before retrying a write.`;

function localBaseURL() {
  const url = new URL(process.env.BASEGRID_API_URL || 'http://127.0.0.1:9878');
  if (url.protocol !== 'http:' || !['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname) ||
      url.username || url.password || url.pathname !== '/' || url.search || url.hash) {
    throw new Error('BASEGRID_API_URL must be a local loopback HTTP address, e.g. http://127.0.0.1:9878.');
  }
  return url.origin;
}

function dataDirectory() {
  if (process.env.LOCALAPPDATA) return join(process.env.LOCALAPPDATA, 'Basegrid');
  if (process.platform === 'darwin') return join(homedir(), 'Library', 'Application Support', 'Basegrid');
  return join(homedir(), '.basegrid');
}

async function bridge(path, body) {
  const base = localBaseURL();
  let token;
  try { token = readFileSync(join(dataDirectory(), 'mcp-token.txt'), 'utf8').trim(); }
  catch { throw new Error('Start SketchUp with Basegrid enabled to create its local MCP connection.'); }
  if (!/^[a-f0-9]{64}$/.test(token)) throw new Error('The Basegrid local API token is invalid.');
  const response = await fetch(base + path, {
    method: 'POST', redirect: 'error', signal: AbortSignal.timeout(120_000),
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: JSON.stringify(body)
  });
  if (response.status === 404) throw new Error('Basegrid API is not loaded. Restart SketchUp with Basegrid enabled.');
  if (response.status === 401) throw new Error('Basegrid rejected its local API token. Restart its MCP API.');
  const payload = await response.json();
  if (!response.ok && payload.ok !== false) throw new Error(`Basegrid returned HTTP ${response.status}.`);
  return payload;
}

const errorContent = message => ({ content: [{ type: 'text', text: message }], isError: true });

export function createDispatcher({ requestBridge = bridge } = {}) {
  return async function dispatch(request) {
    if (!request || typeof request !== 'object' || Array.isArray(request) || request.jsonrpc !== '2.0' || typeof request.method !== 'string') {
      return { jsonrpc: '2.0', id: request?.id ?? null, error: { code: -32600, message: 'Invalid Request' } };
    }
    const { id, method, params } = request;
    if (id === undefined) return null;
    const reply = result => ({ jsonrpc: '2.0', id, result });
    try {
      if (method === 'initialize') return reply({
        protocolVersion: VERSIONS.includes(params?.protocolVersion) ? params.protocolVersion : VERSIONS[0],
        capabilities: { tools: {} }, serverInfo: { name: 'basegrid', version: '0.3.5' }, instructions: INSTRUCTIONS
      });
      if (method === 'ping') return reply({});
      if (method === 'tools/list') return reply({ tools: TOOLS });
      if (method === 'tools/call') {
        if (!NAMES.has(params?.name)) return reply(errorContent('Unknown Basegrid tool. Call tools/list for available commands.'));
        localBaseURL();
        const payload = await requestBridge('/basegrid/call', { name: params.name, arguments: params.arguments ?? {} });
        const captured = params.name === 'basegrid_capture_view' && payload.ok ? payload.result?.image : null;
        const report = captured ? { ...payload, result: { ...payload.result, image: 'PNG attached' } } : payload;
        const content = [{ type: 'text', text: JSON.stringify(report) }];
        if (captured) content.push({ type: 'image', data: captured.data, mimeType: captured.mimeType });
        return reply({ content, isError: payload.ok === false });
      }
      return { jsonrpc: '2.0', id, error: { code: -32601, message: `Method not found: ${method}` } };
    } catch (error) {
      const message = error?.cause?.code === 'ECONNREFUSED'
        ? 'SketchUp is not reachable. Start SketchUp with Basegrid enabled, then retry.'
        : String(error?.message || error);
      return method === 'tools/call' ? reply(errorContent(message)) : { jsonrpc: '2.0', id, error: { code: -32603, message } };
    }
  };
}

export const dispatch = createDispatcher();

function main() {
  const lines = readline.createInterface({ input: process.stdin, terminal: false });
  let pending = Promise.resolve();
  lines.on('line', line => {
    if (!line.trim()) return;
    pending = pending.then(async () => {
      let request;
      try { request = JSON.parse(line); } catch {
        process.stdout.write(JSON.stringify({ jsonrpc: '2.0', id: null, error: { code: -32700, message: 'Parse error' } }) + '\n');
        return;
      }
      const response = await dispatch(request);
      if (response) process.stdout.write(JSON.stringify(response) + '\n');
    }).catch(error => process.stderr.write(`Basegrid MCP: ${error.message}\n`));
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) main();
