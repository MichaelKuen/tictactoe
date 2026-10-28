// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/game/difficulty.dart';
import 'package:tictactoe/game/game_controller.dart';
import 'package:tictactoe/game/game_setup.dart';
import 'package:tictactoe/game/game_status.dart';
import 'package:tictactoe/game/player.dart';
import 'package:tictactoe/game/score_repository.dart';

const _twoPlayer = GameSetup(mode: GameMode.twoPlayer);

void _play(GameController c, List<int> cells) {
  for (final i in cells) {
    c.tap(i);
  }
}

void main() {
  group('2 Players', () {
    test('X starts, players alternate and X wins on the top row', () {
      final c = GameController(setup: _twoPlayer);
      expect(c.statusText, "X's turn");
      _play(c, [0, 3, 1, 4]);
      expect(c.statusText, "X's turn");
      c.tap(2);
      expect(c.game.status, GameStatus.xWins);
      expect(c.statusText, 'X wins!');
      expect(c.score.xWins, 1);
    });

    test('an occupied square is ignored', () {
      final c = GameController(setup: _twoPlayer);
      c.tap(4);
      c.tap(4);
      expect(c.game.board[4], Player.x);
      expect(c.game.currentPlayer, Player.o);
    });

    test('taps after the game is over are ignored', () {
      final c = GameController(setup: _twoPlayer);
      _play(c, [0, 3, 1, 4, 2]);
      c.tap(8);
      expect(c.game.board[8], isNull);
    });

    test('a full board with no line is a draw', () {
      final c = GameController(setup: _twoPlayer);
      _play(c, [0, 1, 2, 4, 3, 5, 7, 6, 8]);
      expect(c.statusText, 'Draw!');
      expect(c.score.draws, 1);
    });

    test('the last move is remembered for the board', () {
      final c = GameController(setup: _twoPlayer);
      c.tap(5);
      expect(c.lastMove, 5);
    });

    test('sounds: a move per mark, then the result', () {
      final sounds = <GameSound>[];
      final c = GameController(setup: _twoPlayer, onSound: sounds.add);
      _play(c, [0, 3, 1, 4, 2]);
      expect(sounds, [
        GameSound.moveX,
        GameSound.moveO,
        GameSound.moveX,
        GameSound.moveO,
        GameSound.win,
      ]);
    });
  });

  group('vs Computer', () {
    test('the computer answers after a short pause and says why', () {
      fakeAsync((async) {
        final c = GameController(
          setup: const GameSetup(difficulty: Difficulty.hard),
        );
        c.tap(0);
        expect(c.thinking, isTrue);
        expect(c.statusText, 'Computer is thinking…');
        expect(c.humansTurn, isFalse);
        async.elapse(const Duration(seconds: 1));
        expect(c.thinking, isFalse);
        // Hard answers a corner opening with the centre.
        expect(c.game.board[4], Player.o);
        expect(c.message, startsWith('Computer: '));
        expect(c.statusText, 'Your turn (X)');
        c.dispose();
      });
    });

    test('the board is blocked while the computer thinks', () {
      fakeAsync((async) {
        final c = GameController();
        c.tap(0);
        c.tap(1);
        expect(c.game.board[1], isNull);
        async.elapse(const Duration(seconds: 1));
        c.dispose();
      });
    });

    test('when the computer starts, it plays X and the player plays O', () {
      fakeAsync((async) {
        final c = GameController(humanFirst: false);
        expect(c.humanPlayer, Player.o);
        expect(c.thinking, isTrue);
        async.elapse(const Duration(seconds: 1));
        expect(c.game.board.cells.where((p) => p == Player.x), hasLength(1));
        expect(c.statusText, 'Your turn (O)');
        c.dispose();
      });
    });

    test('a computer win is a loss for the player', () {
      fakeAsync((async) {
        final sounds = <GameSound>[];
        final c = GameController(onSound: sounds.add);
        // X plays badly; Hard wins.
        for (final i in [1, 2, 6, 7, 8, 5, 3]) {
          c.tap(i);
          async.elapse(const Duration(seconds: 1));
          if (c.isOver) break;
        }
        expect(c.game.board.winner, Player.o);
        expect(c.statusText, 'Computer wins!');
        expect(c.score.oWins, 1);
        expect(sounds.last, GameSound.lose);
        c.dispose();
      });
    });

    test('a hint shows the best square and clears after the move', () {
      fakeAsync((async) {
        final c = GameController();
        expect(c.canHint, isTrue);
        c.showHint();
        expect(c.hint, isNotNull);
        expect(c.canHint, isFalse);
        c.tap(c.hint!);
        expect(c.hint, isNull);
        async.elapse(const Duration(seconds: 1));
        c.dispose();
      });
    });
  });

  group('keyboard', () {
    test('the first arrow selects the centre, then moves and clamps', () {
      final c = GameController(setup: _twoPlayer);
      c.moveCursor(0, 1);
      expect(c.cursor, 4);
      c.moveCursor(-1, 0);
      expect(c.cursor, 1);
      c.moveCursor(-1, 0);
      expect(c.cursor, 1);
      c.playCursor();
      expect(c.game.board[1], Player.x);
    });

    test('number keys play their square', () {
      final c = GameController(setup: _twoPlayer);
      c.keyMove(8);
      expect(c.game.board[8], Player.x);
      expect(c.cursor, 8);
    });
  });

  group('scores', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('are kept per mode and saved', () async {
      final repo = await ScoreRepository.create();
      final c = GameController(setup: _twoPlayer, scores: repo);
      _play(c, [0, 3, 1, 4, 2]);
      expect(repo.humanScore.xWins, 1);
      expect(repo.aiScore.xWins, 0);
      final again = GameController(setup: _twoPlayer, scores: repo);
      expect(again.score.xWins, 1);
    });

    test('reset clears both modes', () async {
      SharedPreferences.setMockInitialValues({
        'tictactoe.score.computer.you': 3,
        'tictactoe.score.twoPlayer.o': 2,
      });
      final repo = await ScoreRepository.create();
      final c = GameController(setup: _twoPlayer, scores: repo);
      expect(c.score.oWins, 2);
      c.resetScores();
      expect(c.score.oWins, 0);
      expect(repo.aiScore.xWins, 0);
    });

    test('scores saved before the update are moved to the new keys', () async {
      SharedPreferences.setMockInitialValues({
        'score_ai_x': 4,
        'score_ai_o': 1,
        'score_ai_d': 7,
        'score_hv_x': 2,
      });
      final repo = await ScoreRepository.create();
      expect(repo.aiScore.xWins, 4);
      expect(repo.aiScore.oWins, 1);
      expect(repo.aiScore.draws, 7);
      expect(repo.humanScore.xWins, 2);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('score_ai_x'), isFalse);
      expect(prefs.getInt('tictactoe.score.computer.you'), 4);
    });
  });
}
