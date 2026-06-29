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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final boardEnabled = !_game.isOver && !_aiThinking && !_isAiTurn;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
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
              Text(
                _statusText,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
                    child: BoardWidget(
                      board: _game.board,
                      winningLine: _game.board.winningLine,
                      onCellTap: boardEnabled ? _onCellTap : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _reset,
                child: const Text('New Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
