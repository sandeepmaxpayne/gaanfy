import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gaanfy/widgets/animated_logo.dart';

void main() {
  testWidgets('animated logo renders brand name', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: AnimatedLogo())),
      ),
    );

    expect(find.text('Gaanfy'), findsOneWidget);
    expect(find.byIcon(Icons.graphic_eq_rounded), findsOneWidget);
  });
}
