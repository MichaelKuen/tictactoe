// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:shared_preferences/shared_preferences.dart';

import 'score.dart';

/// Persists win/draw/loss records for vs Computer and 2 Players
/// independently.
///
/// In vs Computer, [Score.xWins] counts the player's wins and [Score.oWins]
/// the computer's, whichever mark each played. In 2 Players they count X and
/// O wins.
class ScoreRepository {
  static const _prefix = 'tictactoe.score';
  static const _aiX = '$_prefix.computer.you';
  static const _aiO = '$_prefix.computer.computer';
  static const _aiD = '$_prefix.computer.draw';
  static const _hvX = '$_prefix.twoPlayer.x';
  static const _hvO = '$_prefix.twoPlayer.o';
  static const _hvD = '$_prefix.twoPlayer.draw';

  /// Keys used before the App Verse Games update, moved on first start.
  static const _legacy = {
    'score_ai_x': _aiX,
    'score_ai_o': _aiO,
    'score_ai_d': _aiD,
    'score_hv_x': _hvX,
    'score_hv_o': _hvO,
    'score_hv_d': _hvD,
  };

  final SharedPreferences _prefs;

  ScoreRepository._(this._prefs);

  static Future<ScoreRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    for (final MapEntry(key: old, value: key) in _legacy.entries) {
      final value = prefs.getInt(old);
      if (value == null) continue;
      if (!prefs.containsKey(key)) await prefs.setInt(key, value);
      await prefs.remove(old);
    }
    return ScoreRepository._(prefs);
  }

  Score get aiScore => Score(
    xWins: _prefs.getInt(_aiX) ?? 0,
    oWins: _prefs.getInt(_aiO) ?? 0,
    draws: _prefs.getInt(_aiD) ?? 0,
  );

  Score get humanScore => Score(
    xWins: _prefs.getInt(_hvX) ?? 0,
    oWins: _prefs.getInt(_hvO) ?? 0,
    draws: _prefs.getInt(_hvD) ?? 0,
  );

  void saveAiScore(Score s) {
    _prefs.setInt(_aiX, s.xWins);
    _prefs.setInt(_aiO, s.oWins);
    _prefs.setInt(_aiD, s.draws);
  }

  void saveHumanScore(Score s) {
    _prefs.setInt(_hvX, s.xWins);
    _prefs.setInt(_hvO, s.oWins);
    _prefs.setInt(_hvD, s.draws);
  }

  void resetAll() {
    for (final k in [_aiX, _aiO, _aiD, _hvX, _hvO, _hvD]) {
      _prefs.remove(k);
    }
  }
}
