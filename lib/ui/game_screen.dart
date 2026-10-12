// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ads/ad_manager.dart';
import '../game/ai.dart';
import '../game/difficulty.dart';
import '../game/game.dart';
import '../game/game_status.dart';
import '../game/player.dart';
import '../game/score.dart';
import '../game/score_repository.dart';
import '../health/session_timer.dart';
import '../theme_notifier.dart';
import 'board_widget.dart';
import 'games_sheet.dart';
import 'kofi_button.dart';
import 'privacy_policy_screen.dart';
import 'score_widget.dart';
import 'session_bar_widget.dart';

class GameScreen extends StatefulWidget {
  /// Web build embedded in the appversegames.com iframe: the page around it
  /// shows the title, rules and ads, so the game shows only the game: no app
  /// bar, store links, Ko-fi, ad hints or session timer.
  final bool embedMode;

  const GameScreen({super.key, this.embedMode = kIsWeb});

  /// App shortcuts for embed mode: arrow keys belong to the board cursor, so
  /// they must not also move focus between buttons or scroll.
  static Map<ShortcutActivator, Intent> get embedShortcuts => {
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
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Game _game = Game.start();
  bool _vsAi = true;
  Difficulty _difficulty = Difficulty.hard;
  bool _aiThinking = false;
  Timer? _aiTimer;
  int? _hintCell;
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  final _sessionTimer = SessionTimer();
  bool _eyeBreakShown = false;
  bool _sessionLimitShown = false;
  ScoreRepository? _scoreRepo;
  Score _aiScore = const Score();
  Score _humanScore = const Score();

  /// Keyboard cursor (embed mode only); null until an arrow key is pressed.
  int? _cursor;

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

  static bool get _adsSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadBanner();
    if (widget.embedMode) {
      HardwareKeyboard.instance.addHandler(_onKey);
    } else {
      _sessionTimer.start();
      _sessionTimer.addListener(_onTimerTick);
    }
    _initScores();
  }

  Future<void> _initScores() async {
    final repo = await ScoreRepository.create();
    if (!mounted) return;
    setState(() {
      _scoreRepo = repo;
      _aiScore = repo.aiScore;
      _humanScore = repo.humanScore;
    });
  }

