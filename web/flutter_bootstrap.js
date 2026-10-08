{{flutter_js}}
{{flutter_build_config}}

(() => {
  const fallback = document.getElementById('portfolio-fallback');
  const status = document.getElementById('startup-status');
  let firstFrameRendered = false;
  const setStatus = (message) => {
    if (status) status.textContent = message;
  };
  const loadingTimer = window.setTimeout(() => {
    if (!firstFrameRendered) {
      setStatus('The interactive view is taking longer than expected. You can keep browsing this overview while it loads, or reload to try again.');
    }
  }, 15000);

  const reportFailure = (error) => {
    if (firstFrameRendered) return;
    window.clearTimeout(loadingTimer);
    setStatus('The interactive view could not load. The overview and contact links still work; reload to try again.');
    console.error('Portfolio startup failed', error);
  };
  const onScriptError = (event) => {
    const target = event.target;
    if (target && target.tagName === 'SCRIPT' && /\/main\.dart\.js(?:[?#]|$)/.test(target.src || '')) {
      reportFailure('The application script could not be downloaded.');
    }
  };
  window.addEventListener('error', onScriptError, true);
  window.addEventListener('flutter-first-frame', () => {
    firstFrameRendered = true;
    window.clearTimeout(loadingTimer);
    window.removeEventListener('error', onScriptError, true);
    if (fallback) fallback.hidden = true;
  }, {once: true});

  _flutter.loader.load({
    onEntrypointLoaded: async function (engineInitializer) {
      try {
        const appRunner = await engineInitializer.initializeEngine();
        await appRunner.runApp();
      } catch (error) {
        reportFailure(error);
      }
    }
  }).catch(reportFailure);
})();
