// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:math';

import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/game/game_setup.dart';
import 'package:tictactoe/game/session_timer.dart';
import 'package:tictactoe/screens/game_page.dart';
import 'package:tictactoe/screens/watch_page.dart';
import 'package:tictactoe/widgets/game_chrome.dart';

import 'test_helpers.dart';

/// Iframe and phone sizes the game must fit without scrolling.
const sizes = [
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
];

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => debugWebBuildOverride = null);

  Future<void> check(
    WidgetTester tester,
    Size size,
    Widget page, {
    bool web = true,
    bool dark = false,
    double minPhoneBoard = 280,
  }) async {
    debugWebBuildOverride = web;
    setWindow(tester, size.width, size.height);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppverseTheme.light(),
        darkTheme: AppverseTheme.dark(),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: page,
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull, reason: 'no overflow at $size');
    // The Watch and Learn move log is the only thing allowed to scroll.
    expect(
      find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      ),
      findsNothing,
      reason: 'at $size',
    );
    final board = tester.getRect(find.byKey(const Key('board')));
    final screen = Offset.zero & size;
    expect(screen.intersect(board), board, reason: 'board visible at $size');
    final minBoard = min(size.width, size.height) >= 600 ? 400 : minPhoneBoard;
    expect(
      board.width,
      greaterThanOrEqualTo(minBoard),
      reason: 'board width ${board.width} at $size',
    );
  }

  final kit = CoreKit.forTesting(gameId: 'tictactoe');

  for (final size in sizes) {
    final label = '${size.width.toInt()}×${size.height.toInt()}';

    testWidgets('web game fits $label', (tester) async {
      await check(tester, size, GamePage(kit: kit, onNewGame: (_) {}));
      expect(find.byKey(const Key('newGame')), findsOneWidget);
      expect(find.byKey(const Key('themeToggle')), findsOneWidget);
      expect(find.byKey(const Key('demo')), findsOneWidget);
    });

    testWidgets('web game fits $label in dark mode', (tester) async {
      await check(
        tester,
        size,
        GamePage(kit: kit, onNewGame: (_) {}),
        dark: true,
      );
    });

    testWidgets('mobile game fits $label', (tester) async {
      final timer = SessionTimer();
      addTearDown(timer.dispose);
      await check(
        tester,
        size,
        GamePage(kit: kit, sessionTimer: timer, onNewGame: (_) {}),
        web: false,
        // The app bar and play-time bar take some height on phones.
        minPhoneBoard: 240,
      );
    });

    testWidgets('Watch and Learn fits $label', (tester) async {
      await check(
        tester,
        size,
        WatchPage(
          kit: kit,
          setup: const GameSetup(mode: GameMode.watch),
          onNewGame: (_) {},
          autoStart: false,
        ),
      );
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('the New Game dialog fits a small phone', (tester) async {
    setWindow(tester, 320, 568);
    await tester.pumpWidget(
      MaterialApp(
        home: GamePage(kit: kit, onNewGame: (_) {}),
      ),
    );
    await tester.tap(find.byKey(const Key('options')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final start = tester.getRect(find.byKey(const Key('start')));
    expect(start.bottom, lessThanOrEqualTo(568));
  });

  test('the privacy note matches what is stored', () {
    expect(privacyText, contains('saved only on this device'));
    expect(privacyText, contains('your scores'));
    expect(privacyText, contains('local storage on the web'));
    expect(privacyText, contains('Signing in with Google'));
    expect(privacyText, contains('ads from Google AdMob'));
    expect(privacyText, contains('Ad privacy choices'));
  });
}
