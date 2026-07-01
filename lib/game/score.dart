// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

/// Immutable snapshot of the win/draw/loss record for one game mode.
class Score {
  final int xWins;
  final int oWins;
  final int draws;

  const Score({this.xWins = 0, this.oWins = 0, this.draws = 0});

  Score copyWithXWin() => Score(xWins: xWins + 1, oWins: oWins, draws: draws);
  Score copyWithOWin() => Score(xWins: xWins, oWins: oWins + 1, draws: draws);
  Score copyWithDraw() => Score(xWins: xWins, oWins: oWins, draws: draws + 1);
  Score get reset => const Score();
}
