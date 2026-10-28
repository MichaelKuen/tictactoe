// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/game/game_setup.dart';
import 'package:tictactoe/game/player.dart';
import 'package:tictactoe/game/session_timer.dart';
import 'package:tictactoe/main.dart';
import 'package:tictactoe/screens/game_host.dart';
import 'package:tictactoe/screens/watch_page.dart';
import 'package:tictactoe/widgets/cell_widget.dart';

import 'test_helpers.dart';

/// Counts finished games and grants every rewarded ad.
class FakeAds extends NoAdsService {
  int gamesEnded = 0;
  int rewardedShown = 0;

  @override
  bool get isSupported => true;

  @override
  bool get rewardedReady => true;

  @override
  Future<void> onGameEnded() async => gamesEnded++;

  @override
  Future<bool> showRewarded() async {
    rewardedShown++;
    return true;
  }
}

CoreKit _kit({AdsService? ads}) => CoreKit(
  config: ticTacToeConfig,
  settings: SettingsController(gameId: 'tictactoe'),
  ads: ads ?? NoAdsService(),
  purchases: NoPurchasesService(),
  analytics: NoAnalytics(),
);

Future<void> _pumpApp(
  WidgetTester tester, {
  CoreKit? kit,
  GameSetup setup = const GameSetup(),
  SessionTimer? timer,
}) async {
  await tester.pumpWidget(
    TicTacToeApp(kit: kit ?? _kit(), setup: setup, sessionTimer: timer),
  );
  await tester.pumpAndSettle();
}

