import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitsubishi/ui/ui.dart';

// Smoke test tanpa Firebase: memastikan tema & palet warna terpasang.
void main() {
  testWidgets('Tema memakai warna canvas dari AppColors', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: Text('SPK WIP')),
      ),
    );

    expect(find.text('SPK WIP'), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    final bg =
        scaffold.backgroundColor ??
        Theme.of(tester.element(find.byType(Scaffold))).scaffoldBackgroundColor;
    expect(bg, AppColors.canvas);
  });
}