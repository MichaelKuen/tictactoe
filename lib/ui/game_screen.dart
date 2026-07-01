// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:async';
import 'package:flutter/material.dart';
import '../game/ai.dart';
import '../game/game.dart';
import '../game/game_status.dart';
import '../game/player.dart';
import 'board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Game _game = Game.start();
  bool _vsAi = true;
  bool _aiThinking = false;
  Timer? _aiTimer;

  bool get _isAiTurn =>
      _vsAi && !_game.isOver && _game.currentPlayer == Player.o;

  @override
  void dispose() {
    _aiTimer?.cancel();
    super.dispose();
  }

  void _onCellTap(int index) {
    if (_aiThinking) return;
    setState(() {
      _game = _game.move(index);
    });
    if (_isAiTurn) _scheduleAiMove();
  }

  void _scheduleAiMove() {
    setState(() => _aiThinking = true);
    _aiTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _game = _game.move(AiPlayer.bestMove(_game.board, Player.o));
        _aiThinking = false;
      });
    });
  }

  void _cancelAiTimer() {
    _aiTimer?.cancel();
    _aiTimer = null;
    _aiThinking = false;
  }

  void _reset() {
    setState(() {
      _cancelAiTimer();
      _game = _game.reset();
    });
  }

  void _setMode(bool vsAi) {
    setState(() {
      _cancelAiTimer();
      _vsAi = vsAi;
      _game = Game.start();
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

  Widget _buildBoard(bool boardEnabled) {
    return Flexible(
      child: AspectRatio(
        aspectRatio: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: BoardWidget(
            board: _game.board,
            winningLine: _game.board.winningLine,
            onCellTap: boardEnabled ? _onCellTap : null,
          ),
        ),
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
          const SizedBox(height: 24),
          Text(_statusText, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          _buildBoard(boardEnabled),
          const SizedBox(height: 16),
          FilledButton(onPressed: _reset, child: const Text('New Game')),
        ],
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, bool boardEnabled) {
    final theme = Theme.of(context);
    const sidebarWidth = 180.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mirror spacer — keeps the board visually centred
        const SizedBox(width: sidebarWidth),

        // Board area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_statusText, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 24),
                _buildBoard(boardEnabled),
              ],
            ),
          ),
        ),

        // Right sidebar
        Container(
          width: sidebarWidth,
          decoration: const BoxDecoration(
            color: Color(0xFF252540),
            border: Border(
              left: BorderSide(color: Color(0xFF5A5A7A)),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 32),
              const Divider(color: Color(0xFF5A5A7A)),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _reset,
                child: const Text('New Game'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final boardEnabled = !_game.isOver && !_aiThinking && !_isAiTurn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: const Color(0xFF252540),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return _buildWideLayout(context, boardEnabled);
            }
            return _buildNarrowLayout(context, boardEnabled);
          },
        ),
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
