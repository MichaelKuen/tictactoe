// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:math';

import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/ai.dart';
import '../game/demo.dart';
import '../game/game.dart';
import '../game/game_controller.dart' show GameSound;
import '../game/game_setup.dart';
import '../game/game_status.dart';
import '../game/player.dart';
import '../game/session_timer.dart';
import '../services/page_visibility.dart';
import '../widgets/board_view.dart';
import '../widgets/cell_widget.dart';
import '../widgets/game_chrome.dart';
import '../widgets/new_game_dialog.dart';
import '../widgets/session_bar.dart';
import 'game_host.dart';

typedef WatchController = AutoPlayController<Game, int>;
typedef DemoEntry = AutoPlayEntry<Game, int>;

/// Watch and Learn: two computers play a demo game, and a comment box
/// explains every move and why it was chosen.
class WatchPage extends StatefulWidget {
  const WatchPage({
    super.key,
    required this.kit,
    this.setup = const GameSetup(mode: GameMode.watch),
    this.sessionTimer,
    required this.onNewGame,
    this.random,
    this.autoStart = true,
    this.visibility,
  });

  final CoreKit kit;
  final GameSetup setup;
  final SessionTimer? sessionTimer;
  final ValueChanged<GameSetup> onNewGame;

  /// Injected by tests so the computers' random choices repeat.
  final Random? random;

  /// Start playing as soon as the page opens.
  final bool autoStart;

  /// Whether the player can see the game; [pageVisible] unless a test
  /// passes its own.
  final ValueListenable<bool>? visibility;

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  late GameSetup _setup = widget.setup;
  late final WatchController _auto = AutoPlayController(
    initial: Game.start(),
    decide: (g) async => AiPlayer.decide(
      g.board,
      g.currentPlayer,
      _setup.levelFor(g.currentPlayer),
      random: widget.random,
    ),
    apply: (g, move) => g.move(move),
    isOver: (g) => g.isOver,
    // Long enough to read the comment box (and its "Why").
    pace: (e) => readingTime(
      '${describe(e.before, e.decision.move)} ${e.decision.reason}',
    ),
    speed: widget.setup.speed,
  );
  final _logScroll = ScrollController();
  int _heardPosition = 0;
  late final ValueListenable<bool> _visible = widget.visibility ?? pageVisible;

  /// The demo was playing when it was hidden, so it carries on when shown.
  bool _resumeWhenVisible = false;

  static const maxBoard = 560.0;
  static const panelWidth = 300.0;
  static const controlsHeight = 150.0;
  static const commentHeight = 120.0;

  // Tighter when stacked under the board, so it stays big.
  static const stackedControlsHeight = 112.0;
  static const stackedCommentHeight = 100.0;
  static const maxCommentHeight = 150.0;
  static const minLogHeight = 44.0;

