// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'ui/game_screen.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFF5252),     // X — vivid red
          onPrimary: Colors.white,
          secondary: const Color(0xFF40C4FF),   // O — vivid sky blue
          onSecondary: const Color(0xFF002233),
          surface: const Color(0xFF1A1A2E),
          onSurface: const Color(0xFFE0E0E0),
          outline: const Color(0xFF5A5A7A),
          inversePrimary: const Color(0xFF2A2A4A),
        ),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
