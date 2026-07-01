// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';

/// Global theme-mode notifier. Toggle from anywhere in the widget tree.
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);
