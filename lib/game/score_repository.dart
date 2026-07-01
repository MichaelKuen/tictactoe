// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:shared_preferences/shared_preferences.dart';
import 'score.dart';

/// Persists win/draw/loss records for vs-AI and vs-Human modes independently.
class ScoreRepository {
  static const _aiX = 'score_ai_x';
  static const _aiO = 'score_ai_o';
  static const _aiD = 'score_ai_d';
  static const _hvX = 'score_hv_x';
  static const _hvO = 'score_hv_o';
  static const _hvD = 'score_hv_d';

  final SharedPreferences _prefs;

  ScoreRepository._(this._prefs);

  static Future<ScoreRepository> create() async =>
      ScoreRepository._(await SharedPreferences.getInstance());

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
