// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';

import '../game/score.dart';

/// Scoreboard showing wins | draws | wins for the current game mode.
///
/// [vsComputer] controls the labels shown: YOU / COMPUTER (true) or X / O
/// (false).
class ScoreWidget extends StatelessWidget {
  final Score score;
  final bool vsComputer;
  final VoidCallback onReset;

  const ScoreWidget({
    super.key,
    required this.score,
    required this.vsComputer,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = scheme.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: _ScoreCell(
              label: vsComputer ? 'YOU' : 'X',
              value: score.xWins,
              color: scheme.onSurface,
            ),
          ),
          _VerticalDivider(color: border),
          Expanded(
            child: _ScoreCell(
              label: 'DRAW',
              value: score.draws,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          _VerticalDivider(color: border),
          Expanded(
            child: _ScoreCell(
              label: vsComputer ? 'COMPUTER' : 'O',
              value: score.oWins,
              color: scheme.tertiary,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            key: const Key('resetScores'),
            tooltip: 'Reset scores',
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            onPressed: onReset,
            icon: Icon(
              Icons.restart_alt,
              color: scheme.onSurface.withValues(alpha: 0.5),
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: color,
            ),
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
