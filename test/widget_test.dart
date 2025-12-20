import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mysmartadmin/app/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const LedgerApp());

    // Verify that the app title is displayed
    expect(find.text('LedgerAI'), findsOneWidget);

    // Verify navigation bar is present
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
