// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:async';
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
import 'privacy_policy_screen.dart';
import 'score_widget.dart';
import 'session_bar_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

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
    _sessionTimer.start();
    _sessionTimer.addListener(_onTimerTick);
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

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() {
      _cancelAiTimer();
      _hintCell = null;
      _game = _game.reset();
    });
  }

  void _setMode(bool vsAi) {
    setState(() {
      _cancelAiTimer();
      _hintCell = null;
      _vsAi = vsAi;
      _game = Game.start();
    });
  }

  void _setDifficulty(Difficulty d) {
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

  Widget _buildBoard(bool boardEnabled) {
    return Flexible(
      child: AspectRatio(
        aspectRatio: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: BoardWidget(
            board: _game.board,
            winningLine: _game.board.winningLine,
            hintCell: _hintCell,
            onCellTap: boardEnabled ? _onCellTap : null,
          ),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          _buildBoard(boardEnabled),
          const SizedBox(height: 16),
          FilledButton(onPressed: _reset, child: const Text('New Game')),
          if (_canHint) ...[
            const SizedBox(height: 8),
            _HintButton(onTap: _onHintTapped),
          ],
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
        const SizedBox(width: sidebarWidth),
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
            ],
          ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final boardEnabled = !_game.isOver && !_aiThinking && !_isAiTurn;
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
                  if (constraints.maxWidth >= 600) {
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
