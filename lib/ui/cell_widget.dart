// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../game/player.dart';

class CellWidget extends StatefulWidget {
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
    _pulseScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    // Cell already occupied on first build (e.g. hot-reload) — skip animation.
    if (widget.player != null) _placeCtrl.value = 1.0;
    if (widget.highlighted) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CellWidget old) {
    super.didUpdateWidget(old);
    if (widget.player != null && old.player == null) {
      _placeCtrl.forward(from: 0);
    }
    if (widget.highlighted && !old.highlighted) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final playerColor = widget.player == Player.x
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    final Color bgColor;
    final Color borderColor;
    final double borderWidth;

    if (widget.highlighted) {
      bgColor = const Color(0x44FFD740);
      borderColor = const Color(0xFFFFD740);
      borderWidth = 2.5;
    } else if (widget.hinted) {
      bgColor = const Color(0x4469F0AE);
      borderColor = const Color(0xFF69F0AE);
      borderWidth = 2.5;
    } else {
      bgColor = isDark ? const Color(0xFF252540) : Colors.white;
      borderColor = theme.colorScheme.outline;
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
              ? ScaleTransition(
                  scale: _placeScale,
                  child: Text(
                    widget.player!.label,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: playerColor,
                      fontWeight: FontWeight.bold,
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
