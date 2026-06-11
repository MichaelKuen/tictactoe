// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game/game.dart';
import 'package:tictactoe/game/game_status.dart';
import 'package:tictactoe/game/player.dart';

void main() {
  group('Game.start()', () {
    test('board is empty', () {
      final game = Game.start();
      for (var i = 0; i < 9; i++) {
        expect(game.board[i], isNull);
      }
    });

    test('X goes first', () => expect(Game.start().currentPlayer, Player.x));
    test('status is playing', () => expect(Game.start().status, GameStatus.playing));
    test('isOver is false', () => expect(Game.start().isOver, isFalse));
  });

  group('Game.move() — turn alternation', () {
    test('after X moves, current player is O', () {
      final game = Game.start().move(0);
      expect(game.currentPlayer, Player.o);
      expect(game.board[0], Player.x);
    });

    test('after X then O, current player is X again', () {
      final game = Game.start().move(0).move(1);
      expect(game.currentPlayer, Player.x);
      expect(game.board[1], Player.o);
    });

    test('move on occupied cell is a no-op', () {
      final before = Game.start().move(0);
      final after = before.move(0);
      expect(after.board[0], Player.x);
      expect(after.currentPlayer, Player.o);
      expect(identical(before, after), isTrue);
    });

    test('move on out-of-range index is a no-op', () {
      final game = Game.start();
      expect(identical(game.move(-1), game), isTrue);
      expect(identical(game.move(9), game), isTrue);
    });
  });

  group('Game.move() — X wins', () {
    // X: 0,1,2  O: 3,4
    Game xWinsRow() =>
        Game.start().move(0).move(3).move(1).move(4).move(2);

    test('status becomes xWins', () => expect(xWinsRow().status, GameStatus.xWins));
    test('isOver becomes true', () => expect(xWinsRow().isOver, isTrue));
    test('currentPlayer stays X after win', () => expect(xWinsRow().currentPlayer, Player.x));

    test('move after game over is a no-op', () {
      final won = xWinsRow();
      final still = won.move(5);
      expect(identical(won, still), isTrue);
    });
  });

  group('Game.move() — O wins', () {
    // X: 0,1,6  O: 3,4,5
    Game oWinsRow() =>
        Game.start().move(0).move(3).move(1).move(4).move(6).move(5);

    test('status becomes oWins', () => expect(oWinsRow().status, GameStatus.oWins));
    test('isOver becomes true', () => expect(oWinsRow().isOver, isTrue));
    test('currentPlayer stays O after win', () => expect(oWinsRow().currentPlayer, Player.o));
  });

  group('Game.move() — diagonal wins', () {
    test('X wins main diagonal [0,4,8]', () {
      final game = Game.start().move(0).move(1).move(4).move(2).move(8);
      expect(game.status, GameStatus.xWins);
    });

    test('X wins anti-diagonal [2,4,6]', () {
      final game = Game.start().move(2).move(0).move(4).move(1).move(6);
      expect(game.status, GameStatus.xWins);
    });
  });

  group('Game.move() — draw', () {
    // X O X
    // O O X
    // X X O — draw
    Game drawGame() => Game.start()
        .move(0).move(1)
        .move(2).move(3)
        .move(7).move(4)
        .move(5).move(8)
        .move(6);

    test('status becomes draw', () => expect(drawGame().status, GameStatus.draw));
    test('isOver becomes true', () => expect(drawGame().isOver, isTrue));
  });

  group('Game.reset()', () {
    test('returns a fresh game after win', () {
      final reset = Game.start().move(0).move(3).move(1).move(4).move(2).reset();
      expect(reset.status, GameStatus.playing);
      expect(reset.currentPlayer, Player.x);
      for (var i = 0; i < 9; i++) {
        expect(reset.board[i], isNull);
      }
    });

    test('returns a fresh game mid-play', () {
      final reset = Game.start().move(0).move(1).reset();
      expect(reset.board[0], isNull);
      expect(reset.currentPlayer, Player.x);
    });
  });
}
