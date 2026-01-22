import 'package:flutter_test/flutter_test.dart';

import 'package:craftconnect/main.dart';

void main() {
  testWidgets('Welcome screen button toggles text', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const CraftConnectApp());

    // Initial text should be visible
    expect(find.text('Welcome to CraftConnect'), findsOneWidget);
    expect(find.text('Connecting Artisans to Customers'), findsNothing);

    // Tap the button
    await tester.tap(find.text('Get Started'));
    await tester.pump();

    // Updated text should be visible
    expect(find.text('Welcome to CraftConnect'), findsNothing);
    expect(find.text('Connecting Artisans to Customers'), findsOneWidget);
  });
}
