// Runs synchronously in <head>, before the overview can be painted.
(() => {
  const root = document.documentElement;
  let ready = false;
  let fallbackMessage = '';
  root.dataset.portfolioState = 'loading';

  const updateStatus = () => {
    const status = document.getElementById('startup-status');
    if (status && fallbackMessage) status.textContent = fallbackMessage;
  };
  const showFallback = (message) => {
    if (ready) return;
    fallbackMessage = message;
    root.dataset.portfolioState = 'fallback';
    updateStatus();
  };
  const timer = window.setTimeout(() => {
    showFallback('The interactive view is taking longer than expected. The overview and contact links are available while it loads.');
  }, 15000);

  const fail = () => {
    if (ready) return;
    window.clearTimeout(timer);
    showFallback('The interactive view could not load. The overview and contact links still work; reload to try again.');
  };
  const onScriptError = (event) => {
    const scriptUrl = event.target?.tagName === 'SCRIPT'
      ? event.target.src : event.filename;
    if (/(?:^|\/)(?:flutter_bootstrap|firebase_emulator_bootstrap|main\.dart)\.js(?:[?#]|$)/.test(scriptUrl || '')) {
      fail();
    }
  };

  window.lumenStartup = { fail };
  window.addEventListener('error', onScriptError, true);
  document.addEventListener('DOMContentLoaded', updateStatus, { once: true });
  window.addEventListener('flutter-first-frame', () => {
    ready = true;
    window.clearTimeout(timer);
    window.removeEventListener('error', onScriptError, true);
    root.dataset.portfolioState = 'ready';
  }, { once: true });
})();
