// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'dart:math';
import 'board.dart';
import 'player.dart';

class AiPlayer {
  const AiPlayer._();

  static int bestMove(Board board, Player aiPlayer) {
    int bestScore = -1000;
    int bestIndex = -1;
    for (final i in board.emptyCells) {
      final score = _minimax(board.move(i, aiPlayer), 0, false, aiPlayer);
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  static int _minimax(Board board, int depth, bool isMaximising, Player aiPlayer) {
    final winner = board.winner;
    if (winner == aiPlayer) return 10 - depth;
    if (winner == aiPlayer.opponent) return depth - 10;
    if (board.isDraw) return 0;

    final cells = board.emptyCells;
    if (isMaximising) {
      int best = -1000;
      for (final i in cells) {
        best = max(best, _minimax(board.move(i, aiPlayer), depth + 1, false, aiPlayer));
      }
      return best;
    } else {
      int best = 1000;
      for (final i in cells) {
        best = min(best, _minimax(board.move(i, aiPlayer.opponent), depth + 1, true, aiPlayer));
      }
      return best;
    }
  }
}
