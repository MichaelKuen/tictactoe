// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';

import 'game/game_setup.dart';
import 'game/session_timer.dart';
import 'screens/game_host.dart';
import 'screens/game_page.dart';
import 'screens/home_page.dart';
import 'services/google_identity.dart';

const ticTacToeConfig = CoreKitConfig(
  gameId: 'tictactoe',
  gameName: 'Tic Tac Toe',
);

// Portfolio Pass: this game will be an App in the shared App Verse Games
// RevenueCat project (not created yet), using the `portfolio_pass`
// entitlement. Optional Sign in with Google gives purchases a stable player
// ID across games; the core kit only offers it in the Android/iOS app.
Future<void> main() async {
  final kit = await CoreKit.init(
    ticTacToeConfig,
    identity: GoogleIdentityService.new,
  );
  final setup = await GameSetup.load();
  // The play-time reminder is for the apps; the website has its own pages.
  final timer = isWebBuild ? null : (SessionTimer()..start());
  runApp(TicTacToeApp(kit: kit, setup: setup, sessionTimer: timer));
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({
    super.key,
    required this.kit,
    this.setup = const GameSetup(),
    this.sessionTimer,
  });

  final CoreKit kit;

  /// The last-used mode, levels and first-move choice.
  final GameSetup setup;
  final SessionTimer? sessionTimer;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: kit.settings,
      builder: (context, _) => MaterialApp(
        title: 'Tic Tac Toe | App Verse Games',
        debugShowCheckedModeBanner: false,
        theme: AppverseTheme.light(),
        darkTheme: AppverseTheme.dark(),
        themeMode: kit.settings.themeMode,
        shortcuts: GamePage.shortcuts,
        // On web the page around the iframe already shows the title and
        // rules, so the game opens straight into play.
        home: isWebBuild
            ? GameHost(kit: kit, setup: setup)
            : HomePage(kit: kit, sessionTimer: sessionTimer),
      ),
    );
  }
}
