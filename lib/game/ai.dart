// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'dart:math';
import 'board.dart';
import 'difficulty.dart';
import 'player.dart';

final _rng = Random();

class AiPlayer {
  const AiPlayer._();

  /// Returns a move index for the given [difficulty].
  ///
  /// - Easy   → always random
  /// - Medium → 35 % random, 65 % optimal (minimax)
  /// - Hard   → always optimal (minimax)
  static int move(Board board, Player aiPlayer, Difficulty difficulty) {
    final empties = board.emptyCells;
    if (empties.isEmpty) return -1;

    switch (difficulty) {
      case Difficulty.easy:
        return empties[_rng.nextInt(empties.length)];
      case Difficulty.medium:
        if (_rng.nextDouble() < 0.35) {
          return empties[_rng.nextInt(empties.length)];
        }
        return bestMove(board, aiPlayer);
      case Difficulty.hard:
        return bestMove(board, aiPlayer);
    }
  }

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
