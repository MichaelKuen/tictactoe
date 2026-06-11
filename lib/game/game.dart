// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'board.dart';
import 'game_status.dart';
import 'player.dart';

class Game {
  final Board board;
  final Player currentPlayer;
  final GameStatus status;

  const Game._({
    required this.board,
    required this.currentPlayer,
    required this.status,
  });

  factory Game.start() => Game._(
        board: Board.empty(),
        currentPlayer: Player.x,
        status: GameStatus.playing,
      );

  bool get isOver => status != GameStatus.playing;

  Game move(int index) {
    if (isOver || !board.canMove(index)) return this;

    final next = board.move(index, currentPlayer);
    final winner = next.winner;

    final GameStatus newStatus;
    if (winner == Player.x) {
      newStatus = GameStatus.xWins;
    } else if (winner == Player.o) {
      newStatus = GameStatus.oWins;
    } else if (next.isDraw) {
      newStatus = GameStatus.draw;
    } else {
      newStatus = GameStatus.playing;
    }

    return Game._(
      board: next,
      currentPlayer: newStatus == GameStatus.playing
          ? currentPlayer.opponent
          : currentPlayer,
      status: newStatus,
    );
  }

  Game reset() => Game.start();
}
