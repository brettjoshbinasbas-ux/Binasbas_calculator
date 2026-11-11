import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:binasbas_calculator/calculator_screen.dart';

Future<void> loadFonts() async {
  // 1. Material Icons
  final iconFile = File('C:/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (iconFile.existsSync()) {
    final fontData = iconFile.readAsBytesSync();
    final fontLoader = FontLoader('MaterialIcons');
    fontLoader.addFont(Future.value(ByteData.view(fontData.buffer)));
    await fontLoader.load();
  }

  // 2. Text fonts
  final fontFile = File('C:/Windows/Fonts/segoeui.ttf');
  if (fontFile.existsSync()) {
    final fontData = fontFile.readAsBytesSync();

    final robotoLoader = FontLoader('Roboto');
    robotoLoader.addFont(Future.value(ByteData.view(fontData.buffer)));
    await robotoLoader.load();

    final segoeLoader = FontLoader('Segoe UI');
    segoeLoader.addFont(Future.value(ByteData.view(fontData.buffer)));
    await segoeLoader.load();
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await loadFonts();
  });

  testWidgets('Capture Calculator Screenshots with Real Typography', (WidgetTester tester) async {
    final screenshotDir = Directory('screenshots');
    if (!screenshotDir.existsSync()) {
      screenshotDir.createSync(recursive: true);
    }

    tester.view.physicalSize = const Size(540, 960);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repaintKey = GlobalKey();

    Future<void> snap(String fileName) async {
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.runAsync(() async {
        final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 2.0);
          final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            File('screenshots/$fileName').writeAsBytesSync(byteData.buffer.asUint8List());
            print('Saved: $fileName');
          }
        }
      });
    }

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Segoe UI',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: RepaintBoundary(
          key: repaintKey,
          child: const CalculatorScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final textFields = find.byType(TextField);

    // 1. Initial State
    await snap('01_initial_screen.png');

    // 2. Successful Calculation (25 × 4 = 100.0)
    print('Entering 25 and 4');
    await tester.enterText(textFields.at(0), '25');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textFields.at(1), '4');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(ElevatedButton, '×'));
    await snap('02_successful_calculation.png');

    // Addition (125 + 75 = 200.0)
    print('Entering 125 and 75');
    await tester.enterText(textFields.at(0), '125');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textFields.at(1), '75');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await snap('02_addition_successful.png');

    // 3. Division by Zero Message (50 ÷ 0)
    print('Entering 50 and 0');
    await tester.enterText(textFields.at(0), '50');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textFields.at(1), '0');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(ElevatedButton, '÷'));
    await snap('03_division_by_zero.png');

    // 4. Invalid Input
    print('Entering abc and 10');
    await tester.enterText(textFields.at(0), 'abc');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textFields.at(1), '10');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.widgetWithText(ElevatedButton, '+'));
    await snap('04_invalid_input.png');

    // 5. Clear state
    print('Tapping Clear');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Clear'));
    await snap('05_cleared_screen.png');
    print('ALL DONE WITH TYPOGRAPHY');
  });
}
