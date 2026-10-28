// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:math';

import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/game_controller.dart';
import '../game/game_setup.dart';
import '../game/player.dart';
import '../game/score_repository.dart';
import '../game/session_timer.dart';
import '../widgets/board_view.dart';
import '../widgets/cell_widget.dart';
import '../widgets/game_chrome.dart';
import '../widgets/new_game_dialog.dart';
import '../widgets/score_widget.dart';
import '../widgets/session_bar.dart';
import 'game_host.dart';

/// Player vs computer, or two players on one device.
class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.kit,
    this.setup = const GameSetup(),
    this.humanFirst = true,
    this.scores,
    this.sessionTimer,
    required this.onNewGame,
    this.controller,
  });

  final CoreKit kit;
  final GameSetup setup;
  final bool humanFirst;
  final ScoreRepository? scores;

  /// Play-time reminder bar; only shown in the apps.
  final SessionTimer? sessionTimer;

  /// Starts a new game (possibly in another mode) with the given setup.
  final ValueChanged<GameSetup> onNewGame;

  /// Injected by tests; otherwise created from [setup].
  final GameController? controller;

  /// App shortcuts: arrow keys belong to the board cursor, so they must not
  /// also move focus between buttons or scroll.
  static Map<ShortcutActivator, Intent> get shortcuts => {
    ...WidgetsApp.defaultShortcuts,
    const SingleActivator(LogicalKeyboardKey.arrowUp):
        const DoNothingAndStopPropagationIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowDown):
        const DoNothingAndStopPropagationIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowLeft):
        const DoNothingAndStopPropagationIntent(),
    const SingleActivator(LogicalKeyboardKey.arrowRight):
        const DoNothingAndStopPropagationIntent(),
  };

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final GameController _game =
      widget.controller ??
      GameController(
        setup: widget.setup,
        humanFirst: widget.humanFirst,
        scores: widget.scores,
        onSound: (s) => playGameSound(widget.kit, s),
      );
  bool _ended = false;

  static const maxBoard = 560.0;
  static const panelWidth = 260.0;
  static const controlsHeight = 170.0;

  // Digit row in reading order: 1 = top-left, 9 = bottom-right.
  static final _digitKeys = <LogicalKeyboardKey, int>{
    LogicalKeyboardKey.digit1: 0,
    LogicalKeyboardKey.digit2: 1,
    LogicalKeyboardKey.digit3: 2,
    LogicalKeyboardKey.digit4: 3,
    LogicalKeyboardKey.digit5: 4,
    LogicalKeyboardKey.digit6: 5,
    LogicalKeyboardKey.digit7: 6,
    LogicalKeyboardKey.digit8: 7,
    LogicalKeyboardKey.digit9: 8,
    // Numpad matches its physical layout: 7 = top-left, 3 = bottom-right.
    LogicalKeyboardKey.numpad7: 0,
    LogicalKeyboardKey.numpad8: 1,
    LogicalKeyboardKey.numpad9: 2,
    LogicalKeyboardKey.numpad4: 3,
    LogicalKeyboardKey.numpad5: 4,
    LogicalKeyboardKey.numpad6: 5,
    LogicalKeyboardKey.numpad1: 6,
    LogicalKeyboardKey.numpad2: 7,
    LogicalKeyboardKey.numpad3: 8,
  };

  @override
  void initState() {
    super.initState();
    _game.addListener(_onGameChanged);
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _game.removeListener(_onGameChanged);
    if (widget.controller == null) _game.dispose();
    super.dispose();
  }

  void _onGameChanged() {
    if (!_game.isOver || _ended) return;
    _ended = true;
    // May show an ad between games (Android only, not every game).
    widget.kit.ads.onGameEnded();
  }

  /// Plays again with the same choices ("Take turns" swaps who starts).
  void _restart() => widget.onNewGame(_game.setup);

  Future<void> _options() async {
    final setup = await showNewGameDialog(context, _game.setup);
    if (setup != null && mounted) widget.onNewGame(setup);
  }

  Future<void> _hint() async {
    final ads = widget.kit.ads;
    if (!ads.rewardedReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The hint video is not ready yet. Try again shortly.'),
        ),
      );
      return;
    }
    final earned = await ads.showRewarded();
    if (earned && mounted) _game.showHint();
  }

  // A global handler rather than a Focus widget, so keys keep working after
  // the player clicks a button.
  bool _onKey(KeyEvent event) {
    if (event is KeyUpEvent || !mounted) return false;
    // Ignore keys while a dialog or another page is on top of the game.
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return false;
    final key = event.logicalKey;
    final repeat = event is KeyRepeatEvent;

    final digit = _digitKeys[key];
    if (digit != null) {
      if (!repeat) _game.keyMove(digit);
      return true;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _game.moveCursor(-1, 0);
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _game.moveCursor(1, 0);
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _game.moveCursor(0, -1);
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _game.moveCursor(0, 1);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      // A button reached with Tab owns Enter/Space.
      final focus = FocusManager.instance.primaryFocus;
      if (focus != null && focus is! FocusScopeNode) return false;
      if (!repeat) _game.playCursor();
    } else if (key == LogicalKeyboardKey.keyN) {
      if (!repeat) _restart();
    } else {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final timer = widget.sessionTimer;
    return Scaffold(
      appBar: gameAppBar(context, widget.kit, _game.setup.mode.label),
      body: SafeArea(
        child: Column(
          children: [
            if (timer != null && !isWebBuild) SessionBar(timer: timer),
            Expanded(
              child: ListenableBuilder(
                listenable: _game,
                builder: (context, _) => LayoutBuilder(builder: _layout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _board(double size) {
    final game = _game;
    return SizedBox.square(
      key: const Key('board'),
      dimension: size,
      child: BoardView(
        board: game.game.board,
        winningLine: game.game.board.winningLine,
        lastMove: game.lastMove,
        hintCell: game.hint,
        cursorCell: game.cursor,
        onCellTap: game.humansTurn ? game.tap : null,
      ),
    );
  }

  Widget _layout(BuildContext context, BoxConstraints constraints) {
    final w = constraints.maxWidth, h = constraints.maxHeight;
    final wide = w >= 720 && w > h;
    if (wide) {
      final board = max(0.0, min(min(w - panelWidth - 48, h - 16), maxBoard));
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _board(board),
            const SizedBox(width: 24),
            SizedBox(
              width: panelWidth,
              height: max(0.0, h - 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(width: panelWidth, child: _controls(context)),
              ),
            ),
          ],
        ),
      );
    }
    final board = max(0.0, min(min(w - 16, h - controlsHeight - 16), maxBoard));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _board(board),
        const SizedBox(height: 8),
        SizedBox(
          width: w,
          height: controlsHeight,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: max(min(w, 480.0), 320.0),
              child: _controls(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _controls(BuildContext context) {
    final theme = Theme.of(context);
    final game = _game;
    final setup = game.setup;
    final info =
        game.message ??
        (game.vsComputer
            ? '${setup.difficulty.label} · You play ${game.humanPlayer.label}'
            : 'Two players, one device');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!game.isOver) ...[
                MarkTile(game.game.currentPlayer),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  game.statusText,
                  key: const Key('status'),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 34,
            child: Center(
              child: Text(
                info,
                key: const Key('message'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
          SizedBox(
            width: 240,
            child: ScoreWidget(
              score: game.score,
              vsComputer: game.vsComputer,
              onReset: game.resetScores,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              FilledButton.icon(
                key: const Key('newGame'),
                icon: const Icon(Icons.refresh),
                label: const Text('New game'),
                onPressed: _restart,
              ),
              IconButton.outlined(
                key: const Key('options'),
                tooltip: 'Game options',
                icon: const Icon(Icons.tune),
                onPressed: _options,
              ),
              // Hints are paid for with an optional video ad, so they only
              // exist where ads do (the Android app).
              if (widget.kit.ads.isSupported)
                OutlinedButton.icon(
                  key: const Key('hint'),
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Hint'),
                  onPressed: game.canHint ? _hint : null,
                ),
              if (isWebBuild)
                IconButton.outlined(
                  key: const Key('demo'),
                  tooltip: 'Watch a demo game',
                  icon: const Icon(Icons.school_outlined),
                  onPressed: () =>
                      widget.onNewGame(setup.copyWith(mode: GameMode.watch)),
                ),
              ...webButtons(context, widget.kit),
            ],
          ),
        ],
      ),
    );
  }
}
