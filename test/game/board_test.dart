// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game/board.dart';
import 'package:tictactoe/game/player.dart';

void main() {
  group('Board.empty()', () {
    test('all cells are null', () {
      final board = Board.empty();
      for (var i = 0; i < 9; i++) {
        expect(board[i], isNull);
      }
    });

    test('all moves are valid', () {
      final board = Board.empty();
      for (var i = 0; i < 9; i++) {
        expect(board.canMove(i), isTrue);
      }
    });

    test('out-of-range index is not a valid move', () {
      final board = Board.empty();
      expect(board.canMove(-1), isFalse);
      expect(board.canMove(9), isFalse);
    });

    test('has no winner', () => expect(Board.empty().winner, isNull));
    test('is not a draw', () => expect(Board.empty().isDraw, isFalse));
    test('is not terminal', () => expect(Board.empty().isTerminal, isFalse));
    test('emptyCells returns all 9 indices', () {
      expect(Board.empty().emptyCells, List.generate(9, (i) => i));
    });
  });

  group('Board.move()', () {
    test('places the player in the correct cell', () {
      final board = Board.empty().move(4, Player.x);
      expect(board[4], Player.x);
    });

    test('does not mutate other cells', () {
      final board = Board.empty().move(4, Player.x);
      for (var i = 0; i < 9; i++) {
        if (i != 4) expect(board[i], isNull);
      }
    });

    test('move on occupied cell returns same board', () {
      final board = Board.empty().move(4, Player.x);
      final same = board.move(4, Player.o);
      expect(same[4], Player.x);
    });

    test('move on out-of-range index returns same board', () {
      final board = Board.empty();
      expect(board.move(-1, Player.x), same(board));
      expect(board.move(9, Player.x), same(board));
    });

    test('canMove returns false for occupied cell', () {
      final board = Board.empty().move(0, Player.x);
      expect(board.canMove(0), isFalse);
    });

    test('emptyCells shrinks after each move', () {
      final board = Board.empty().move(0, Player.x).move(8, Player.o);
      expect(board.emptyCells, isNot(contains(0)));
      expect(board.emptyCells, isNot(contains(8)));
      expect(board.emptyCells.length, 7);
    });
  });

  group('Board winner detection', () {
    Board xWinsAt(List<int> indices) {
      var b = Board.empty();
      for (final i in indices) {
        b = b.move(i, Player.x);
      }
      return b;
    }

    test('row 0: X wins [0,1,2]', () => expect(xWinsAt([0, 1, 2]).winner, Player.x));
    test('row 1: X wins [3,4,5]', () => expect(xWinsAt([3, 4, 5]).winner, Player.x));
    test('row 2: X wins [6,7,8]', () => expect(xWinsAt([6, 7, 8]).winner, Player.x));
    test('col 0: X wins [0,3,6]', () => expect(xWinsAt([0, 3, 6]).winner, Player.x));
    test('col 1: X wins [1,4,7]', () => expect(xWinsAt([1, 4, 7]).winner, Player.x));
    test('col 2: X wins [2,5,8]', () => expect(xWinsAt([2, 5, 8]).winner, Player.x));
    test('diag: X wins [0,4,8]', () => expect(xWinsAt([0, 4, 8]).winner, Player.x));
    test('anti-diag: X wins [2,4,6]', () => expect(xWinsAt([2, 4, 6]).winner, Player.x));

    test('O can also win', () {
      var b = Board.empty()
          .move(0, Player.o)
          .move(1, Player.o)
          .move(2, Player.o);
      expect(b.winner, Player.o);
    });

    test('partial row is not a win', () {
      final b = Board.empty().move(0, Player.x).move(1, Player.x);
      expect(b.winner, isNull);
    });

    test('mixed row is not a win', () {
      final b = Board.empty()
          .move(0, Player.x)
          .move(1, Player.o)
          .move(2, Player.x);
      expect(b.winner, isNull);
    });
  });

  group('Board draw detection', () {
    // X O X
    // O O X
    // X X O  — no winner, all cells filled
    Board drawBoard() {
      return Board.empty()
          .move(0, Player.x)
          .move(1, Player.o)
          .move(2, Player.x)
          .move(3, Player.o)
          .move(4, Player.o)
          .move(5, Player.x)
          .move(6, Player.x)
          .move(7, Player.x)
          .move(8, Player.o);
    }

    test('full board with no winner is a draw', () {
      expect(drawBoard().isDraw, isTrue);
    });

    test('draw board is terminal', () {
      expect(drawBoard().isTerminal, isTrue);
    });

    test('partial board is not a draw', () {
      expect(Board.empty().isDraw, isFalse);
    });

    test('winning board is not a draw', () {
      final b = Board.empty().move(0, Player.x).move(1, Player.x).move(2, Player.x);
      expect(b.isDraw, isFalse);
    });
  });

  group('Board.isTerminal', () {
    test('true when there is a winner', () {
      final b = Board.empty().move(0, Player.x).move(1, Player.x).move(2, Player.x);
      expect(b.isTerminal, isTrue);
    });

    test('false while game is still in progress', () {
      final b = Board.empty().move(0, Player.x).move(4, Player.o);
      expect(b.isTerminal, isFalse);
    });
  });

  group('Board.winningLine', () {
    test('null on empty board', () {
      expect(Board.empty().winningLine, isNull);
    });

    test('null mid-game with no winner', () {
      final b = Board.empty().move(0, Player.x).move(4, Player.o);
      expect(b.winningLine, isNull);
    });

    test('returns [0,1,2] when top row wins', () {
      final b = Board.empty()
          .move(0, Player.x)
          .move(1, Player.x)
          .move(2, Player.x);
      expect(b.winningLine, equals([0, 1, 2]));
    });

    test('returns [0,4,8] for main diagonal', () {
      final b = Board.empty()
          .move(0, Player.x)
          .move(4, Player.x)
          .move(8, Player.x);
      expect(b.winningLine, equals([0, 4, 8]));
    });

    test('null on a draw board', () {
      final b = Board.empty()
          .move(0, Player.x).move(1, Player.o).move(2, Player.x)
          .move(3, Player.o).move(4, Player.o).move(5, Player.x)
          .move(6, Player.x).move(7, Player.x).move(8, Player.o);
      expect(b.winningLine, isNull);
    });
  });
}
