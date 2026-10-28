// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';

import '../game/board.dart';
import 'cell_widget.dart';

/// The 3×3 board: a navy tray with a thin amber edge, the same in light and
/// dark mode.
class BoardView extends StatelessWidget {
  final Board board;
  final void Function(int index)? onCellTap;
  final List<int>? winningLine;
  final int? lastMove;
  final int? hintCell;
  final int? cursorCell;

  /// Pulse the winning line; off for still pictures.
  final bool pulse;

  const BoardView({
    super.key,
    required this.board,
    this.onCellTap,
    this.winningLine,
    this.lastMove,
    this.hintCell,
    this.cursorCell,
    this.pulse = true,
  });

  @override
  Widget build(BuildContext context) {
    // Plain rows and columns rather than a GridView, so the board is never a
    // scrollable and always fills the square it is given.
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pad = constraints.maxWidth * 0.02;
          return Container(
            padding: EdgeInsets.all(pad),
            decoration: BoxDecoration(
              color: AppverseColors.navy,
              borderRadius: BorderRadius.circular(pad * 4),
              border: Border.all(color: AppverseColors.amber, width: 2),
            ),
            child: Column(
              children: [
                for (var row = 0; row < 3; row++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var col = 0; col < 3; col++)
                          Expanded(child: _cell(row * 3 + col)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cell(int index) => CellWidget(
    key: ValueKey('cell_$index'),
    player: board[index],
    highlighted: winningLine?.contains(index) ?? false,
    pulse: pulse,
    last: lastMove == index,
    hinted: hintCell == index,
    focused: cursorCell == index,
    onTap: onCellTap != null ? () => onCellTap!(index) : null,
  );
}
