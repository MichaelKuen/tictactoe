// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'ai.dart';
import 'game.dart';
import 'game_status.dart';
import 'player.dart';

/// A plain-words explanation of the move to [index], played from [before].
String describe(Game before, int index) {
  final side = before.currentPlayer;
  final enemy = side.opponent;
  final after = before.move(index);
  final buf = StringBuffer(
    '${side.label} plays the ${squareNames[index]} square.',
  );
  switch (after.status) {
    case GameStatus.xWins:
    case GameStatus.oWins:
      final (_, name) = lines.firstWhere(
        (l) =>
            l.$1.contains(index) && l.$1.every((i) => after.board[i] == side),
      );
      buf.write(' That is three in a row on the $name: ${side.label} wins!');
    case GameStatus.draw:
      buf.write(' The board is full and nobody has three in a row: a draw.');
    case GameStatus.playing:
      final threats = threatsOf(after.board, side);
      final counter = threatsOf(after.board, enemy);
      if (counter.isNotEmpty) {
        final gap = gapOf(after.board, counter.first.$1);
        buf.write(
          ' But ${enemy.label} can win at once on the ${counter.first.$2} '
          'by taking the ${squareNames[gap]} square.',
        );
      } else if (threats.length >= 2) {
        buf.write(
          ' ${side.label} now threatens the ${threats[0].$2} and the '
          '${threats[1].$2}. ${enemy.label} can only block one of them.',
        );
      } else if (threats.length == 1) {
        final gap = gapOf(after.board, threats.first.$1);
        buf.write(
          ' ${side.label} threatens to win on the ${threats.first.$2}, so '
          '${enemy.label} must take the ${squareNames[gap]} square next.',
        );
      }
  }
  return buf.toString();
}

/// How long a comment stays on screen at normal speed: a moment to look at
/// the board, plus time to read every word.
Duration readingTime(String text) {
  final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  return Duration(milliseconds: 1200 + 300 * words);
}
