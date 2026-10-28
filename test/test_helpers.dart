// Copyright © App Verse Games. All rights reserved.
// Unauthorised use, reproduction, or distribution is strictly prohibited.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets the test window to [width] × [height] logical pixels.
void setWindow(WidgetTester tester, double width, double height) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Finder cell(int index) => find.byKey(ValueKey('cell_$index'));

Future<void> tapCell(WidgetTester tester, int index) async {
  await tester.tap(cell(index));
  await tester.pump();
}

String statusOf(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('status'))).data!;
