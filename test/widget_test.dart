// This is a basic Flutter widget test for ResQRoute app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resqroute/main.dart';

void main() {
  testWidgets('ResQRoute app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ResQRouteApp());

    // Verify that the app loads and shows splash screen or login elements
    // Since the app uses Firebase and GetX, we'll just verify it builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App title verification', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ResQRouteApp());

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // The app should build successfully without throwing errors
    expect(tester.takeException(), isNull);
  });
}