  void _loadBanner() {
    if (!_adsSupported) return;
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _bannerLoaded = true),
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _sessionTimer.removeListener(_onTimerTick);
    _sessionTimer.dispose();
    _bannerAd?.dispose();
    _aiTimer?.cancel();
    super.dispose();
  }

  void _onTimerTick() {
    if (!mounted) return;
    if (_sessionTimer.shouldFireEyeBreak && !_eyeBreakShown) {
      _eyeBreakShown = true;
      _sessionTimer.acknowledgeEyeBreak();
      _showEyeBreakSnackBar();
    }
    if (_sessionTimer.shouldFireSessionLimit && !_sessionLimitShown) {
      _sessionLimitShown = true;
      _showSessionLimitDialog();
    }
  }

  void _showEyeBreakSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 8),
        backgroundColor: const Color(0xFF3A2D0A),
        content: Row(
          children: const [
            Icon(Icons.visibility_outlined, color: Color(0xFFFFD740), size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '20-20-20 eye break — look at something 20 feet away for 20 seconds.',
                style: TextStyle(color: Color(0xFFFFD740)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionLimitDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.health_and_safety, color: Color(0xFFFF5252), size: 28),
            SizedBox(width: 10),
            Text('Time for a break!',
                style: TextStyle(color: Color(0xFFFF5252))),
          ],
        ),
        content: const Text(
          "You've been playing for 60 minutes.\n\n"
          "Health guidelines recommend taking a proper break — "
          "stand up, stretch, and rest your eyes before continuing.",
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _sessionTimer.dismissSessionLimit();
            },
            child: const Text('Continue anyway',
                style: TextStyle(color: Colors.white38)),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _eyeBreakShown = false;
              _sessionLimitShown = false;
              _sessionTimer.acknowledgeSessionLimit();
            },
            icon: const Icon(Icons.self_improvement, size: 18),
            label: const Text('Take a break'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF69F0AE),
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // A global handler rather than a Focus widget, so keys keep working after
  // the player clicks a button.
  bool _onKey(KeyEvent event) {
    if (event is KeyUpEvent || !mounted) return false;
    if (!(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    final key = event.logicalKey;
    final repeat = event is KeyRepeatEvent;

    final digitCell = _digitKeys[key];
    if (digitCell != null) {
      if (!repeat) _keyMove(digitCell);
      return true;
    }

    final arrows = {
      LogicalKeyboardKey.arrowUp: (-1, 0),
      LogicalKeyboardKey.arrowDown: (1, 0),
      LogicalKeyboardKey.arrowLeft: (0, -1),
      LogicalKeyboardKey.arrowRight: (0, 1),
    };
    final step = arrows[key];
    if (step != null) {
      setState(() {
        final c = _cursor;
        if (c == null) {
          _cursor = 4; // first arrow press selects the centre
        } else {
          final row = (c ~/ 3 + step.$1).clamp(0, 2);
          final col = (c % 3 + step.$2).clamp(0, 2);
          _cursor = row * 3 + col;
        }
      });
      return true;
    }

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      // A button reached with Tab owns Enter/Space.
      final focus = FocusManager.instance.primaryFocus;
      if (focus != null && focus is! FocusScopeNode) return false;
      final c = _cursor;
      if (c != null && !repeat) _keyMove(c);
      return true;
    }

    if (key == LogicalKeyboardKey.keyN) {
      if (!repeat) _reset();
      return true;
    }
    return false;
  }

  void _keyMove(int index) {
    setState(() => _cursor = index);
    final boardEnabled = !_game.isOver && !_aiThinking && !_isAiTurn;
    if (boardEnabled && _game.board.canMove(index)) _onCellTap(index);
  }

  bool get _isAiTurn =>
      _vsAi && !_game.isOver && _game.currentPlayer == Player.o;

  void _onCellTap(int index) {
    if (_aiThinking) return;
    HapticFeedback.selectionClick();
    setState(() {
      _hintCell = null;
      _game = _game.move(index);
    });
    if (_game.isOver) {
      _game.status == GameStatus.draw
          ? HapticFeedback.lightImpact()
          : HapticFeedback.mediumImpact();
      AdManager.instance.onGameEnded();
      _recordResult();
    } else if (_isAiTurn) {
      _scheduleAiMove();
    }
  }

  void _scheduleAiMove() {
    setState(() => _aiThinking = true);
    _aiTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      HapticFeedback.selectionClick();
      setState(() {
        _game = _game.move(AiPlayer.move(_game.board, Player.o, _difficulty));
        _aiThinking = false;
      });
      if (_game.isOver) {
        HapticFeedback.mediumImpact();
        AdManager.instance.onGameEnded();
        _recordResult();
      }
    });
  }

  void _recordResult() {
    final repo = _scoreRepo;
    if (repo == null || !_game.isOver) return;
    if (_vsAi) {
      final next = switch (_game.status) {
        GameStatus.xWins => _aiScore.copyWithXWin(),
        GameStatus.oWins => _aiScore.copyWithOWin(),
        GameStatus.draw => _aiScore.copyWithDraw(),
        GameStatus.playing => null,
      };
      if (next == null) return;
      setState(() => _aiScore = next);
      repo.saveAiScore(next);
    } else {
      final next = switch (_game.status) {
        GameStatus.xWins => _humanScore.copyWithXWin(),
        GameStatus.oWins => _humanScore.copyWithOWin(),
        GameStatus.draw => _humanScore.copyWithDraw(),
        GameStatus.playing => null,
      };
      if (next == null) return;
      setState(() => _humanScore = next);
      repo.saveHumanScore(next);
    }
  }

  void _resetScores() {
    _scoreRepo?.resetAll();
    setState(() {
      _aiScore = const Score();
      _humanScore = const Score();
    });
  }

  void _cancelAiTimer() {
    _aiTimer?.cancel();
    _aiTimer = null;
    _aiThinking = false;
  }

  /// In embed mode a clicked button gives up focus, so Enter/Space go back
  /// to the board instead of pressing that button again.
  void _releaseFocus() {
    if (widget.embedMode) FocusManager.instance.primaryFocus?.unfocus();
  }

  void _reset() {
    _releaseFocus();
    HapticFeedback.lightImpact();
    setState(() {
      _cancelAiTimer();
      _hintCell = null;
      _game = _game.reset();
    });
  }

  void _setMode(bool vsAi) {
    _releaseFocus();
    setState(() {
      _cancelAiTimer();
      _hintCell = null;
      _vsAi = vsAi;
      _game = Game.start();
    });
  }

  void _setDifficulty(Difficulty d) {
    _releaseFocus();
    setState(() {
      _cancelAiTimer();
      _hintCell = null;
      _difficulty = d;
      _game = Game.start();
    });
  }

  void _onHintTapped() {
    if (!AdManager.instance.isRewardedReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hint ad not ready yet — try again shortly.')),
      );
      return;
    }
    AdManager.instance.showRewarded(() {
      if (!mounted) return;
      final best = AiPlayer.bestMove(_game.board, _game.currentPlayer);
      setState(() => _hintCell = best);
    });
  }

  String get _statusText {
    if (_aiThinking) return 'AI is thinking…';
    switch (_game.status) {
      case GameStatus.playing:
        final label = _game.currentPlayer.label;
        final who = _vsAi && _game.currentPlayer == Player.o ? 'AI' : label;
        return "$who's turn";
      case GameStatus.xWins:
        return _vsAi ? 'You win!' : 'X wins!';
      case GameStatus.oWins:
        return _vsAi ? 'AI wins!' : 'O wins!';
      case GameStatus.draw:
        return 'Draw!';
    }
  }

  bool get _canHint =>
      !_game.isOver && !_aiThinking && !_isAiTurn && _hintCell == null;

  static const double _maxBoard = 560;

  Widget _board(bool boardEnabled) {
    return BoardWidget(
      board: _game.board,
      winningLine: _game.board.winningLine,
      hintCell: _hintCell,
      cursorCell: _cursor,
      onCellTap: boardEnabled ? _onCellTap : null,
    );
  }

  /// Board that takes the largest square the remaining space allows.
  Widget _buildBoard(bool boardEnabled) {
    return Flexible(
      child: LayoutBuilder(
        builder: (context, constraints) => SizedBox.square(
          dimension: min(
              min(constraints.maxWidth, constraints.maxHeight), _maxBoard),
          child: _board(boardEnabled),
        ),
      ),
    );
  }

  Widget _buildStatus(BuildContext context, ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Text(
        _statusText,
        key: ValueKey(_statusText),
        style: theme.textTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, bool boardEnabled) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // The controls need roughly 400px of height. The board gets the rest
        // but never drops below 240px: on very short screens the column
        // scrolls instead of shrinking the board to nothing.
        final boardSize = min(
          min(constraints.maxWidth - 48,
              max(constraints.maxHeight - 400, 240.0)),
          _maxBoard,
        );
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: _buildNarrowColumn(theme, boardSize, boardEnabled),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNarrowColumn(
      ThemeData theme, double boardSize, bool boardEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('vs AI')),
              ButtonSegment(value: false, label: Text('vs Human')),
            ],
            selected: {_vsAi},
            onSelectionChanged: (s) => _setMode(s.first),
          ),
          if (_vsAi) ...[
            const SizedBox(height: 12),
            SegmentedButton<Difficulty>(
              segments: Difficulty.values
                  .map((d) => ButtonSegment(value: d, label: Text(d.label)))
                  .toList(),
              selected: {_difficulty},
              onSelectionChanged: (s) => _setDifficulty(s.first),
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                selectedForegroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_scoreRepo != null)
            ScoreWidget(
              score: _vsAi ? _aiScore : _humanScore,
              vsAi: _vsAi,
              onReset: _resetScores,
            ),
          const SizedBox(height: 8),
          _buildStatus(context, theme),
          const SizedBox(height: 16),
          SizedBox.square(dimension: boardSize, child: _board(boardEnabled)),
          const SizedBox(height: 16),
          FilledButton(onPressed: _reset, child: const Text('New Game')),
          if (_canHint) ...[
            const SizedBox(height: 8),
            _HintButton(onTap: _onHintTapped),
          ],
          const SizedBox(height: 12),
          const KoFiButton(),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, bool boardEnabled) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const sidebarWidth = 180.0;
    final sidebarColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFEEEEEE);
    final sidebarBorderColor =
        isDark ? const Color(0xFF5A5A7A) : const Color(0xFFCCCCCC);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatus(context, theme),
                const SizedBox(height: 24),
                _buildBoard(boardEnabled),
              ],
            ),
          ),
        ),
        Container(
          width: sidebarWidth,
          decoration: BoxDecoration(
            color: sidebarColor,
            border: Border(
                left: BorderSide(color: sidebarBorderColor)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Text(
                'Game Mode',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _SidebarButton(
                label: 'vs AI',
                selected: _vsAi,
                onTap: () => _setMode(true),
              ),
              const SizedBox(height: 8),
              _SidebarButton(
                label: 'vs Human',
                selected: !_vsAi,
                onTap: () => _setMode(false),
              ),
              if (_vsAi) ...[
                const SizedBox(height: 24),
                Divider(color: sidebarBorderColor),
                const SizedBox(height: 16),
                Text(
                  'Difficulty',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ...Difficulty.values.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SidebarButton(
                      label: d.label,
                      selected: _difficulty == d,
                      onTap: () => _setDifficulty(d),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Divider(color: sidebarBorderColor),
              const SizedBox(height: 8),
              FilledButton(onPressed: _reset, child: const Text('New Game')),
              if (_canHint) ...[
                const SizedBox(height: 8),
                _HintButton(onTap: _onHintTapped),
              ],
              if (_scoreRepo != null) ...[
                const SizedBox(height: 12),
                ScoreWidget(
                  score: _vsAi ? _aiScore : _humanScore,
                  vsAi: _vsAi,
                  onReset: _resetScores,
                ),
              ],
              const SizedBox(height: 8),
              Divider(color: sidebarBorderColor),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => GamesSheet.show(context),
                icon: const Icon(Icons.sports_esports, size: 16),
                label: const Text('More Games'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: sidebarBorderColor),
                ),
              ),
              const SizedBox(height: 8),
              const KoFiButton(),
            ],
          ),
          ),
        ),
      ],
    );
  }

  // ── Embedded web layout ────────────────────────────────────────────────

  static const double _pad = 12;
  static const double _gap = 8;
  static const double _rowH = 40;
  static const double _statusH = 32;
  static const double _bottomH = 52;
  static const double _panelW = 240;

  /// Fixed-height row whose content shrinks instead of overflowing.
  Widget _fit(double width, double height, Widget child) => SizedBox(
        width: width,
        height: height,
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      );

  Widget _themeToggle(bool isDark, {bool withLabel = false}) {
    void toggle() {
      _releaseFocus();
      themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
    }

    final icon = Icon(isDark ? Icons.light_mode : Icons.dark_mode);
    final tooltip = isDark ? 'Switch to light mode' : 'Switch to dark mode';
    if (withLabel) {
      return TextButton.icon(
        onPressed: toggle,
        icon: icon,
        label: Text(isDark ? 'Light mode' : 'Dark mode'),
      );
    }
    return IconButton(tooltip: tooltip, icon: icon, onPressed: toggle);
  }

  Widget _modeSelector() => SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: true, label: Text('vs AI')),
          ButtonSegment(value: false, label: Text('vs Human')),
        ],
        selected: {_vsAi},
        onSelectionChanged: (s) => _setMode(s.first),
      );

  /// Difficulty buttons in AI mode; a note of the same size in 2-player mode
  /// so the board does not jump when switching modes.
  Widget _difficultySelector(ThemeData theme) {
    if (!_vsAi) {
      return SizedBox(
        height: _rowH,
        child: Center(
          child: Text(
            'Two players, one device',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }
    return SegmentedButton<Difficulty>(
      showSelectedIcon: false,
      segments: Difficulty.values
          .map((d) => ButtonSegment(value: d, label: Text(d.label)))
          .toList(),
      selected: {_difficulty},
      onSelectionChanged: (s) => _setDifficulty(s.first),
    );
  }

  Widget _scoreBox() => SizedBox(
        width: 200,
        child: _scoreRepo == null
            ? const SizedBox(height: 50)
            : ScoreWidget(
                score: _vsAi ? _aiScore : _humanScore,
                vsAi: _vsAi,
                onReset: _resetScores,
              ),
      );

  Widget _buildEmbed(BuildContext context, bool boardEnabled) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            if (w >= 720 && w > h) {
              return _buildEmbedSide(theme, isDark, w, h, boardEnabled);
            }
            return _buildEmbedStacked(theme, isDark, w, h, boardEnabled);
          },
        ),
      ),
    );
  }

  /// Phones, narrow and square iframes: controls stacked around the board.
  Widget _buildEmbedStacked(
      ThemeData theme, bool isDark, double w, double h, bool boardEnabled) {
    const controlsH =
        _rowH + _gap + _rowH + _gap + _statusH + _gap + _gap + _bottomH;
    final boardSize = max(
      0.0,
      min(min(w - 2 * _pad, h - 2 * _pad - controlsH), _maxBoard),
    );
    final controlsW = max(0.0, min(w - 2 * _pad, max(boardSize, 360.0)));
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _fit(
            controlsW,
            _rowH,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _modeSelector(),
                const SizedBox(width: 8),
                _themeToggle(isDark),
              ],
            ),
          ),
          const SizedBox(height: _gap),
          _fit(controlsW, _rowH, _difficultySelector(theme)),
          const SizedBox(height: _gap),
          _fit(controlsW, _statusH, _buildStatus(context, theme)),
          const SizedBox(height: _gap),
          SizedBox.square(dimension: boardSize, child: _board(boardEnabled)),
          const SizedBox(height: _gap),
          _fit(
            controlsW,
            _bottomH,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _scoreBox(),
                const SizedBox(width: 12),
                FilledButton(onPressed: _reset, child: const Text('New Game')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Wide landscape iframes: board on the left, control panel on the right.
  Widget _buildEmbedSide(
      ThemeData theme, bool isDark, double w, double h, bool boardEnabled) {
    final boardSize = max(
      0.0,
      min(min(w - _panelW - 4 * _pad, h - 2 * _pad), _maxBoard),
    );
    final label = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      letterSpacing: 1.2,
    );
    final panel = SizedBox(
      width: _panelW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _buildStatus(context, theme),
            ),
          ),
          const SizedBox(height: 16),
          Text('MODE', style: label),
          const SizedBox(height: 6),
          _modeSelector(),
          const SizedBox(height: 16),
          Text('DIFFICULTY', style: label),
          const SizedBox(height: 6),
          _difficultySelector(theme),
          const SizedBox(height: 16),
          _scoreBox(),
          const SizedBox(height: 16),
          FilledButton(onPressed: _reset, child: const Text('New Game')),
          const SizedBox(height: 8),
          _themeToggle(isDark, withLabel: true),
        ],
      ),
    );
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(dimension: boardSize, child: _board(boardEnabled)),
          const SizedBox(width: 2 * _pad),
          SizedBox(
            width: _panelW,
            height: max(0.0, h - 2 * _pad),
            child: FittedBox(fit: BoxFit.scaleDown, child: panel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final boardEnabled = !_game.isOver && !_aiThinking && !_isAiTurn;
    if (widget.embedMode) return _buildEmbed(context, boardEnabled);
    final appBarColor =
        isDark ? const Color(0xFF252540) : const Color(0xFFEEEEEE);

    Widget? bannerWidget;
    if (_bannerLoaded && _bannerAd != null) {
      bannerWidget = SizedBox(
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            tooltip: 'More Games',
            icon: const Icon(Icons.sports_esports),
            onPressed: () => GamesSheet.show(context),
          ),
          IconButton(
            tooltip: 'Privacy Policy',
            icon: const Icon(Icons.privacy_tip_outlined),
            onPressed: () => PrivacyPolicyScreen.show(context),
          ),
          IconButton(
            tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeNotifier.value =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      bottomNavigationBar: bannerWidget,
      body: SafeArea(
        child: Column(
          children: [
            SessionBarWidget(timer: _sessionTimer),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Sidebar only when there is room for it beside a decent
                  // board: wide and landscape.
                  if (constraints.maxWidth >= 720 &&
                      constraints.maxWidth > constraints.maxHeight) {
                    return _buildWideLayout(context, boardEnabled);
                  }
                  return _buildNarrowLayout(context, boardEnabled);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  final VoidCallback onTap;
  const _HintButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.lightbulb_outline, size: 16),
      label: const Text('Watch ad for hint'),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF69F0AE),
        side: const BorderSide(color: Color(0xFF69F0AE)),
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (selected) {
      return FilledButton(
        onPressed: null,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor: theme.colorScheme.primary,
          disabledForegroundColor: theme.colorScheme.onPrimary,
        ),
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: theme.colorScheme.outline),
      ),
      child: Text(label),
    );
  }
}
