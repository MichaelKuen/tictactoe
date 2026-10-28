// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart' show AutoPlaySpeed;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'difficulty.dart';
import 'player.dart';

enum GameMode {
  vsComputer('vs Computer'),
  twoPlayer('2 Players'),
  watch('Watch and Learn');

  const GameMode(this.label);

  final String label;
}

/// Who makes the first move against the computer. X always moves first, so
/// whoever starts plays X.
enum FirstMove {
  you('You'),
  computer('Computer'),
  alternate('Take turns');

  const FirstMove(this.label);

  final String label;
}

/// Everything chosen in the game options, saved between sessions.
@immutable
class GameSetup {
  const GameSetup({
    this.mode = GameMode.vsComputer,
    this.difficulty = Difficulty.hard,
    this.firstMove = FirstMove.you,
    this.xLevel = Difficulty.medium,
    this.oLevel = Difficulty.hard,
    this.speed = AutoPlaySpeed.normal,
  });

  final GameMode mode;

  /// The computer's level in vs Computer.
  final Difficulty difficulty;
  final FirstMove firstMove;

  /// Watch and Learn: each computer's level, and how fast they play.
  final Difficulty xLevel;
  final Difficulty oLevel;
  final AutoPlaySpeed speed;

  GameSetup copyWith({
    GameMode? mode,
    Difficulty? difficulty,
    FirstMove? firstMove,
    Difficulty? xLevel,
    Difficulty? oLevel,
    AutoPlaySpeed? speed,
  }) => GameSetup(
    mode: mode ?? this.mode,
    difficulty: difficulty ?? this.difficulty,
    firstMove: firstMove ?? this.firstMove,
    xLevel: xLevel ?? this.xLevel,
    oLevel: oLevel ?? this.oLevel,
    speed: speed ?? this.speed,
  );

  Difficulty levelFor(Player player) => player == Player.x ? xLevel : oLevel;

  static const _prefix = 'tictactoe.setup';

  static Future<GameSetup> load() async {
    final prefs = await SharedPreferences.getInstance();
    T pick<T extends Enum>(List<T> values, String key, T fallback) {
      final name = prefs.getString('$_prefix.$key');
      return values.firstWhere((v) => v.name == name, orElse: () => fallback);
    }

    const d = GameSetup();
    return GameSetup(
      mode: pick(GameMode.values, 'mode', d.mode),
      difficulty: pick(Difficulty.values, 'difficulty', d.difficulty),
      firstMove: pick(FirstMove.values, 'firstMove', d.firstMove),
      xLevel: pick(Difficulty.values, 'xLevel', d.xLevel),
      oLevel: pick(Difficulty.values, 'oLevel', d.oLevel),
      speed: pick(AutoPlaySpeed.values, 'speed', d.speed),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.mode', mode.name);
    await prefs.setString('$_prefix.difficulty', difficulty.name);
    await prefs.setString('$_prefix.firstMove', firstMove.name);
    await prefs.setString('$_prefix.xLevel', xLevel.name);
    await prefs.setString('$_prefix.oLevel', oLevel.name);
    await prefs.setString('$_prefix.speed', speed.name);
  }

  static const _humanFirstKey = '$_prefix.humanWentFirst';

  /// Decides whether the player moves first in the next vs Computer game,
  /// remembering it so "Take turns" alternates across sessions.
  Future<bool> nextHumanFirst() async {
    final prefs = await SharedPreferences.getInstance();
    final first = switch (firstMove) {
      FirstMove.you => true,
      FirstMove.computer => false,
      FirstMove.alternate => !(prefs.getBool(_humanFirstKey) ?? false),
    };
    await prefs.setBool(_humanFirstKey, first);
    return first;
  }

  @override
  bool operator ==(Object other) =>
      other is GameSetup &&
      other.mode == mode &&
      other.difficulty == difficulty &&
      other.firstMove == firstMove &&
      other.xLevel == xLevel &&
      other.oLevel == oLevel &&
      other.speed == speed;

  @override
  int get hashCode =>
      Object.hash(mode, difficulty, firstMove, xLevel, oLevel, speed);
}
