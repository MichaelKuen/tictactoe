// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';

import '../game/board.dart';
import '../game/game_setup.dart';
import '../game/player.dart';
import '../game/session_timer.dart';
import '../widgets/board_view.dart';
import '../widgets/game_chrome.dart';
import '../widgets/games_sheet.dart';
import '../widgets/kofi_button.dart';
import 'game_host.dart';
import 'how_to_play_page.dart';

/// Start screen for the Android, iOS and Windows apps. Not used on web.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.kit, this.sessionTimer});

  final CoreKit kit;
  final SessionTimer? sessionTimer;

  Future<void> _play(BuildContext context, GameMode mode) async {
    // Reload so choices made during the last game are kept.
    final setup = (await GameSetup.load()).copyWith(mode: mode);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            GameHost(kit: kit, setup: setup, sessionTimer: sessionTimer),
      ),
    );
  }

  /// A finished game for the title picture: X has the diagonal.
  static final _preview = [
    (0, Player.x),
    (1, Player.o),
    (4, Player.x),
    (2, Player.o),
    (8, Player.x),
  ].fold(Board.empty(), (b, m) => b.move(m.$1, m.$2));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    Widget button(
      Key key,
      IconData icon,
      String label,
      VoidCallback onTap, {
      bool filled = false,
    }) => SizedBox(
      width: 260,
      child: filled
          ? FilledButton.icon(
              key: key,
              icon: Icon(icon),
              label: Text(label),
              onPressed: onTap,
            )
          : OutlinedButton.icon(
              key: key,
              icon: Icon(icon),
              label: Text(label),
              onPressed: onTap,
            ),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tic Tac Toe', style: textTheme.displaySmall),
                const SizedBox(height: 4),
                Text('Three in a row wins', style: textTheme.titleMedium),
                const SizedBox(height: 20),
                IgnorePointer(
                  child: SizedBox.square(
                    dimension: 180,
                    child: BoardView(
                      board: _preview,
                      winningLine: const [0, 4, 8],
                      pulse: false,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                button(
                  const Key('playComputer'),
                  Icons.smart_toy_outlined,
                  'Play vs Computer',
                  () => _play(context, GameMode.vsComputer),
                  filled: true,
                ),
                const SizedBox(height: 10),
                button(
                  const Key('playTwo'),
                  Icons.people_outline,
                  '2 Players',
                  () => _play(context, GameMode.twoPlayer),
                ),
                const SizedBox(height: 10),
                button(
                  const Key('watch'),
                  Icons.school_outlined,
                  'Watch and Learn',
                  () => _play(context, GameMode.watch),
                ),
                const SizedBox(height: 10),
                button(
                  const Key('howToPlay'),
                  Icons.help_outline,
                  'How to Play',
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HowToPlayPage()),
                  ),
                ),
                const SizedBox(height: 10),
                button(
                  const Key('moreGames'),
                  Icons.sports_esports_outlined,
                  'More Games',
                  () => GamesSheet.show(context),
                ),
                const SizedBox(height: 10),
                button(
                  const Key('settings'),
                  Icons.settings,
                  'Settings',
                  () => openSettings(context, kit),
                ),
                const SizedBox(height: 10),
                const SizedBox(width: 260, child: KoFiButton()),
                const SizedBox(height: 16),
                Text('App Verse Games', style: textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
