// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:math';

import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/game/game_setup.dart';
import 'package:tictactoe/screens/watch_page.dart';

import 'test_helpers.dart';

/// On web the game is told when the player can't see it (tab in the
/// background, or the site's full-screen layer closed). Tic Tac Toe has no
/// clock, so only Watch and Learn pauses.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget watch(ValueNotifier<bool> visible) => MaterialApp(
    home: WatchPage(
      kit: CoreKit.forTesting(gameId: 'tictactoe'),
      setup: const GameSetup(mode: GameMode.watch),
      onNewGame: (_) {},
      random: Random(2),
      visibility: visible,
    ),
  );

  String comment(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('commentText'))).data!;

  Future<void> leave(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('the demo pauses while hidden and carries on when shown', (
    tester,
  ) async {
    setWindow(tester, 390, 844);
    final visible = ValueNotifier(true);
    await tester.pumpWidget(watch(visible));
    await tester.pump();
    expect(find.byTooltip('Pause'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 10));

    visible.value = false;
    await tester.pump();
    expect(find.byTooltip('Play'), findsOneWidget);
    final hidden = comment(tester);
    await tester.pump(const Duration(seconds: 60));
    expect(comment(tester), hidden);

    visible.value = true;
    await tester.pump();
    expect(find.byTooltip('Pause'), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
    expect(comment(tester), isNot(hidden));
    await leave(tester);
  });

  testWidgets('a demo paused by the player stays paused when shown', (
    tester,
  ) async {
    setWindow(tester, 390, 844);
    final visible = ValueNotifier(true);
    await tester.pumpWidget(watch(visible));
    await tester.pump();
    await tester.tap(find.byKey(const Key('playPause')));
    await tester.pump();
    visible.value = false;
    await tester.pump();
    visible.value = true;
    await tester.pump();
    expect(find.byTooltip('Play'), findsOneWidget);
    await leave(tester);
  });

  testWidgets('a demo opened while hidden starts when shown', (tester) async {
    setWindow(tester, 390, 844);
    final visible = ValueNotifier(false);
    await tester.pumpWidget(watch(visible));
    await tester.pump();
    expect(find.byTooltip('Play'), findsOneWidget);

    visible.value = true;
    await tester.pump();
    expect(find.byTooltip('Pause'), findsOneWidget);
    await leave(tester);
  });
}
