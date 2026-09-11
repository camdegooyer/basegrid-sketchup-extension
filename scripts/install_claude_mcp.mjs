#!/usr/bin/env node
// Merge just the Basegrid entry; preserve other Claude Desktop settings.
import { existsSync, readFileSync, writeFileSync, copyFileSync, mkdirSync, renameSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

if (process.argv.slice(2).some(arg => arg !== '--dry-run')) {
  throw new Error('Usage: node scripts/install_claude_mcp.mjs [--dry-run]');
}
const configPath = process.platform === 'win32'
  ? join(process.env.APPDATA, 'Claude', 'claude_desktop_config.json')
  : join(homedir(), 'Library', 'Application Support', 'Claude', 'claude_desktop_config.json');
const entry = {
  command: process.execPath,
  args: [fileURLToPath(new URL('../mcp/server.mjs', import.meta.url))],
  env: { BASEGRID_API_URL: 'http://127.0.0.1:9878' }
};
const config = existsSync(configPath) ? JSON.parse(readFileSync(configPath, 'utf8').replace(/^\uFEFF/, '')) : {};
if (!config || typeof config !== 'object' || Array.isArray(config)) throw new Error('Claude Desktop config must be an object.');
if (config.mcpServers != null && (typeof config.mcpServers !== 'object' || Array.isArray(config.mcpServers))) {
  throw new Error('Claude Desktop mcpServers must be an object.');
}
if (process.argv.includes('--dry-run')) {
  console.log(JSON.stringify({ configPath, entry: { basegrid: entry } }, null, 2));
} else {
  config.mcpServers = { ...(config.mcpServers || {}), basegrid: entry };
  mkdirSync(dirname(configPath), { recursive: true });
  const backup = `${configPath}.basegrid-backup-${Date.now()}`;
  if (existsSync(configPath)) copyFileSync(configPath, backup);
  const temporary = `${configPath}.basegrid-${process.pid}.tmp`;
  writeFileSync(temporary, JSON.stringify(config, null, 2) + '\n', { flag: 'wx' });
  renameSync(temporary, configPath);
  console.log(`Installed Basegrid MCP in ${configPath}`);
  if (existsSync(backup)) console.log(`Previous settings backed up to ${backup}`);
}
