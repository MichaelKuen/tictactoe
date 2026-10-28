// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'ai.dart';
import 'game.dart';
import 'game_setup.dart';
import 'game_status.dart';
import 'player.dart';
import 'score.dart';
import 'score_repository.dart';

enum GameSound { moveX, moveO, win, lose, draw }

/// Runs one game of player vs computer, or two players on one device.
class GameController extends ChangeNotifier {
  GameController({
    this.setup = const GameSetup(),
    bool humanFirst = true,
    this.scores,
    this.aiDelay = const Duration(milliseconds: 350),
    this.onSound,
    this.random,
  }) : humanPlayer = humanFirst ? Player.x : Player.o {
    _aiScore = scores?.aiScore ?? const Score();
    _humanScore = scores?.humanScore ?? const Score();
    if (_computersTurn) _scheduleAi();
  }

  final GameSetup setup;

  /// Saved scores; null keeps them in memory only (tests).
  final ScoreRepository? scores;

  /// Pause before the computer's move appears. The search itself takes a
  /// few milliseconds, so on web (where it runs on the main thread) this
  /// pause is also what lets "Computer is thinking…" show first.
  final Duration aiDelay;

  final void Function(GameSound sound)? onSound;

  /// Injected by tests so the computer's random choices repeat.
  final Random? random;

  /// The player's mark in vs Computer: X when they move first.
  final Player humanPlayer;

  Game _game = Game.start();
  int? _lastMove;
  int? _hint;
  int? _cursor;
  bool _thinking = false;
  String? _message;
  Timer? _aiTimer;
  late Score _aiScore;
  late Score _humanScore;

  bool get vsComputer => setup.mode == GameMode.vsComputer;
  Player get computerPlayer => humanPlayer.opponent;
  Game get game => _game;
  bool get isOver => _game.isOver;
  bool get thinking => _thinking;

  /// The square played last, highlighted on the board.
  int? get lastMove => _lastMove;

  /// The square a hint suggests, until the next move.
  int? get hint => _hint;

  /// Keyboard cursor square, or null until an arrow key is pressed.
  int? get cursor => _cursor;

  /// Why the computer played its last move.
  String? get message => _message;

  /// The score for the current mode.
  Score get score => vsComputer ? _aiScore : _humanScore;

  bool get _computersTurn =>
      vsComputer && !isOver && _game.currentPlayer == computerPlayer;

  bool get humansTurn => !isOver && !_thinking && !_computersTurn;

  bool get canHint => humansTurn && _hint == null;

  /// True when [winner] is the player (vs Computer only).
  bool get humanWon => vsComputer && _game.board.winner == humanPlayer;

  String get statusText {
    if (_thinking) return 'Computer is thinking…';
    final current = _game.currentPlayer;
    switch (_game.status) {
      case GameStatus.playing:
        if (!vsComputer) return "${current.label}'s turn";
        return current == humanPlayer
            ? 'Your turn (${current.label})'
            : "Computer's turn";
      case GameStatus.xWins:
      case GameStatus.oWins:
        if (!vsComputer) return '${_game.board.winner!.label} wins!';
        return humanWon ? 'You win!' : 'Computer wins!';
      case GameStatus.draw:
        return 'Draw!';
    }
  }

  /// Places the current player's mark on [index] if it is the player's turn.
  void tap(int index) {
    if (!humansTurn || !_game.board.canMove(index)) return;
    _cursor = index;
    _message = null;
    _play(index);
  }

  void _play(int index) {
    final player = _game.currentPlayer;
    _game = _game.move(index);
    _lastMove = index;
    _hint = null;
    if (isOver) {
      _recordResult();
      onSound?.call(
        _game.status == GameStatus.draw
            ? GameSound.draw
            : vsComputer && !humanWon
            ? GameSound.lose
            : GameSound.win,
      );
    } else {
      onSound?.call(player == Player.x ? GameSound.moveX : GameSound.moveO);
      if (_computersTurn) _scheduleAi();
    }
    notifyListeners();
  }

  void _scheduleAi() {
    _thinking = true;
    _aiTimer = Timer(aiDelay, () {
      final decision = AiPlayer.decide(
        _game.board,
        computerPlayer,
        setup.difficulty,
        random: random,
      );
      _thinking = false;
      _message = 'Computer: ${decision.reason}.';
      _play(decision.move);
    });
  }

  /// Shows the best move for the player to move (after a rewarded ad).
  void showHint() {
    if (!canHint) return;
    _hint = AiPlayer.bestMove(_game.board, _game.currentPlayer);
    notifyListeners();
  }

  /// Moves the keyboard cursor; the first press selects the centre.
  void moveCursor(int dRow, int dCol) {
    final c = _cursor;
    if (c == null) {
      _cursor = 4;
    } else {
      final row = (c ~/ 3 + dRow).clamp(0, 2);
      final col = (c % 3 + dCol).clamp(0, 2);
      _cursor = row * 3 + col;
    }
    notifyListeners();
  }

  /// Plays on the cursor square, if there is one.
  void playCursor() {
    final c = _cursor;
    if (c != null) tap(c);
  }

  /// Moves the cursor to [index] and plays there (number keys).
  void keyMove(int index) {
    _cursor = index;
    if (humansTurn && _game.board.canMove(index)) {
      tap(index);
    } else {
      notifyListeners();
    }
  }

  void _recordResult() {
    final repo = scores;
    if (vsComputer) {
      _aiScore = switch (_game.status) {
        GameStatus.draw => _aiScore.copyWithDraw(),
        _ when humanWon => _aiScore.copyWithXWin(),
        _ => _aiScore.copyWithOWin(),
      };
      repo?.saveAiScore(_aiScore);
    } else {
      _humanScore = switch (_game.status) {
        GameStatus.xWins => _humanScore.copyWithXWin(),
        GameStatus.oWins => _humanScore.copyWithOWin(),
        _ => _humanScore.copyWithDraw(),
      };
      repo?.saveHumanScore(_humanScore);
    }
  }

  void resetScores() {
    scores?.resetAll();
    _aiScore = const Score();
    _humanScore = const Score();
    notifyListeners();
  }

  @override
  void dispose() {
    _aiTimer?.cancel();
    super.dispose();
  }
}
