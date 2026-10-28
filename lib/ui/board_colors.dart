// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';

/// Optional board colours. When a theme does not provide this extension the
/// cells fall back to their original (mobile) colours.
@immutable
class BoardColors extends ThemeExtension<BoardColors> {
  final Color cell;
  final Color highlight;
  final Color highlightFill;
  final Color cursor;

  const BoardColors({
    required this.cell,
    required this.highlight,
    required this.highlightFill,
    required this.cursor,
  });

  @override
  BoardColors copyWith({
    Color? cell,
    Color? highlight,
    Color? highlightFill,
    Color? cursor,
  }) =>
      BoardColors(
        cell: cell ?? this.cell,
        highlight: highlight ?? this.highlight,
        highlightFill: highlightFill ?? this.highlightFill,
        cursor: cursor ?? this.cursor,
      );

  @override
  BoardColors lerp(BoardColors? other, double t) {
    if (other == null) return this;
    return BoardColors(
      cell: Color.lerp(cell, other.cell, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      highlightFill: Color.lerp(highlightFill, other.highlightFill, t)!,
      cursor: Color.lerp(cursor, other.cursor, t)!,
    );
  }
}
