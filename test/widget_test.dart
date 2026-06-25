// Copyright © FullStackShack. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter_test/flutter_test.dart';
import 'package:tictactoe/main.dart';

void main() {
  testWidgets('app smoke test — renders without error', (tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    expect(find.text('Tic Tac Toe'), findsOneWidget);
  });
}
