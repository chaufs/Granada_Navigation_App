fimport 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:granada_navigation_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentApp());
    expect(find.text('Login'), findsWidgets);
  });
}
