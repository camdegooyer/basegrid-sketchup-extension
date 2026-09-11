// Build an installable, self-contained SketchUp RBZ using Node's standard library.
import { readFileSync, readdirSync, mkdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { deflateRawSync } from 'node:zlib';
const root = fileURLToPath(new URL('../', import.meta.url));
const entries = [['basegrid.rb', 'basegrid.rb']];
function collect(directory, prefix) {
  for (const entry of readdirSync(join(root, directory), { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
    if (entry.isDirectory()) collect(`${directory}/${entry.name}`, `${prefix}/${entry.name}`);
    else if (entry.isFile() && /\.(rb|png|svg)$/.test(entry.name)) entries.push([`${directory}/${entry.name}`, `${prefix}/${entry.name}`]);
  }
}
collect('basegrid', 'basegrid');
for (const path of ['config/basegrid_api_tools.json', 'config/sketchup_tool_definitions.json',
  'src/basegrid_ontology.rb', 'exports/ontology.json', 'exports/relationships.json', 'exports/materials.json']) {
  entries.push([path, `basegrid/${path}`]);
}
const crcTable = Array.from({ length: 256 }, (_, n) => {
  for (let i = 0; i < 8; i++) n = n & 1 ? 0xedb88320 ^ (n >>> 1) : n >>> 1;
  return n >>> 0;
});
function crc32(buffer) {
  let crc = 0xffffffff;
  for (const byte of buffer) crc = crcTable[(crc ^ byte) & 255] ^ (crc >>> 8);
  return (crc ^ 0xffffffff) >>> 0;
}
const local = [], central = [];
let offset = 0;
for (const [source, destination] of entries) {
  const name = Buffer.from(destination);
  const content = readFileSync(join(root, source));
  const compressed = deflateRawSync(content);
  const checksum = crc32(content);
  const header = Buffer.alloc(30);
  header.writeUInt32LE(0x04034b50, 0); header.writeUInt16LE(20, 4);
  header.writeUInt16LE(0x800, 6); header.writeUInt16LE(8, 8); header.writeUInt16LE(33, 12);
  header.writeUInt32LE(checksum, 14); header.writeUInt32LE(compressed.length, 18);
  header.writeUInt32LE(content.length, 22); header.writeUInt16LE(name.length, 26);
  local.push(header, name, compressed);
  const record = Buffer.alloc(46);
  record.writeUInt32LE(0x02014b50, 0); record.writeUInt16LE(20, 4); record.writeUInt16LE(20, 6);
  record.writeUInt16LE(0x800, 8); record.writeUInt16LE(8, 10); record.writeUInt16LE(33, 14);
  record.writeUInt32LE(checksum, 16); record.writeUInt32LE(compressed.length, 20);
  record.writeUInt32LE(content.length, 24); record.writeUInt16LE(name.length, 28); record.writeUInt32LE(offset, 42);
  central.push(record, name);
  offset += header.length + name.length + compressed.length;
}
const directory = Buffer.concat(central);
const end = Buffer.alloc(22);
end.writeUInt32LE(0x06054b50, 0); end.writeUInt16LE(entries.length, 8); end.writeUInt16LE(entries.length, 10);
end.writeUInt32LE(directory.length, 12); end.writeUInt32LE(offset, 16);
const version = /EXTENSION_VERSION = "([^"]+)"/.exec(readFileSync(join(root, 'basegrid.rb'), 'utf8'))[1];
mkdirSync(join(root, 'dist'), { recursive: true });
const destination = join(root, 'dist', `Basegrid-${version}.rbz`);
writeFileSync(destination, Buffer.concat([...local, directory, end]));
console.log(`Built ${destination} (${entries.length} files)`);
