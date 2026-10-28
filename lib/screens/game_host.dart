// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/game_controller.dart';
import '../game/game_setup.dart';
import '../game/score_repository.dart';
import '../game/session_timer.dart';
import 'game_page.dart';
import 'watch_page.dart';

const _soundFiles = {
  GameSound.moveX: 'sounds/move_x.wav',
  GameSound.moveO: 'sounds/move_o.wav',
  GameSound.win: 'sounds/win.wav',
  GameSound.lose: 'sounds/lose.wav',
  GameSound.draw: 'sounds/draw.wav',
};

/// Plays [sound], with a light vibration in the apps when allowed.
void playGameSound(CoreKit kit, GameSound sound, {double volume = 1}) {
  kit.sound.play(_soundFiles[sound]!, volume: volume);
  if (!kit.settings.hapticsOn || !isMobileApp) return;
  switch (sound) {
    case GameSound.moveX || GameSound.moveO:
      HapticFeedback.selectionClick();
    case GameSound.draw:
      HapticFeedback.lightImpact();
    case GameSound.win || GameSound.lose:
      HapticFeedback.mediumImpact();
  }
}

/// Shows the game in the chosen mode and starts a fresh one whenever the
/// player picks New Game or another mode. On web this is the whole app.
class GameHost extends StatefulWidget {
  const GameHost({
    super.key,
    required this.kit,
    required this.setup,
    this.sessionTimer,
  });

  final CoreKit kit;
  final GameSetup setup;

  /// Play-time reminder, shown in the apps only.
  final SessionTimer? sessionTimer;

  @override
  State<GameHost> createState() => _GameHostState();
}

class _GameHostState extends State<GameHost> {
  late GameSetup _setup = widget.setup;
  ScoreRepository? _scores;
  bool _humanFirst = true;
  bool _ready = false;
  int _round = 0;

  @override
  void initState() {
    super.initState();
    widget.kit.sound.preload(_soundFiles.values.toList());
    _init();
  }

  Future<void> _init() async {
    _scores = await ScoreRepository.create();
    await _start(widget.setup);
  }

  Future<void> _start(GameSetup setup) async {
    await setup.save();
    final humanFirst = setup.mode == GameMode.vsComputer
        ? await setup.nextHumanFirst()
        : true;
    if (!mounted) return;
    setState(() {
      _setup = setup;
      _humanFirst = humanFirst;
      _ready = true;
      _round++;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Scaffold();
    final key = ValueKey(_round);
    if (_setup.mode == GameMode.watch) {
      return WatchPage(
        key: key,
        kit: widget.kit,
        setup: _setup,
        sessionTimer: widget.sessionTimer,
        onNewGame: _start,
      );
    }
    return GamePage(
      key: key,
      kit: widget.kit,
      setup: _setup,
      humanFirst: _humanFirst,
      scores: _scores,
      sessionTimer: widget.sessionTimer,
      onNewGame: _start,
    );
  }
}
