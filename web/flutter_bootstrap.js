{{flutter_js}}
{{flutter_build_config}}

(() => {
  const reportFailure = (error) => {
    window.lumenStartup?.fail();
    console.error('Portfolio startup failed', error);
  };
  try {
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
  } catch (error) {
    reportFailure(error);
  }
})();