  @override
  void initState() {
    super.initState();
    _auto.addListener(_onChanged);
    HardwareKeyboard.instance.addHandler(_onKey);
    _visible.addListener(_onVisibility);
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_visible.value) {
          _auto.play();
        } else {
          _resumeWhenVisible = true;
        }
      });
    }
  }

  /// The demo pauses while the player can't see it (web only).
  void _onVisibility() {
    if (!_visible.value) {
      if (_auto.isPlaying) _resumeWhenVisible = true;
      _auto.pause();
    } else if (_resumeWhenVisible) {
      _resumeWhenVisible = false;
      _auto.play();
    }
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _visible.removeListener(_onVisibility);
    _auto.dispose();
    _logScroll.dispose();
    super.dispose();
  }

  void _onChanged() {
    // Sounds only for newly played moves, not when stepping back.
    if (_auto.position > _heardPosition) {
      final state = _auto.state;
      if (_auto.isFinished) {
        playGameSound(
          widget.kit,
          state.status == GameStatus.draw ? GameSound.draw : GameSound.win,
        );
      } else if (_auto.speed != AutoPlaySpeed.instant) {
        final mover = _auto.lastEntry!.before.currentPlayer;
        playGameSound(
          widget.kit,
          mover == Player.x ? GameSound.moveX : GameSound.moveO,
          volume: 0.7,
        );
      }
    }
    _heardPosition = _auto.position;
    // Keep the current row in view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_logScroll.hasClients || _auto.position == 0) return;
      final target = (_auto.position - 1) * _LogTile.height;
      final view = _logScroll.position;
      if (target < view.pixels ||
          target + _LogTile.height > view.pixels + view.viewportDimension) {
        _logScroll.jumpTo(
          min(
            view.maxScrollExtent,
            max(0.0, target - view.viewportDimension + _LogTile.height * 2),
          ),
        );
      }
    });
  }

  void _setSpeed(AutoPlaySpeed speed) {
    _auto.speed = speed;
    _setup = _setup.copyWith(speed: speed);
    _setup.save();
  }

  Future<void> _newGame() async {
    _auto.pause();
    final setup = await showNewGameDialog(context, _setup);
    if (setup != null && mounted) widget.onNewGame(setup);
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyUpEvent) return false;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return false;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      final focus = FocusManager.instance.primaryFocus;
      if (focus != null && focus is! FocusScopeNode) return false;
      if (event is KeyDownEvent) _auto.togglePlay();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _auto.pause();
      _auto.stepForward();
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.backspace) {
      _auto.stepBack();
    } else if (key == LogicalKeyboardKey.keyN && event is KeyDownEvent) {
      widget.onNewGame(_setup);
    } else {
      const digits = [
        [LogicalKeyboardKey.digit1, LogicalKeyboardKey.numpad1],
        [LogicalKeyboardKey.digit2, LogicalKeyboardKey.numpad2],
        [LogicalKeyboardKey.digit3, LogicalKeyboardKey.numpad3],
        [LogicalKeyboardKey.digit4, LogicalKeyboardKey.numpad4],
      ];
      final i = digits.indexWhere((keys) => keys.contains(key));
      if (i < 0) return false;
      _setSpeed(AutoPlaySpeed.values[i]);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final timer = widget.sessionTimer;
    return Scaffold(
      appBar: gameAppBar(context, widget.kit, 'Watch and Learn'),
      body: SafeArea(
        child: Column(
          children: [
            if (timer != null && !isWebBuild) SessionBar(timer: timer),
            Expanded(
              child: ListenableBuilder(
                listenable: _auto,
                builder: (context, _) => LayoutBuilder(builder: _layout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _board(double size) {
    final board = _auto.state.board;
    return SizedBox.square(
      key: const Key('board'),
      dimension: size,
      child: BoardView(
        board: board,
        winningLine: board.winningLine,
        lastMove: _auto.lastEntry?.decision.move,
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
              child: Column(
                children: [
                  SizedBox(
                    height: controlsHeight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _controls(context),
                    ),
                  ),
                  _comment(context, panelWidth, commentHeight),
                  const SizedBox(height: 6),
                  Expanded(child: _log(context)),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final board = max(
      0.0,
      min(
        min(
          w - 16,
          h - stackedControlsHeight - stackedCommentHeight - minLogHeight - 18,
        ),
        maxBoard,
      ),
    );
    // Height left over after the board goes to the comment first, so its
    // text stays readable on phones, then to the move log.
    final comment = (h - board - stackedControlsHeight - minLogHeight - 18)
        .clamp(stackedCommentHeight, maxCommentHeight);
    final column = max(board, min(w - 16, 320.0));
    return Column(
      children: [
        const SizedBox(height: 4),
        _board(board),
        SizedBox(
          width: w,
          height: stackedControlsHeight,
          child: FittedBox(fit: BoxFit.scaleDown, child: _controls(context)),
        ),
        _comment(context, column, comment),
        const SizedBox(height: 6),
        Expanded(
          child: SizedBox(width: column, child: _log(context)),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  String _sideLabel(Player p) => '${p.label} (${_setup.levelFor(p).label})';

  Widget _controls(BuildContext context) {
    final theme = Theme.of(context);
    final s = _auto.state;
    final status = switch (s.status) {
      GameStatus.xWins => 'X wins!',
      GameStatus.oWins => 'O wins!',
      GameStatus.draw => 'Draw',
      GameStatus.playing =>
        _auto.isThinking
            ? '${s.currentPlayer.label} is thinking…'
            : '${s.currentPlayer.label} to move',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!s.isOver) ...[
                MarkTile(s.currentPlayer, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                status,
                key: const Key('status'),
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          Text(
            '${_sideLabel(Player.x)} vs ${_sideLabel(Player.o)}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.outlined(
                key: const Key('back'),
                tooltip: 'Step back',
                icon: const Icon(Icons.skip_previous),
                onPressed: _auto.canStepBack ? _auto.stepBack : null,
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                key: const Key('playPause'),
                tooltip: _auto.isPlaying ? 'Pause' : 'Play',
                icon: Icon(_auto.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _auto.isFinished && !_auto.isPlaying
                    ? null
                    : _auto.togglePlay,
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                key: const Key('forward'),
                tooltip: 'Step forward',
                icon: const Icon(Icons.skip_next),
                onPressed: _auto.canStepForward
                    ? () {
                        _auto.pause();
                        _auto.stepForward();
                      }
                    : null,
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                key: const Key('newGame'),
                icon: const Icon(Icons.refresh),
                label: const Text('New game'),
                onPressed: _newGame,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<AutoPlaySpeed>(
                key: const Key('speed'),
                showSelectedIcon: false,
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                segments: [
                  for (final sp in AutoPlaySpeed.values)
                    ButtonSegment(
                      value: sp,
                      label: Text(
                        sp == AutoPlaySpeed.instant ? 'Max' : sp.label,
                      ),
                    ),
                ],
                selected: {_auto.speed},
                onSelectionChanged: (s) => _setSpeed(s.first),
              ),
              const SizedBox(width: 8),
              if (isWebBuild)
                IconButton.outlined(
                  key: const Key('playYourself'),
                  tooltip: 'Play a game yourself',
                  icon: const Icon(Icons.sports_esports_outlined),
                  onPressed: () => widget.onNewGame(
                    _setup.copyWith(mode: GameMode.vsComputer),
                  ),
                ),
              for (final b in webButtons(context, widget.kit))
                Padding(padding: const EdgeInsets.only(left: 4), child: b),
            ],
          ),
        ],
      ),
    );
  }

  /// The big comment box: what is happening now, and why.
  Widget _comment(BuildContext context, double width, double height) {
    final theme = Theme.of(context);
    final entry = _auto.lastEntry;
    final String title;
    final String text;
    String? why;
    if (entry == null) {
      title = 'Watch and Learn';
      text =
          'Two computers play a whole game, and this box explains every '
          'move. Pause, step back or change the speed any time.';
    } else {
      title = 'Move ${_auto.position} · ${entry.before.currentPlayer.label}';
      text = describe(entry.before, entry.decision.move);
      why = entry.decision.reason;
    }
    return Container(
      key: const Key('comment'),
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.6),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: width - 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(
                text,
                key: const Key('commentText'),
                style: theme.textTheme.bodyMedium,
              ),
              if (why != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Why: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                        TextSpan(text: '$why.'),
                      ],
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _log(BuildContext context) {
    final theme = Theme.of(context);
    final log = _auto.log;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: log.isEmpty
          ? Center(
              child: Text(
                'Moves will be listed here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            )
          : ListView.builder(
              key: const Key('moveLog'),
              controller: _logScroll,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemExtent: _LogTile.height,
              itemCount: log.length,
              itemBuilder: (context, i) => _LogTile(
                turn: i + 1,
                entry: log[i],
                current: i == _auto.position - 1,
                future: i >= _auto.position,
              ),
            ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({
    required this.turn,
    required this.entry,
    required this.current,
    required this.future,
  });

  static const height = 52.0;

  final int turn;
  final DemoEntry entry;
  final bool current;
  final bool future;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final side = entry.before.currentPlayer;
    return Opacity(
      opacity: future ? 0.45 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: current
              ? theme.colorScheme.secondary.withValues(alpha: 0.25)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 26,
              child: Text('$turn.', style: theme.textTheme.bodySmall),
            ),
            MarkTile(side, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    squareNames[entry.decision.move],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge,
                  ),
                  Text(
                    entry.decision.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
