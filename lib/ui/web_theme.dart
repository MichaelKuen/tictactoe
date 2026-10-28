// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'board_colors.dart';

// Themes for the web build, matched to appversegames.com:
// ivory #F6F3EC background, navy #16193A headings, amber #F2A541 accent,
// teal #0B6B63 links. Mobile keeps its own themes in main.dart.

const _ivory = Color(0xFFF6F3EC);
const _navy = Color(0xFF16193A);
const _amber = Color(0xFFF2A541);
const _teal = Color(0xFF0B6B63);

final webLightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: _navy, // X
    onPrimary: Colors.white,
    secondary: _teal, // O
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF9DDB0), // selected segment (amber tint)
    onSecondaryContainer: _navy,
    surface: _ivory,
    onSurface: _navy,
    outline: Color(0xFFCFC7B5),
  ),
  scaffoldBackgroundColor: _ivory,
  useMaterial3: true,
  extensions: const [
    BoardColors(
      cell: Colors.white,
      highlight: _amber,
      highlightFill: Color(0x55F2A541),
      cursor: _amber,
    ),
  ],
);

final webDarkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    primary: _amber, // X
    onPrimary: _navy,
    secondary: Color(0xFF5FD4C4), // O (teal, lightened for contrast)
    onSecondary: _navy,
    secondaryContainer: Color(0xFF3B3F6B),
    onSecondaryContainer: _ivory,
    surface: _navy,
    onSurface: _ivory,
    outline: Color(0xFF3B3F6B),
  ),
  scaffoldBackgroundColor: _navy,
  useMaterial3: true,
  extensions: const [
    BoardColors(
      cell: Color(0xFF22264D),
      highlight: _amber,
      highlightFill: Color(0x44F2A541),
      cursor: _ivory,
    ),
  ],
);
