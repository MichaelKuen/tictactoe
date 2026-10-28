// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:appverse_core_kit/appverse_core_kit.dart' show AutoPlaySpeed;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tictactoe/game/difficulty.dart';
import 'package:tictactoe/game/game_setup.dart';
import 'package:tictactoe/game/player.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults: vs Computer on Hard, player first', () async {
    final setup = await GameSetup.load();
    expect(setup, const GameSetup());
    expect(setup.mode, GameMode.vsComputer);
    expect(setup.difficulty, Difficulty.hard);
    expect(setup.firstMove, FirstMove.you);
  });

  test('every choice is saved under tictactoe.setup keys', () async {
    const setup = GameSetup(
      mode: GameMode.watch,
      difficulty: Difficulty.easy,
      firstMove: FirstMove.alternate,
      xLevel: Difficulty.hard,
      oLevel: Difficulty.easy,
      speed: AutoPlaySpeed.double_,
    );
    await setup.save();
    expect(await GameSetup.load(), setup);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), everyElement(startsWith('tictactoe.setup.')));
    expect(setup.levelFor(Player.x), Difficulty.hard);
    expect(setup.levelFor(Player.o), Difficulty.easy);
  });

  test('unknown saved values fall back to the defaults', () async {
    SharedPreferences.setMockInitialValues({
      'tictactoe.setup.mode': 'nonsense',
    });
    expect((await GameSetup.load()).mode, GameMode.vsComputer);
  });

  test('first move: you, computer, or take turns across games', () async {
    expect(await const GameSetup().nextHumanFirst(), isTrue);
    expect(
      await const GameSetup(firstMove: FirstMove.computer).nextHumanFirst(),
      isFalse,
    );
    const turns = GameSetup(firstMove: FirstMove.alternate);
    final first = await turns.nextHumanFirst();
    expect(await turns.nextHumanFirst(), !first);
    expect(await turns.nextHumanFirst(), first);
  });
}
