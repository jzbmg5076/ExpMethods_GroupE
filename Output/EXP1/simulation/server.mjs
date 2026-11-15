import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { dirname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = dirname(fileURLToPath(import.meta.url));
const types = { '.html': 'text/html', '.css': 'text/css', '.js': 'text/javascript', '.json': 'application/json' };
const port = Number(process.env.PORT || 5173);
createServer(async (req, res) => {
  try {
    const path = decodeURIComponent(new URL(req.url || '/', 'http://localhost').pathname);
    const relative = path === '/' ? 'index.html' : path.replace(/^[/\\]+/, '');
    const target = normalize(join(root, relative));
    if (!target.startsWith(root + '\\')) throw Error('Invalid path');
    const file = await readFile(target);
    const extension = target.slice(target.lastIndexOf('.'));
    res.writeHead(200, { 'Content-Type': types[extension] || 'application/octet-stream', 'Cache-Control': 'no-store' });
    res.end(file);
  } catch { res.writeHead(404); res.end('Not found'); }
}).listen(port, () => console.log(`Chain & Plate Lab: http://localhost:${port}`));
