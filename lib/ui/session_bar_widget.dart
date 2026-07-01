// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import '../health/session_timer.dart';

/// Compact health-awareness bar shown between the AppBar and game content.
///
/// Displays elapsed play time and a countdown to the next recommended break.
/// Colour shifts from green → amber → red as the break approaches.
class SessionBarWidget extends StatelessWidget {
  final SessionTimer timer;
  const SessionBarWidget({super.key, required this.timer});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) {
        final state = timer.state;
        final elapsed = timer.elapsed;
        final remaining = timer.timeUntilBreak;

        final colors = _resolveColors(context, state);

        final elapsedLabel = formatDuration(elapsed);
        final breakLabel = formatDuration(remaining);

        final breakText = state == HealthState.eyeBreakDue ||
                state == HealthState.sessionLimitDue
            ? 'Take a break!'
            : 'break in $breakLabel';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          color: colors.bg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety_outlined,
                  size: 15, color: colors.fg),
              const SizedBox(width: 6),
              Text(
                '$elapsedLabel played',
                style: TextStyle(
                  color: colors.fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 1,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: colors.fg.withValues(alpha: 0.4),
              ),
              _PulsingDot(color: colors.dot, pulse: state == HealthState.warning),
              const SizedBox(width: 5),
              Text(
                breakText,
                style: TextStyle(
                  color: colors.fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _BarColors _resolveColors(BuildContext context, HealthState state) {
    switch (state) {
      case HealthState.safe:
        return _BarColors(
          bg: const Color(0xFF1B3A2F),
          fg: const Color(0xFF69F0AE),
          dot: const Color(0xFF69F0AE),
        );
      case HealthState.warning:
        return _BarColors(
          bg: const Color(0xFF3A2D0A),
          fg: const Color(0xFFFFD740),
          dot: const Color(0xFFFFD740),
        );
      case HealthState.eyeBreakDue:
      case HealthState.sessionLimitDue:
        return _BarColors(
          bg: const Color(0xFF3A0F0F),
          fg: const Color(0xFFFF5252),
          dot: const Color(0xFFFF5252),
        );
    }
  }
}

class _BarColors {
  final Color bg;
  final Color fg;
  final Color dot;
  const _BarColors({required this.bg, required this.fg, required this.dot});
}

/// A small dot that pulses when [pulse] is true.
class _PulsingDot extends StatefulWidget {
  final Color color;
  final bool pulse;
  const _PulsingDot({required this.color, required this.pulse});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.pulse) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.pulse && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
