// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:responsive_dashboard/main.dart';

void main() {
  testWidgets('Dashboard satu kolom di layar sempit', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(
      400,
      800,
    ); // Set the screen size to a narrow width
    tester.view.devicePixelRatio = 1.0; // Set the device pixel ratio
    addTearDown(tester.view.reset);
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DashboardApp());
    final width = tester.getSize(
      find.widgetWithText(DashboardCard, 'Assignments'),
    );
    expect(
      find.byType(DashboardCard),
      findsNWidgets(4),
    ); // Expect the width of the card to be less
  });

  testWidgets('Dashboard dua kolom di layar lebar', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(
      1200,
      800,
    ); // Set the screen size to a wide width
    tester.view.devicePixelRatio = 1.0; // Set the device pixel ratio
    addTearDown(tester.view.reset);
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DashboardApp());
    final width = tester.getSize(
      find.widgetWithText(DashboardCard, 'Assignments'),
    );
    expect(
      find.byType(DashboardCard),
      findsNWidgets(4),
    ); // Expect the width of the card to be greater
  });
}
