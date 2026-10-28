// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';

import '../game/player.dart';

/// Mark colours on the navy board: ivory X, amber O.
Color markColor(Player player) =>
    player == Player.x ? AppverseColors.ivory : AppverseColors.amber;

class CellWidget extends StatefulWidget {
  final Player? player;
  final VoidCallback? onTap;

  /// Part of the winning line.
  final bool highlighted;

  /// The square played last.
  final bool last;
  final bool hinted;

  /// Keyboard cursor is on this cell.
  final bool focused;

  /// Pulse while [highlighted].
  final bool pulse;

  const CellWidget({
    super.key,
    required this.player,
    this.onTap,
    this.highlighted = false,
    this.last = false,
    this.hinted = false,
    this.focused = false,
    this.pulse = true,
  });

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget> with TickerProviderStateMixin {
  // Declared late, assigned in initState so vsync is never accessed lazily.
  late final AnimationController _placeCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _placeScale;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _placeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _placeScale = CurvedAnimation(parent: _placeCtrl, curve: Curves.elasticOut);
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    // Cell already occupied on first build (e.g. hot-reload) — skip animation.
    if (widget.player != null) _placeCtrl.value = 1.0;
    if (widget.highlighted && widget.pulse) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CellWidget old) {
    super.didUpdateWidget(old);
    if (widget.player != null && old.player == null) {
      _placeCtrl.forward(from: 0);
    }
    if (widget.highlighted && !old.highlighted && widget.pulse) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.highlighted && old.highlighted) {
      _pulseCtrl.animateTo(0, duration: const Duration(milliseconds: 200));
    }
    if (widget.player == null && old.player != null) {
      _placeCtrl.stop();
      _placeCtrl.reset();
    }
  }

  @override
  void dispose() {
    _placeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  static const _line = Color(0xFF3B3F6B);

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final double borderWidth;

    if (widget.highlighted) {
      bgColor = AppverseColors.tealLight.withValues(alpha: 0.3);
      borderColor = AppverseColors.tealLight;
      borderWidth = 3;
    } else if (widget.hinted) {
      bgColor = AppverseColors.tealLight.withValues(alpha: 0.18);
      borderColor = AppverseColors.tealLight;
      borderWidth = 3;
    } else if (widget.focused) {
      bgColor = AppverseColors.navySurface;
      borderColor = AppverseColors.ivory;
      borderWidth = 3;
    } else if (widget.last) {
      bgColor = AppverseColors.navySurface;
      borderColor = AppverseColors.amber;
      borderWidth = 2;
    } else {
      bgColor = AppverseColors.navySurface;
      borderColor = _line;
      borderWidth = 1;
    }

    final cell = GestureDetector(
      onTap: widget.player == null ? widget.onTap : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: widget.player != null
              ? LayoutBuilder(
                  // Glyph scales with the cell so it never overflows small
                  // boards and fills large ones.
                  builder: (context, constraints) => ScaleTransition(
                    scale: _placeScale,
                    child: Text(
                      widget.player!.label,
                      style: TextStyle(
                        color: markColor(widget.player!),
                        fontWeight: FontWeight.bold,
                        fontSize: constraints.biggest.shortestSide * 0.5,
                        height: 1.0,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );

    if (widget.highlighted) {
      return ScaleTransition(scale: _pulseScale, child: cell);
    }
    return cell;
  }
}

/// A mark on a small tile of board colour, so it shows on both the ivory and
/// the dark page (status line, move log, scores).
class MarkTile extends StatelessWidget {
  const MarkTile(this.player, {super.key, this.size = 22});

  final Player player;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppverseColors.navy,
      borderRadius: BorderRadius.circular(size * 0.22),
      border: Border.all(color: AppverseColors.amber, width: 1),
    ),
    child: Text(
      player.label,
      style: TextStyle(
        color: markColor(player),
        fontWeight: FontWeight.bold,
        fontSize: size * 0.62,
        height: 1.0,
      ),
    ),
  );
}
