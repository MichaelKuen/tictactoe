// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/foundation.dart';

import 'page_visibility_stub.dart'
    if (dart.library.js_interop) 'page_visibility_web.dart';

/// Whether the player can see the game. On web it turns false while the
/// browser tab is in the background, or while the site's full-screen game
/// layer (web/embed.js) is closed. Always true in the apps.
final ValueListenable<bool> pageVisible = createPageVisibility();
