// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../game/player.dart';

class CellWidget extends StatelessWidget {
  final Player? player;
  final VoidCallback? onTap;
  final bool highlighted;
  final bool hinted;

  const CellWidget({
    super.key,
    required this.player,
    this.onTap,
    this.highlighted = false,
    this.hinted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = player == Player.x
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    final Color bgColor;
    final Color borderColor;
    final double borderWidth;

    if (highlighted) {
      bgColor = const Color(0x44FFD740);
      borderColor = const Color(0xFFFFD740);
      borderWidth = 2.5;
    } else if (hinted) {
      bgColor = const Color(0x4469F0AE);
      borderColor = const Color(0xFF69F0AE);
      borderWidth = 2.5;
    } else {
      bgColor = const Color(0xFF252540);
      borderColor = theme.colorScheme.outline;
      borderWidth = 1;
    }

    return GestureDetector(
      onTap: player == null ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: player != null
              ? Text(
                  player!.label,
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
