// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Global theme-mode notifier. Toggle from anywhere in the widget tree.
///
/// Web starts light so the game blends into the ivory host page; mobile
/// starts dark as before.
final themeNotifier =
    ValueNotifier<ThemeMode>(kIsWeb ? ThemeMode.light : ThemeMode.dark);
