import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fast_shikho/main.dart';

void main() {
  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(const FastShikhoApp());
  });
}
