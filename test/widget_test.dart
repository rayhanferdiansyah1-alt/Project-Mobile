import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mitsubishi/screens/login_screen.dart';
import 'package:mitsubishi/ui/ui.dart';

void main() {
  testWidgets('login screen renders the sign-in form', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: const LoginScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('SPK WIP'), findsOneWidget);
    expect(find.text('Bodi & Cat'), findsOneWidget);
    expect(find.text('EMAIL'), findsOneWidget);
    expect(find.text('KATA SANDI'), findsOneWidget);
    expect(find.text('Masuk'), findsNWidgets(2));
  });
}
