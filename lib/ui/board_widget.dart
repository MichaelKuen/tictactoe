// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../game/board.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  final Board board;
  final void Function(int index)? onCellTap;
  final List<int>? winningLine;
  final int? hintCell;
  final int? cursorCell;

  const BoardWidget({
    super.key,
    required this.board,
    this.onCellTap,
    this.winningLine,
    this.hintCell,
    this.cursorCell,
  });

  @override
  Widget build(BuildContext context) {
    // Plain rows and columns rather than a GridView, so the board is never a
    // scrollable and always fills the square it is given.
    return AspectRatio(
      aspectRatio: 1,
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
  }

  Widget _cell(int index) => CellWidget(
        key: ValueKey('cell_$index'),
        player: board[index],
        highlighted: winningLine?.contains(index) ?? false,
        hinted: hintCell == index,
        focused: cursorCell == index,
        onTap: onCellTap != null ? () => onCellTap!(index) : null,
      );
}
