// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../game/score.dart';

/// Scoreboard showing X wins | draws | O wins for the current game mode.
///
/// [vsAi] controls the labels shown: YOU / AI (true) or X / O (false).
class ScoreWidget extends StatelessWidget {
  final Score score;
  final bool vsAi;
  final VoidCallback onReset;

  const ScoreWidget({
    super.key,
    required this.score,
    required this.vsAi,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E38) : const Color(0xFFF0F0F0);
    final border = isDark ? const Color(0xFF3A3A5A) : const Color(0xFFD0D0D0);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _ScoreCell(
              label: vsAi ? 'YOU' : 'X',
              value: score.xWins,
              color: theme.colorScheme.primary,
            ),
          ),
          _VerticalDivider(color: border),
          Expanded(
            child: _ScoreCell(
              label: 'DRAW',
              value: score.draws,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
            ),
          ),
          _VerticalDivider(color: border),
          Expanded(
            child: _ScoreCell(
              label: vsAi ? 'AI' : 'O',
              value: score.oWins,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onReset,
            child: Tooltip(
              message: 'Reset scores',
              child: Icon(
                Icons.refresh,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreCell extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '$value',
            key: ValueKey('${label}_$value'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;
  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: color,
    );
  }
}
