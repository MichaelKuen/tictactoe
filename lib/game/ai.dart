// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'dart:math';

import 'package:appverse_core_kit/appverse_core_kit.dart' show AiDecision;

import 'board.dart';
import 'difficulty.dart';
import 'player.dart';

final _defaultRng = Random();

/// Plain names for the nine squares, in reading order.
const squareNames = [
  'top left', 'top middle', 'top right', //
  'middle left', 'centre', 'middle right',
  'bottom left', 'bottom middle', 'bottom right',
];

/// The eight lines of three, with a name for each.
const lines = <(List<int>, String)>[
  ([0, 1, 2], 'top row'),
  ([3, 4, 5], 'middle row'),
  ([6, 7, 8], 'bottom row'),
  ([0, 3, 6], 'left column'),
  ([1, 4, 7], 'middle column'),
  ([2, 5, 8], 'right column'),
  ([0, 4, 8], 'diagonal'),
  ([2, 4, 6], 'other diagonal'),
];

/// Lines where [player] has two marks and the third square is empty.
List<(List<int>, String)> threatsOf(Board board, Player player) => [
  for (final line in lines)
    if (line.$1.where((i) => board[i] == player).length == 2 &&
        line.$1.any((i) => board[i] == null))
      line,
];

/// The empty square that completes a [threatsOf] line.
int gapOf(Board board, List<int> line) =>
    line.firstWhere((i) => board[i] == null);

class AiPlayer {
  const AiPlayer._();

  /// Returns a move index for the given [difficulty].
  ///
  /// - Easy   → always random
  /// - Medium → 35 % random, 65 % optimal (minimax)
  /// - Hard   → always optimal (minimax)
  static int move(
    Board board,
    Player aiPlayer,
    Difficulty difficulty, {
    Random? random,
  }) => decide(board, aiPlayer, difficulty, random: random).move;

  /// Chooses a move like [move] and says why, in words for the player.
  static AiDecision<int> decide(
    Board board,
    Player aiPlayer,
    Difficulty difficulty, {
    Random? random,
  }) {
    final rng = random ?? _defaultRng;
    final empties = board.emptyCells;
    if (empties.isEmpty) return const AiDecision(-1, 'The board is full');

    final guess = switch (difficulty) {
      Difficulty.easy => true,
      Difficulty.medium => rng.nextDouble() < 0.35,
      Difficulty.hard => false,
    };
    if (guess) {
      final index = empties[rng.nextInt(empties.length)];
      return AiDecision(index, explain(board, aiPlayer, index, random: true));
    }
    final index = bestMove(board, aiPlayer);
    return AiDecision(index, explain(board, aiPlayer, index));
  }

  /// Why [player] playing [index] on [board] is a good idea, tagged with the
  /// first of these that really applies: win now, block a win, make two
  /// threats (a fork), make one threat, take the centre, take a corner.
  /// [random] moves say so honestly instead.
  static String explain(
    Board board,
    Player player,
    int index, {
    bool random = false,
  }) {
    if (random) return 'Picks a free square at random';
    final opponent = player.opponent;
    final after = board.move(index, player);
    for (final (line, name) in lines) {
      if (line.contains(index) && line.every((i) => after[i] == player)) {
        return 'Completes the $name to win';
      }
    }
    for (final (line, name) in threatsOf(board, opponent)) {
      if (gapOf(board, line) == index) {
        return 'Blocks ${opponent.label} from completing the $name';
      }
    }
    final threats = threatsOf(after, player);
    if (threats.length >= 2) {
      return 'Makes two threats at once: ${opponent.label} can only block one';
    }
    if (threats.length == 1) {
      return 'Lines up two on the ${threats.first.$2}, so '
          '${opponent.label} must block';
    }
    if (index == 4) return 'Takes the centre, which is on four lines';
    if (index.isEven) return 'Takes a corner, which is on three lines';
    return 'Looking ahead, every other square is no better';
  }

  /// The best move for [aiPlayer]: the first square with the highest
  /// minimax score (win sooner, lose later).
  static int bestMove(Board board, Player aiPlayer) {
    int bestScore = -1000;
    int bestIndex = -1;
    for (final i in board.emptyCells) {
      // A full window per root move, so every score is exact and ties go to
      // the first square, as before alpha-beta was added.
      final score = _minimax(
        board.move(i, aiPlayer),
        0,
        false,
        aiPlayer,
        -1000,
        1000,
      );
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  static int _minimax(
    Board board,
    int depth,
    bool isMaximising,
    Player aiPlayer,
    int alpha,
    int beta,
  ) {
    final winner = board.winner;
    if (winner == aiPlayer) return 10 - depth;
    if (winner == aiPlayer.opponent) return depth - 10;
    if (board.isDraw) return 0;

    final cells = board.emptyCells;
    if (isMaximising) {
      var best = -1000;
      for (final i in cells) {
        best = max(
          best,
          _minimax(
            board.move(i, aiPlayer),
            depth + 1,
            false,
            aiPlayer,
            alpha,
            beta,
          ),
        );
        alpha = max(alpha, best);
        if (alpha >= beta) break;
      }
      return best;
    } else {
      var best = 1000;
      for (final i in cells) {
        best = min(
          best,
          _minimax(
            board.move(i, aiPlayer.opponent),
            depth + 1,
            true,
            aiPlayer,
            alpha,
            beta,
          ),
        );
        beta = min(beta, best);
        if (alpha >= beta) break;
      }
      return best;
    }
  }
}
