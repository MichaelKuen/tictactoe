// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game/ai.dart';
import 'package:tictactoe/game/board.dart';
import 'package:tictactoe/game/difficulty.dart';
import 'package:tictactoe/game/player.dart';

Board _board(List<String> spec) {
  var b = Board.empty();
  for (var i = 0; i < 9; i++) {
    if (spec[i] == 'X') b = b.move(i, Player.x);
    if (spec[i] == 'O') b = b.move(i, Player.o);
  }
  return b;
}

void main() {
  group('AiPlayer.bestMove()', () {
    test('takes an immediate winning move', () {
      // O can win at index 2: O O _
      //                       X X _
      //                       _ _ _
      final board = _board(['O', 'O', '.', 'X', 'X', '.', '.', '.', '.']);
      expect(AiPlayer.bestMove(board, Player.o), 2);
    });

    test('blocks the human from winning', () {
      // X can win at index 2 unless O blocks: X X _
      //                                       O _ _
      //                                       _ _ _
      final board = _board(['X', 'X', '.', 'O', '.', '.', '.', '.', '.']);
      expect(AiPlayer.bestMove(board, Player.o), 2);
    });

    test('prefers winning over blocking', () {
      // O can win at 6; X would win at 2 — AI should win, not block.
      // O O _   X X _
      // _ _ _   _ _ _
      // O _ _
      final board = _board(['O', 'O', '.', 'X', 'X', '.', 'O', '.', '.']);
      expect(AiPlayer.bestMove(board, Player.o), 2);
    });

    test('returns a valid index on an empty board', () {
      final index = AiPlayer.bestMove(Board.empty(), Player.x);
      expect(index, inInclusiveRange(0, 8));
    });

    test('returns a valid cell index on a nearly full board', () {
      // Only cell 8 is empty.
      final board = _board(['X', 'O', 'X', 'O', 'X', 'O', 'O', 'X', '.']);
      expect(AiPlayer.bestMove(board, Player.o), 8);
    });

    test('never loses — O draws or wins against every X first move', () {
      for (var firstMove = 0; firstMove < 9; firstMove++) {
        var board = Board.empty().move(firstMove, Player.x);
        // Alternate: O plays minimax, X plays minimax.
        var turn = Player.o;
        while (!board.isTerminal) {
          board = board.move(AiPlayer.bestMove(board, turn), turn);
          if (board.isTerminal) break;
          turn = turn.opponent;
        }
        expect(board.winner, isNot(Player.x),
            reason: 'AI (O) lost when X opened at $firstMove');
      }
    });
  });

  group('AiPlayer.move() — difficulty', () {
    test('easy returns a valid empty cell', () {
      final board = _board(['X', 'O', '.', '.', 'X', '.', '.', '.', '.']);
      for (var i = 0; i < 20; i++) {
        final idx = AiPlayer.move(board, Player.o, Difficulty.easy);
        expect(board.emptyCells, contains(idx));
      }
    });

    test('medium always returns a valid empty cell', () {
      final board = _board(['X', '.', '.', '.', 'O', '.', '.', '.', 'X']);
      for (var i = 0; i < 20; i++) {
        final idx = AiPlayer.move(board, Player.o, Difficulty.medium);
        expect(board.emptyCells, contains(idx));
      }
    });

    test('hard returns the same as bestMove', () {
      final board = _board(['O', 'O', '.', 'X', 'X', '.', '.', '.', '.']);
      expect(
        AiPlayer.move(board, Player.o, Difficulty.hard),
        AiPlayer.bestMove(board, Player.o),
      );
    });

    test('returns -1 when board is full', () {
      final board = _board(['X', 'O', 'X', 'O', 'X', 'O', 'O', 'X', 'O']);
      expect(AiPlayer.move(board, Player.o, Difficulty.hard), -1);
    });
  });
}
