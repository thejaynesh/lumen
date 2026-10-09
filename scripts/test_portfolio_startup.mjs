import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';
import vm from 'node:vm';

const source = await readFile(new URL('../web/portfolio_startup.js', import.meta.url), 'utf8');
const html = await readFile(new URL('../web/index.html', import.meta.url), 'utf8');
const bootstrap = (await readFile(new URL('../web/flutter_bootstrap.js', import.meta.url), 'utf8'))
  .replace(/\{\{flutter_(?:js|build_config)\}\}/g, '');

function harness({ bodyParsed = true } = {}) {
  const events = new Map();
  const timers = new Map();
  const root = { dataset: {} };
  const status = { textContent: 'Portfolio overview and contact links.' };
  let parsed = bodyParsed;
  const window = {
    setTimeout(callback) { timers.set(1, callback); return 1; },
    clearTimeout(id) { timers.delete(id); },
    addEventListener(name, callback) { events.set(name, callback); },
    removeEventListener(name) { events.delete(name); },
  };
  const document = {
    documentElement: root,
    getElementById() { return parsed ? status : null; },
    addEventListener(name, callback) { events.set(name, callback); },
  };
  const context = vm.createContext({ window, document, console: { error() {} } });
  vm.runInContext(source, context);
  return {
    context, window, root, status, timers,
    emit(name, value = {}) { events.get(name)?.(value); },
    parseBody() { parsed = true; events.get('DOMContentLoaded')?.(); },
    timeout() { timers.get(1)?.(); },
  };
}

test('hides the overview before parsing the body; no-JS visitors retain the overview', () => {
  const head = html.slice(0, html.indexOf('</head>'));
  assert.match(head, /<script src="portfolio_startup\.js"><\/script>/);
  assert.match(html, /<main id="portfolio-fallback">/);
  assert.match(html, /html\[data-portfolio-state="loading"\] #portfolio-fallback/);
  assert.match(html, /#startup-shell\{display:none/);
  const run = harness({ bodyParsed: false });
  assert.equal(run.root.dataset.portfolioState, 'loading');
});

test('first Flutter frame removes the loader and prevents late fallback flashes', () => {
  const run = harness();
  run.emit('flutter-first-frame');
  assert.equal(run.root.dataset.portfolioState, 'ready');
  assert.equal(run.timers.size, 0);
  run.window.lumenStartup.fail();
  run.timeout();
  assert.equal(run.root.dataset.portfolioState, 'ready');
});

test('slow startup exposes the useful overview and can still recover', () => {
  const run = harness();
  run.timeout();
  assert.equal(run.root.dataset.portfolioState, 'fallback');
  assert.match(run.status.textContent, /taking longer/);
  run.emit('flutter-first-frame');
  assert.equal(run.root.dataset.portfolioState, 'ready');
});

test('bootstrap or app script download failure restores the overview', () => {
  for (const file of ['flutter_bootstrap.js', 'main.dart.js?v=2', 'firebase_emulator_bootstrap.js']) {
    const run = harness();
    run.emit('error', { target: { tagName: 'SCRIPT', src: `https://jaynesh.dev/${file}` } });
    assert.equal(run.root.dataset.portfolioState, 'fallback');
    assert.match(run.status.textContent, /could not load/);
    assert.equal(run.timers.size, 0);
  }
});

test('an early failure updates its message after the HTML is parsed', () => {
  const run = harness({ bodyParsed: false });
  run.window.lumenStartup.fail();
  run.parseBody();
  assert.equal(run.root.dataset.portfolioState, 'fallback');
  assert.match(run.status.textContent, /could not load/);
});

test('unrelated resource failures do not replace the loading screen', () => {
  const run = harness();
  run.emit('error', { target: { tagName: 'IMG', src: 'photo.png' } });
  run.emit('error', { filename: 'https://example.com/analytics.js' });
  assert.equal(run.root.dataset.portfolioState, 'loading');
});

test('synchronous and asynchronous Flutter loader failures expose the fallback', async () => {
  for (const synchronous of [true, false]) {
    const run = harness();
    run.context._flutter = { loader: { load() {
      if (synchronous) throw new Error('Loader unavailable');
      return Promise.reject(new Error('Download failed'));
    } } };
    vm.runInContext(bootstrap, run.context);
    await Promise.resolve();
    assert.equal(run.root.dataset.portfolioState, 'fallback');
  }
});

test('engine initialization failure restores the overview', async () => {
  const run = harness();
  let start;
  run.context._flutter = { loader: { load(options) {
    start = options.onEntrypointLoaded;
    return Promise.resolve();
  } } };
  vm.runInContext(bootstrap, run.context);
  await start({ async initializeEngine() { throw new Error('Renderer unavailable'); } });
  assert.equal(run.root.dataset.portfolioState, 'fallback');
});
