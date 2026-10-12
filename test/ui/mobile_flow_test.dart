// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/main.dart';
import 'package:tictactoe/theme_notifier.dart';
import 'package:tictactoe/ui/game_screen.dart';
import 'package:tictactoe/ui/kofi_button.dart';
import 'package:tictactoe/ui/score_widget.dart';
import 'package:tictactoe/ui/session_bar_widget.dart';

// Pins the mobile (non-web) behaviour of the game screen so the web-embed
// refactor cannot change it. On the VM test runner kIsWeb is false.

Widget _wrap(Widget child) => MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: child,
    );

Finder _cell(int index) => find.byKey(ValueKey('cell_$index'));

Future<void> _setSize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpGame(WidgetTester tester) async {
  await tester.pumpWidget(_wrap(const GameScreen()));
  // Let ScoreRepository.create() resolve.
  await tester.pumpAndSettle();
}

Future<void> _play(WidgetTester tester, List<int> cells) async {
  for (final c in cells) {
    await tester.tap(_cell(c));
    await tester.pump();
  }
}

int _scoreValue(WidgetTester tester, String label) {
  final score = tester.widget<ScoreWidget>(find.byType(ScoreWidget)).score;
  return switch (label) {
    'x' => score.xWins,
    'o' => score.oWins,
    _ => score.draws,
  };
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    themeNotifier.value = ThemeMode.dark;
  });

  group('mobile chrome', () {
    testWidgets('app starts dark with app bar actions', (tester) async {
      await tester.pumpWidget(const TicTacToeApp());
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Tic Tac Toe'), findsOneWidget);
      expect(find.byTooltip('More Games'), findsOneWidget);
      expect(find.byTooltip('Privacy Policy'), findsOneWidget);
      expect(find.byTooltip('Switch to light mode'), findsOneWidget);
      expect(themeNotifier.value, ThemeMode.dark);
    });

    testWidgets('theme toggle switches to light mode', (tester) async {
      await tester.pumpWidget(const TicTacToeApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Switch to light mode'));
      await tester.pumpAndSettle();
      expect(themeNotifier.value, ThemeMode.light);
      expect(find.byTooltip('Switch to dark mode'), findsOneWidget);
    });

    testWidgets('session bar, Ko-fi and hint button are shown',
        (tester) async {
      await _setSize(tester, const Size(480, 900));
      await _pumpGame(tester);
      expect(find.byType(SessionBarWidget), findsOneWidget);
      expect(find.textContaining('played'), findsOneWidget);
      expect(find.byType(KoFiButton), findsOneWidget);
      expect(find.text('Watch ad for hint'), findsOneWidget);
    });

    testWidgets('narrow layout shows mode and difficulty segments',
        (tester) async {
      await _setSize(tester, const Size(480, 900));
      await _pumpGame(tester);
      expect(find.byType(SegmentedButton<bool>), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
    });

    testWidgets('wide layout shows More Games in the sidebar',
        (tester) async {
      await _setSize(tester, const Size(1280, 900));
      await _pumpGame(tester);
      expect(find.text('More Games'), findsOneWidget);
      expect(find.text('Game Mode'), findsOneWidget);
      expect(find.text('Difficulty'), findsOneWidget);
    });
  });

  group('game flow', () {
    testWidgets('draw shows Draw! and records a draw', (tester) async {
      await _setSize(tester, const Size(480, 900));
      await _pumpGame(tester);
      await tester.tap(find.text('vs Human'));
      await tester.pump();
      // X O X / X O O / O X X
      await _play(tester, [0, 1, 2, 4, 3, 5, 7, 6, 8]);
      expect(find.text('Draw!'), findsOneWidget);
      expect(_scoreValue(tester, 'd'), 1);
    });

    testWidgets('board ignores taps after the game is over', (tester) async {
      await _setSize(tester, const Size(480, 900));
      await _pumpGame(tester);
      await tester.tap(find.text('vs Human'));
      await tester.pump();
      await _play(tester, [0, 3, 1, 4, 2]);
      expect(find.text('X wins!'), findsOneWidget);
      await tester.tap(_cell(8));
      await tester.pump();
      expect(
          find.descendant(of: _cell(8), matching: find.text('O')), findsNothing);
    });

    testWidgets('changing difficulty starts a new game', (tester) async {
      await _setSize(tester, const Size(480, 900));
      await _pumpGame(tester);
      await tester.tap(_cell(4));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('X'), findsOneWidget);
      await tester.tap(find.text('Easy'));
      await tester.pump();
      expect(find.text('X'), findsNothing);
      expect(find.text("X's turn"), findsOneWidget);
    });

    testWidgets('hard AI answers a corner opening with the centre',
        (tester) async {
      await _setSize(tester, const Size(480, 900));
      await _pumpGame(tester);
      await tester.tap(_cell(0));
      await tester.pump();
      expect(find.text('AI is thinking…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(
          find.descendant(of: _cell(4), matching: find.text('O')), findsOneWidget);
      expect(find.text("X's turn"), findsOneWidget);
    });
  });

  group('scores', () {
    testWidgets('scores are kept per mode and persisted', (tester) async {
      await _setSize(tester, const Size(480, 900));
      await _pumpGame(tester);
      await tester.tap(find.text('vs Human'));
      await tester.pump();
      await _play(tester, [0, 3, 1, 4, 2]); // X wins
      expect(_scoreValue(tester, 'x'), 1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('score_hv_x'), 1);
      expect(prefs.getInt('score_ai_x'), isNull);

      await tester.tap(find.text('vs AI'));
      await tester.pump();
      expect(_scoreValue(tester, 'x'), 0);
    });

    testWidgets('stored scores load on start', (tester) async {
      SharedPreferences.setMockInitialValues(
          {'flutter.score_ai_x': 2, 'flutter.score_ai_o': 5, 'flutter.score_ai_d': 3});
      await _setSize(tester, const Size(480, 900));
      await _pumpGame(tester);
      expect(_scoreValue(tester, 'x'), 2);
      expect(_scoreValue(tester, 'o'), 5);
      expect(_scoreValue(tester, 'd'), 3);
    });

    testWidgets('reset icon clears all scores', (tester) async {
      SharedPreferences.setMockInitialValues({'flutter.score_ai_x': 2});
      await _setSize(tester, const Size(480, 900));
      await _pumpGame(tester);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      expect(_scoreValue(tester, 'x'), 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('score_ai_x'), isNull);
    });
  });
}
