import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:binasbas_calculator/main.dart';

void main() {
  testWidgets('Calculator smoke test - addition, division by zero, and clear', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const CalculatorApp());

    // 1. Verify initial UI elements
    expect(find.text('My Stateful Calculator'), findsOneWidget);
    expect(find.text('BASIC CALCULATOR'), findsOneWidget);
    expect(find.text('Enter two numbers'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.textContaining('Brett Josh B. Binasbas'), findsOneWidget);
    expect(find.textContaining('CCE106L(3447)'), findsOneWidget);

    final firstField = find.widgetWithText(TextField, 'First Number');
    final secondField = find.widgetWithText(TextField, 'Second Number');

    // 2. Perform addition: 15 + 25 = 40.0
    await tester.enterText(firstField, '15');
    await tester.enterText(secondField, '25');
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await tester.pump();

    expect(find.text('40.0'), findsOneWidget);
    expect(find.text('15.0 + 25.0'), findsOneWidget);

    // 3. Perform division by zero: 15 ÷ 0
    await tester.enterText(secondField, '0');
    await tester.tap(find.widgetWithText(ElevatedButton, '÷'));
    await tester.pump();

    expect(find.text('Cannot divide by zero'), findsOneWidget);
    expect(find.text('Please change the second number'), findsOneWidget);

    // 4. Test Clear button
    await tester.tap(find.widgetWithText(OutlinedButton, 'Clear'));
    await tester.pump();

    expect(find.text('0'), findsOneWidget);
    expect(find.text('Enter two numbers'), findsOneWidget);
  });
}
