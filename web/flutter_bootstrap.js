{{flutter_js}}
{{flutter_build_config}}

// Custom bootstrap: no (deprecated) service worker, and the loading spinner
// in index.html is removed once the game is running.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    const el = document.getElementById('loading');
    if (el) el.remove();
  },
});
