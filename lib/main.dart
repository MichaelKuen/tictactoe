// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'ads/ad_manager.dart';
import 'theme_notifier.dart';
import 'ui/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdManager.instance.initialize();
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, child) => MaterialApp(
        title: 'Tic Tac Toe',
        themeMode: mode,
        theme: _lightTheme,
        darkTheme: _darkTheme,
        home: const GameScreen(),
      ),
    );
  }
}

final _lightTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: const Color(0xFFD32F2F),
    onPrimary: Colors.white,
    secondary: const Color(0xFF1565C0),
    onSecondary: Colors.white,
    surface: const Color(0xFFF5F5F5),
    onSurface: const Color(0xFF1A1A1A),
    outline: const Color(0xFFBDBDBD),
    inversePrimary: const Color(0xFFEEEEEE),
  ),
  useMaterial3: true,
);

final _darkTheme = ThemeData(
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFFFF5252),
    onPrimary: Colors.white,
    secondary: const Color(0xFF40C4FF),
    onSecondary: const Color(0xFF002233),
    surface: const Color(0xFF1A1A2E),
    onSurface: const Color(0xFFE0E0E0),
    outline: const Color(0xFF5A5A7A),
    inversePrimary: const Color(0xFF2A2A4A),
  ),
  useMaterial3: true,
);
