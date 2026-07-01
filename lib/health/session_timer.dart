// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Health states that drive UI colour and messaging.
enum HealthState {
  /// 0–14:59 and 20:01–54:59 — safe to keep playing.
  safe,

  /// 15:00–19:59 and 55:00–59:59 — approaching a break.
  warning,

  /// Exactly at 20 minutes — eye-break notification due.
  eyeBreakDue,

  /// Exactly at 60 minutes — session-limit notification due.
  sessionLimitDue,
}

/// Tracks how long the user has been playing in the current session.
///
/// Break schedule (aligned to 20-20-20 rule + WHO/NHS guidelines):
///   20 min → eye-break reminder (snackbar, timer continues)
///   60 min → session-limit alert (dialog, timer resets on acknowledge)
///
/// Warning ramp-up:
///   15–20 min → [HealthState.warning] (amber)
///   55–60 min → [HealthState.warning] (red tint)
class SessionTimer extends ChangeNotifier {
  static const int eyeBreakSecs = 20 * 60;      // 20 minutes
  static const int sessionLimitSecs = 60 * 60;  // 60 minutes
  static const int _warnBeforeSecs = 5 * 60;    // warn 5 min before each break

  Timer? _ticker;
  int _elapsed = 0;
  bool _eyeBreakFired = false;
  bool _sessionLimitFired = false;

  int get elapsed => _elapsed;

  /// Seconds until the next scheduled break.
  int get timeUntilBreak {
    final target = _eyeBreakFired ? sessionLimitSecs : eyeBreakSecs;
    return (target - _elapsed).clamp(0, target);
  }

  HealthState get state {
    if (!_sessionLimitFired && _elapsed >= sessionLimitSecs) {
      return HealthState.sessionLimitDue;
    }
    if (!_eyeBreakFired && _elapsed >= eyeBreakSecs) {
      return HealthState.eyeBreakDue;
    }
    // Warning zone: within 5 minutes of either break
    final nextTarget = _eyeBreakFired ? sessionLimitSecs : eyeBreakSecs;
    if (_elapsed >= nextTarget - _warnBeforeSecs) {
      return HealthState.warning;
    }
    return HealthState.safe;
  }

  /// Whether the eye-break notification should fire right now.
  bool get shouldFireEyeBreak =>
      !_eyeBreakFired && _elapsed >= eyeBreakSecs && _elapsed < sessionLimitSecs;

  /// Whether the session-limit notification should fire right now.
  bool get shouldFireSessionLimit =>
      !_sessionLimitFired && _elapsed >= sessionLimitSecs;

  void start() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed++;
      notifyListeners();
    });
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// Called after the user acknowledges the eye-break snackbar.
  void acknowledgeEyeBreak() {
    _eyeBreakFired = true;
    notifyListeners();
  }

  /// Called after the user acknowledges the session-limit dialog.
  /// Resets the session so they can start fresh.
  void acknowledgeSessionLimit() {
    _elapsed = 0;
    _eyeBreakFired = false;
    _sessionLimitFired = false;
    notifyListeners();
  }

  /// Mark session limit as seen without resetting (user chose "Continue").
  void dismissSessionLimit() {
    _sessionLimitFired = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

/// Formats a duration in seconds as MM:SS.
String formatDuration(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
