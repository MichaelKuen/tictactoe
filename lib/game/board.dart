// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.

import 'player.dart';

const _winLines = [
  [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
  [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
  [0, 4, 8], [2, 4, 6],             // diagonals
];

class Board {
  final List<Player?> cells;

  Board._(List<Player?> cells) : cells = List.unmodifiable(cells);

  factory Board.empty() => Board._(List.filled(9, null));

  Player? operator [](int index) => cells[index];

  bool canMove(int index) =>
      index >= 0 && index < 9 && cells[index] == null;

  Board move(int index, Player player) {
    if (!canMove(index)) return this;
    final next = List<Player?>.from(cells);
    next[index] = player;
    return Board._(next);
  }

  Player? get winner {
    for (final line in _winLines) {
      final a = cells[line[0]];
      if (a != null && a == cells[line[1]] && a == cells[line[2]]) return a;
    }
    return null;
  }

  bool get isDraw => winner == null && cells.every((c) => c != null);

  bool get isTerminal => winner != null || isDraw;

  List<int> get emptyCells =>
      [for (var i = 0; i < 9; i++) if (cells[i] == null) i];

  @override
  String toString() {
    final s = cells.map((c) => c == null ? '.' : c.label).toList();
    return '${s[0]}|${s[1]}|${s[2]}\n${s[3]}|${s[4]}|${s[5]}\n${s[6]}|${s[7]}|${s[8]}';
  }
}
