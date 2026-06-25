// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
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

  void _onCellTap(int index) {
    setState(() {
      _game = _game.move(index);
    });
  }

  void _reset() {
    setState(() {
      _game = _game.reset();
    });
  }

  String get _statusText {
    switch (_game.status) {
      case GameStatus.playing:
        return "${_game.currentPlayer.label}'s turn";
      case GameStatus.xWins:
        return 'X wins!';
      case GameStatus.oWins:
        return 'O wins!';
      case GameStatus.draw:
        return 'Draw!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      onCellTap: _game.isOver ? null : _onCellTap,
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
