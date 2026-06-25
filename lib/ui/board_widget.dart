// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../game/board.dart';
import 'cell_widget.dart';

class BoardWidget extends StatelessWidget {
  final Board board;
  final void Function(int index)? onCellTap;
  final List<int>? winningLine;

  const BoardWidget({
    super.key,
    required this.board,
    this.onCellTap,
    this.winningLine,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemCount: 9,
        itemBuilder: (_, index) => CellWidget(
          key: ValueKey('cell_$index'),
          player: board[index],
          highlighted: winningLine?.contains(index) ?? false,
          onTap: onCellTap != null ? () => onCellTap!(index) : null,
        ),
      ),
    );
  }
}
