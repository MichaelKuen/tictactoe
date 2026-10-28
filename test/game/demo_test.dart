// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game/ai.dart';
import 'package:tictactoe/game/demo.dart';
import 'package:tictactoe/game/difficulty.dart';
import 'package:tictactoe/game/game.dart';
import 'package:tictactoe/game/player.dart';

Game _play(List<int> moves) => moves.fold(Game.start(), (g, m) => g.move(m));

void main() {
  test('a quiet move names the square', () {
    expect(describe(Game.start(), 4), 'X plays the centre square.');
  });

  test('a threat says where the opponent must block', () {
    final g = _play([0, 4]);
    expect(
      describe(g, 1),
      'X plays the top middle square. X threatens to win on the top row, so '
      'O must take the top right square next.',
    );
  });

  test('a threat while the opponent can win says so', () {
    // O threatens the middle row; X makes its own threat instead of blocking.
    final g = _play([0, 4, 8, 3]);
    expect(
      describe(g, 2),
      contains(
        'But O can win at once on the middle row by taking the '
        'middle right square.',
      ),
    );
  });

  test('a fork names both lines', () {
    final g = _play([0, 1, 6, 8]);
    expect(describe(g, 4), contains('O can only block one of them'));
  });

  test('a win names the line', () {
    final g = _play([0, 3, 1, 4]);
    expect(
      describe(g, 2),
      'X plays the top right square. That is three in a row on the top row: '
      'X wins!',
    );
  });

  test('a draw says the board is full', () {
    final g = _play([0, 1, 2, 4, 3, 5, 7, 6]);
    expect(describe(g, 8), contains('a draw'));
  });

  test('demo games finish at every level with a reason for every move', () {
    final rng = Random(1);
    for (final x in Difficulty.values) {
      for (final o in Difficulty.values) {
        for (var n = 0; n < 10; n++) {
          var g = Game.start();
          while (!g.isOver) {
            final level = g.currentPlayer == Player.x ? x : o;
            final d = AiPlayer.decide(
              g.board,
              g.currentPlayer,
              level,
              random: rng,
            );
            expect(g.board.canMove(d.move), isTrue);
            expect(d.reason, isNotEmpty);
            expect(describe(g, d.move), isNotEmpty);
            g = g.move(d.move);
          }
        }
      }
    }
  });

  test('reading time grows with the words', () {
    expect(readingTime('one two'), const Duration(milliseconds: 1800));
  });
}
