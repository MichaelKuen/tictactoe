// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/ui/game_screen.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

Finder _cell(int index) => find.byKey(ValueKey('cell_$index'));

void main() {
  testWidgets('shows X turn initially', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    expect(find.text("X's turn"), findsOneWidget);
  });

  testWidgets('tapping a cell places X', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    await tester.tap(_cell(0));
    await tester.pump();
    expect(find.text('X'), findsOneWidget);
    expect(find.text("O's turn"), findsOneWidget);
  });

  testWidgets('tapping an occupied cell has no effect', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    await tester.tap(_cell(0));
    await tester.pump();
    await tester.tap(_cell(0));
    await tester.pump();
    expect(find.text('X'), findsOneWidget);
    expect(find.text("O's turn"), findsOneWidget);
  });

  testWidgets('New Game button resets the board', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    await tester.tap(_cell(0));
    await tester.pump();
    await tester.tap(find.text('New Game'));
    await tester.pump();
    expect(find.text('X'), findsNothing);
    expect(find.text("X's turn"), findsOneWidget);
  });

  testWidgets('X wins shows win message', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    // X: 0, O: 3, X: 1, O: 4, X: 2 — top row win for X
    await tester.tap(_cell(0)); await tester.pump();
    await tester.tap(_cell(3)); await tester.pump();
    await tester.tap(_cell(1)); await tester.pump();
    await tester.tap(_cell(4)); await tester.pump();
    await tester.tap(_cell(2)); await tester.pump();
    expect(find.text('X wins!'), findsOneWidget);
  });

  testWidgets('winning cells are highlighted after X wins', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    // X wins top row [0,1,2]; O plays [3,4]
    await tester.tap(_cell(0)); await tester.pump();
    await tester.tap(_cell(3)); await tester.pump();
    await tester.tap(_cell(1)); await tester.pump();
    await tester.tap(_cell(4)); await tester.pump();
    await tester.tap(_cell(2)); await tester.pump();

    // Winning cells 0,1,2 should be highlighted (primaryContainer background)
    for (final index in [0, 1, 2]) {
      final container = tester.widget<Container>(
        find.descendant(of: _cell(index), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull,
          reason: 'cell $index should have a highlight background');
    }

    // Non-winning cells should not be highlighted
    for (final index in [3, 4]) {
      final container = tester.widget<Container>(
        find.descendant(of: _cell(index), matching: find.byType(Container)),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNull,
          reason: 'cell $index should not be highlighted');
    }
  });

  testWidgets('no cells are highlighted mid-game', (tester) async {
    await tester.pumpWidget(_wrap(const GameScreen()));
    await tester.tap(_cell(0)); await tester.pump();

    final container = tester.widget<Container>(
      find.descendant(of: _cell(0), matching: find.byType(Container)),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNull);
  });
}
