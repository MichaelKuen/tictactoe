# Asset log

Source and licence for every art/audio asset shipped with Tic Tac Toe.

| Asset | Source | Licence |
|---|---|---|
| `assets/sounds/move_x.wav`, `move_o.wav`, `win.wav`, `lose.wav`, `draw.wav` | Synthesised by `tool/generate_sounds.py` (no samples used) | Own work, App Verse Games |
| App/web icons (`web/icons`, `web/favicon.png`, Android `mipmap-*`, iOS `AppIcon.appiconset`, Windows `app_icon.ico`) | Drawn by `tool/generate_icons.py` | Own work, App Verse Games |
| Splash logo (`assets/splash/splash_logo.png`) and the native splash images made from it | Drawn by `tool/generate_icons.py`, then `dart run flutter_native_splash:create` | Own work, App Verse Games |
| Board, marks and score panel | Painted in code (`lib/widgets/`) | Own work, App Verse Games |
| Fonts | None bundled; Material Icons and Cupertino Icons from the Flutter SDK, Roboto fallback from Flutter's web build | Apache-2.0 / MIT / Apache-2.0 |
