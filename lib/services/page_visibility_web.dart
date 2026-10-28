// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

/// Listens to the tab's visibility and to `{avgEmbed: 'hide' | 'show'}`
/// messages that web/embed.js sends from the page around the game.
ValueListenable<bool> createPageVisibility() {
  var shown = true;
  final visible = ValueNotifier(!web.document.hidden);
  void update() => visible.value = shown && !web.document.hidden;

  web.document.addEventListener(
    'visibilitychange',
    ((web.Event _) => update()).toJS,
  );
  web.window.addEventListener(
    'message',
    ((web.MessageEvent event) {
      // Only the page that embeds the game, on the same site.
      if (event.origin != web.window.location.origin) return;
      final data = event.data.dartify();
      if (data is! Map) return;
      switch (data['avgEmbed']) {
        case 'hide':
          shown = false;
        case 'show':
          shown = true;
        default:
          return;
      }
      update();
    }).toJS,
  );
  return visible;
}
