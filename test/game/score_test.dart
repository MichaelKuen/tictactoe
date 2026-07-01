// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/game/score.dart';

void main() {
  group('Score', () {
    test('starts at zero', () {
      const s = Score();
      expect(s.xWins, 0);
      expect(s.oWins, 0);
      expect(s.draws, 0);
    });

    test('copyWithXWin increments only xWins', () {
      const s = Score(xWins: 1, oWins: 2, draws: 3);
      final next = s.copyWithXWin();
      expect(next.xWins, 2);
      expect(next.oWins, 2);
      expect(next.draws, 3);
    });

    test('copyWithOWin increments only oWins', () {
      const s = Score(xWins: 1, oWins: 2, draws: 3);
      final next = s.copyWithOWin();
      expect(next.xWins, 1);
      expect(next.oWins, 3);
      expect(next.draws, 3);
    });

    test('copyWithDraw increments only draws', () {
      const s = Score(xWins: 1, oWins: 2, draws: 3);
      final next = s.copyWithDraw();
      expect(next.xWins, 1);
      expect(next.oWins, 2);
      expect(next.draws, 4);
    });

    test('reset returns all-zero Score', () {
      const s = Score(xWins: 5, oWins: 3, draws: 2);
      final r = s.reset;
      expect(r.xWins, 0);
      expect(r.oWins, 0);
      expect(r.draws, 0);
    });

    test('chaining increments accumulates correctly', () {
      var s = const Score();
      s = s.copyWithXWin().copyWithXWin().copyWithOWin().copyWithDraw();
      expect(s.xWins, 2);
      expect(s.oWins, 1);
      expect(s.draws, 1);
    });

    test('Score is immutable — original unchanged after copy', () {
      const s = Score(xWins: 1, oWins: 0, draws: 0);
      s.copyWithXWin();
      expect(s.xWins, 1);
    });
  });
}
