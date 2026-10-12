// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/theme_notifier.dart';
import 'package:tictactoe/ui/board_widget.dart';
import 'package:tictactoe/ui/game_screen.dart';
import 'package:tictactoe/ui/kofi_button.dart';
import 'package:tictactoe/ui/session_bar_widget.dart';

// The web build runs GameScreen in embed mode inside an iframe on
// appversegames.com. These tests drive embed mode on the VM.

const _sizes = [
  Size(320, 568),
  Size(360, 640),
  Size(390, 844),
  Size(600, 700),
  Size(700, 700),
  Size(768, 700),
  Size(900, 700),
  Size(1024, 700),
  Size(1100, 700),
  Size(1280, 700),
  Size(1024, 500),
  Size(844, 390),
  // Shortest mobile height the game must fit.
  Size(320, 560),
];

Future<void> _pumpEmbed(WidgetTester tester, Size size,
    {ThemeData? theme}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(MaterialApp(
    theme: theme ?? ThemeData.light(),
    home: const GameScreen(embedMode: true),
  ));
  await tester.pumpAndSettle();
}

Finder _cell(int index) => find.byKey(ValueKey('cell_$index'));

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    themeNotifier.value = ThemeMode.light;
  });

  group('embed layout fits the iframe', () {
    for (final size in _sizes) {
      testWidgets('${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
        await _pumpEmbed(tester, size);

        expect(tester.takeException(), isNull);
        expect(find.byType(Scrollable), findsNothing,
            reason: 'nothing may scroll inside the iframe');

        final board = tester.getRect(find.byType(BoardWidget));
        expect(board.left, greaterThanOrEqualTo(0));
        expect(board.top, greaterThanOrEqualTo(0));
        expect(board.right, lessThanOrEqualTo(size.width));
        expect(board.bottom, lessThanOrEqualTo(size.height));

        final minBoard = min(size.width, size.height) >= 600 ? 400.0 : 280.0;
        expect(board.width, greaterThanOrEqualTo(minBoard),
            reason: 'board is ${board.width}px');

        // Every control is fully inside the view.
        for (final text in ['New Game', 'vs AI', 'vs Human', 'Hard']) {
          final r = tester.getRect(find.text(text));
          expect(r.left >= 0 && r.top >= 0, isTrue, reason: text);
          expect(r.right <= size.width && r.bottom <= size.height, isTrue,
              reason: text);
        }
      });
    }
  });

  group('embed mode shows only the game', () {
    testWidgets('no app bar, store links, Ko-fi, hint or session bar',
        (tester) async {
      await _pumpEmbed(tester, const Size(390, 844));
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(KoFiButton), findsNothing);
      expect(find.byType(SessionBarWidget), findsNothing);
      expect(find.text('More Games'), findsNothing);
      expect(find.byTooltip('Privacy Policy'), findsNothing);
      expect(find.text('Watch ad for hint'), findsNothing);
    });

    testWidgets('wide layout hides them too', (tester) async {
      await _pumpEmbed(tester, const Size(1280, 700));
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(KoFiButton), findsNothing);
      expect(find.text('More Games'), findsNothing);
      expect(find.text('Watch ad for hint'), findsNothing);
    });

    testWidgets('theme toggle is in the game controls', (tester) async {
      await _pumpEmbed(tester, const Size(390, 844));
      await tester.tap(find.byTooltip('Switch to dark mode'));
      await tester.pumpAndSettle();
      expect(themeNotifier.value, ThemeMode.dark);
    });

    testWidgets('vs Human keeps the board size and shows a note',
        (tester) async {
      await _pumpEmbed(tester, const Size(360, 640));
      final before = tester.getRect(find.byType(BoardWidget));
      await tester.tap(find.text('vs Human'));
      await tester.pumpAndSettle();
      expect(find.text('Two players, one device'), findsOneWidget);
      expect(tester.getRect(find.byType(BoardWidget)), before);
    });

    testWidgets('play, win and start a new game', (tester) async {
      await _pumpEmbed(tester, const Size(360, 640));
      await tester.tap(find.text('vs Human'));
      await tester.pumpAndSettle();
      for (final c in [0, 3, 1, 4, 2]) {
        await tester.tap(_cell(c));
        await tester.pump();
      }
      expect(find.text('X wins!'), findsOneWidget);
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();
      expect(find.text("X's turn"), findsOneWidget);
    });

    testWidgets('session timer does not run in embed mode', (tester) async {
      await _pumpEmbed(tester, const Size(390, 844));
      await tester.pump(const Duration(minutes: 61));
      expect(find.text('Time for a break!'), findsNothing);
    });
  });
}
