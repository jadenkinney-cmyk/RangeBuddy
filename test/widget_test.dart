import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rangebuddy/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RangeBuddyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Press Generate to start!'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('Press Generate to start!'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}