/// Lets the computer answer.
Future<void> _computer(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

Player? _mark(WidgetTester tester, int index) =>
    tester.widget<CellWidget>(cell(index)).player;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => debugWebBuildOverride = null);

  group('mobile app', () {
    testWidgets('opens on the home page with every option', (tester) async {
      setWindow(tester, 390, 844);
      await _pumpApp(tester);
      expect(find.text('Tic Tac Toe'), findsOneWidget);
      for (final key in [
        'playComputer',
        'playTwo',
        'watch',
        'howToPlay',
        'moreGames',
        'settings',
        'kofi',
      ]) {
        expect(find.byKey(Key(key)), findsOneWidget, reason: key);
      }
    });

    testWidgets('vs Computer: app bar, play-time bar, and the computer '
        'answers', (tester) async {
      setWindow(tester, 390, 844);
      final timer = SessionTimer();
      addTearDown(timer.dispose);
      await _pumpApp(tester, timer: timer);
      await tester.tap(find.byKey(const Key('playComputer')));
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byTooltip('How to play'), findsOneWidget);
      expect(find.byTooltip('More Games'), findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);
      expect(find.byKey(const Key('sessionBar')), findsOneWidget);
      expect(find.byKey(const Key('themeToggle')), findsNothing);
      expect(find.byKey(const Key('demo')), findsNothing);
      expect(statusOf(tester), 'Your turn (X)');

      await tapCell(tester, 0);
      expect(statusOf(tester), 'Computer is thinking…');
      await _computer(tester);
      expect(_mark(tester, 4), Player.o);
      expect(statusOf(tester), 'Your turn (X)');
    });

    testWidgets('More Games and Settings open', (tester) async {
      setWindow(tester, 390, 844);
      await _pumpApp(tester);
      await tester.ensureVisible(find.byKey(const Key('moreGames')));
      await tester.tap(find.byKey(const Key('moreGames')));
      await tester.pumpAndSettle();
      expect(find.text('App Verse Games'), findsWidgets);
      expect(find.byKey(const Key('allGames')), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('settings')));
      await tester.tap(find.byKey(const Key('settings')));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Privacy policy'), findsOneWidget);
    });

    testWidgets('Watch and Learn plays a commented game', (tester) async {
      setWindow(tester, 390, 844);
      await _pumpApp(tester);
      await tester.tap(find.byKey(const Key('watch')));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.byType(WatchPage), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Move 1 · X'), findsOneWidget);
      expect(find.textContaining('Why: '), findsOneWidget);
      await tester.tap(find.byKey(const Key('playPause')));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('web build', () {
    setUp(() => debugWebBuildOverride = true);

    testWidgets('opens straight into play with only the game', (tester) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(tester);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byKey(const Key('kofi')), findsNothing);
      expect(find.byKey(const Key('hint')), findsNothing);
      expect(find.byKey(const Key('sessionBar')), findsNothing);
      expect(find.byTooltip('More Games'), findsNothing);
      expect(find.byKey(const Key('board')), findsOneWidget);
      expect(statusOf(tester), 'Your turn (X)');
    });

    testWidgets('starts light and the toggle switches to dark', (tester) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(tester);
      BuildContext ctx() => tester.element(find.byKey(const Key('board')));
      expect(Theme.of(ctx()).brightness, Brightness.light);
      await tester.tap(find.byKey(const Key('themeToggle')));
      await tester.pumpAndSettle();
      expect(Theme.of(ctx()).brightness, Brightness.dark);
    });

    testWidgets('rules open in a dialog', (tester) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(tester);
      await tester.tap(find.byKey(const Key('rules')));
      await tester.pumpAndSettle();
      expect(find.text('How to play'), findsOneWidget);
      expect(find.text('Taking turns'), findsOneWidget);
    });

    testWidgets('the demo button opens Watch and Learn and back', (
      tester,
    ) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(tester);
      await tester.tap(find.byKey(const Key('demo')));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.byType(WatchPage), findsOneWidget);
      await tester.tap(find.byKey(const Key('playYourself')));
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.byType(WatchPage), findsNothing);
      expect(statusOf(tester), 'Your turn (X)');
    });

    testWidgets('options switch to 2 Players and are remembered', (
      tester,
    ) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(tester);
      await tester.tap(find.byKey(const Key('options')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2 Players'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('start')));
      await tester.pumpAndSettle();
      expect(statusOf(tester), "X's turn");
      await tapCell(tester, 0);
      expect(statusOf(tester), "O's turn");
      expect((await GameSetup.load()).mode, GameMode.twoPlayer);
    });

    testWidgets('computer moves first when chosen, and you play O', (
      tester,
    ) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(
        tester,
        setup: const GameSetup(firstMove: FirstMove.computer),
      );
      expect(statusOf(tester), 'Computer is thinking…');
      await _computer(tester);
      expect(statusOf(tester), 'Your turn (O)');
    });
  });

  group('keyboard', () {
    const twoPlayer = GameSetup(mode: GameMode.twoPlayer);
    setUp(() => debugWebBuildOverride = true);

    Future<void> key(WidgetTester tester, LogicalKeyboardKey k) async {
      await tester.sendKeyEvent(k);
      await tester.pump();
    }

    testWidgets('digit keys play in reading order', (tester) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(tester, setup: twoPlayer);
      await key(tester, LogicalKeyboardKey.digit1);
      await key(tester, LogicalKeyboardKey.digit9);
      expect(_mark(tester, 0), Player.x);
      expect(_mark(tester, 8), Player.o);
    });

    testWidgets('the numpad follows its physical layout', (tester) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(tester, setup: twoPlayer);
      await key(tester, LogicalKeyboardKey.numpad7);
      await key(tester, LogicalKeyboardKey.numpad3);
      expect(_mark(tester, 0), Player.x);
      expect(_mark(tester, 8), Player.o);
    });

    testWidgets('the first arrow selects the centre and Enter plays', (
      tester,
    ) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(tester, setup: twoPlayer);
      await key(tester, LogicalKeyboardKey.arrowLeft);
      await key(tester, LogicalKeyboardKey.enter);
      expect(_mark(tester, 4), Player.x);
      await key(tester, LogicalKeyboardKey.arrowUp);
      await key(tester, LogicalKeyboardKey.space);
      expect(_mark(tester, 1), Player.o);
    });

    testWidgets('N starts a new game', (tester) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(tester, setup: twoPlayer);
      await key(tester, LogicalKeyboardKey.digit5);
      await key(tester, LogicalKeyboardKey.keyN);
      await tester.pumpAndSettle();
      expect(_mark(tester, 4), isNull);
    });

    testWidgets('keys are ignored while a dialog is open', (tester) async {
      setWindow(tester, 1024, 700);
      await _pumpApp(tester, setup: twoPlayer);
      await tester.tap(find.byKey(const Key('options')));
      await tester.pumpAndSettle();
      await key(tester, LogicalKeyboardKey.digit5);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(_mark(tester, 4), isNull);
    });
  });

  group('ads (Android app)', () {
    testWidgets('each finished game is reported for interstitials', (
      tester,
    ) async {
      setWindow(tester, 390, 844);
      final ads = FakeAds();
      await tester.pumpWidget(
        MaterialApp(
          home: GameHost(
            kit: _kit(ads: ads),
            setup: const GameSetup(mode: GameMode.twoPlayer),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final i in [0, 3, 1, 4, 2]) {
        await tapCell(tester, i);
      }
      expect(statusOf(tester), 'X wins!');
      expect(ads.gamesEnded, 1);
    });

    testWidgets('the hint plays a rewarded ad, then shows the best square', (
      tester,
    ) async {
      setWindow(tester, 390, 844);
      final ads = FakeAds();
      await tester.pumpWidget(
        MaterialApp(
          home: GameHost(
            kit: _kit(ads: ads),
            setup: const GameSetup(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hint')));
      await tester.pump();
      expect(ads.rewardedShown, 1);
      expect(
        find.byWidgetPredicate((w) => w is CellWidget && w.hinted),
        findsOneWidget,
      );
    });
  });
}
