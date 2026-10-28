// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';

import '../game/session_timer.dart';

/// Compact health-awareness bar shown at the top of the game in the apps.
///
/// Displays elapsed play time and a countdown to the next recommended break,
/// and shows the 20-minute eye-break note and the 60-minute break dialog.
/// Colour shifts from teal → amber → red as the break approaches.
class SessionBar extends StatefulWidget {
  final SessionTimer timer;
  const SessionBar({super.key, required this.timer});

  /// Height of the bar, for layouts that budget their space.
  static const height = 28.0;

  @override
  State<SessionBar> createState() => _SessionBarState();
}

class _SessionBarState extends State<SessionBar> {
  bool _dialogOpen = false;

  SessionTimer get _timer => widget.timer;

  @override
  void initState() {
    super.initState();
    _timer.addListener(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onTick());
  }

  @override
  void dispose() {
    _timer.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    if (_timer.shouldFireEyeBreak) {
      _timer.acknowledgeEyeBreak();
      _showEyeBreak();
    }
    if (_timer.shouldFireSessionLimit && !_dialogOpen) {
      _showSessionLimit();
    }
  }

  void _showEyeBreak() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 8),
        content: Row(
          children: [
            Icon(Icons.visibility_outlined, color: AppverseColors.amber),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '20-20-20 eye break: look at something 20 feet away for '
                '20 seconds.',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSessionLimit() async {
    _dialogOpen = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.health_and_safety, size: 36),
        title: const Text('Time for a break!'),
        content: const Text(
          "You've been playing for 60 minutes.\n\n"
          'Health guidelines recommend taking a proper break: stand up, '
          'stretch, and rest your eyes before continuing.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _timer.dismissSessionLimit();
            },
            child: const Text('Continue anyway'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _timer.acknowledgeSessionLimit();
            },
            icon: const Icon(Icons.self_improvement, size: 18),
            label: const Text('Take a break'),
          ),
        ],
      ),
    );
    _dialogOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _timer,
      builder: (context, _) {
        final state = _timer.state;
        final scheme = Theme.of(context).colorScheme;
        final fg = switch (state) {
          HealthState.safe => scheme.tertiary,
          HealthState.warning =>
            scheme.brightness == Brightness.dark
                ? AppverseColors.amber
                : const Color(0xFF8A5A12),
          HealthState.eyeBreakDue ||
          HealthState.sessionLimitDue => scheme.error,
        };

        final breakText =
            state == HealthState.eyeBreakDue ||
                state == HealthState.sessionLimitDue
            ? 'Take a break!'
            : 'break in ${formatDuration(_timer.timeUntilBreak)}';
        final style = TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        );

        return AnimatedContainer(
          key: const Key('sessionBar'),
          duration: const Duration(milliseconds: 400),
          height: SessionBar.height,
          color: fg.withValues(alpha: 0.12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.health_and_safety_outlined, size: 15, color: fg),
                const SizedBox(width: 6),
                Text('${formatDuration(_timer.elapsed)} played', style: style),
                Container(
                  width: 1,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: fg.withValues(alpha: 0.4),
                ),
                _PulsingDot(color: fg, pulse: state == HealthState.warning),
                const SizedBox(width: 5),
                Text(breakText, style: style),
              ],
            ),
          ),
        );
      },
    );
  }
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
      value: 1.0,
    );
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
