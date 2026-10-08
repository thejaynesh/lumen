/** Render the original SVG brand sources; never uses existing raster artwork.
 * Requires an existing Sharp installation, resolved normally or via NODE_PATH.
 * Usage: node scripts/render_brand.mjs [--output-dir path]
 */
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { createRequire } from 'node:module';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
if (args.length && (args.length !== 2 || args[0] !== '--output-dir')) {
  throw new Error('Usage: node scripts/render_brand.mjs [--output-dir path]');
}
const output = args.length ? resolve(args[1]) : join(root, 'web');
const cache = join(root, '.dart_tool', 'brand-render');
await mkdir(join(cache, 'font-cache'), { recursive: true });
const xml = value => value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('"', '&quot;');
const fontDirectory = join(root, 'assets', 'fonts').replaceAll('\\', '/');
const fontCache = join(cache, 'font-cache').replaceAll('\\', '/');
const fontConfig = join(cache, 'fonts.conf');
await writeFile(fontConfig, `<?xml version="1.0"?><fontconfig><dir>${xml(fontDirectory)}</dir><cachedir>${xml(fontCache)}</cachedir></fontconfig>`);
// Set before loading Sharp/librsvg so text uses the repository's licensed fonts.
process.env.FONTCONFIG_FILE = fontConfig;
const sharp = createRequire(import.meta.url)('sharp');
// Explicit registration also covers Windows Fontconfig builds that do not
// discover variable fonts from the directory configuration alone.
for (const [family, file] of [['Manrope', 'Manrope.ttf'], ['DM Serif Display', 'DMSerifDisplay-Regular.ttf'], ['DM Serif Display Italic', 'DMSerifDisplay-Italic.ttf']]) {
  await sharp({ text: { text: 'jb.', font: `${family} 12`, fontfile: join(root, 'assets', 'fonts', file) } })
    .png().toBuffer();
}
const favicon = await readFile(join(root, 'web', 'favicon.svg'), 'utf8');
const social = await readFile(join(root, 'web', 'social-preview.svg'), 'utf8');
const maskable = favicon.replace('<g ', '<g transform="translate(9 9) scale(.82)" ');
if (maskable === favicon) throw new Error('Expected the favicon monogram group.');
const derivatives = [
  ['favicon.png', favicon, 32, 32],
  ['icons/Icon-192.png', favicon, 192, 192],
  ['icons/Icon-512.png', favicon, 512, 512],
  ['icons/Icon-maskable-192.png', maskable, 192, 192],
  ['icons/Icon-maskable-512.png', maskable, 512, 512],
  ['social-preview.png', social, 1200, 630],
];
for (const [name, source, width, height] of derivatives) {
  const target = join(output, name);
  await mkdir(dirname(target), { recursive: true });
  const result = await sharp(Buffer.from(source), { density: 144 })
    .resize(width, height).png().toFile(target);
  if (result.width !== width || result.height !== height) {
    throw new Error(`Unexpected dimensions for ${name}: ${result.width}x${result.height}`);
  }
  console.log(`${name}: ${result.width}x${result.height}`);
}
