// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:learning_app/screens/auth/login_screen.dart';
import 'package:learning_app/providers/auth_provider.dart';
import 'package:learning_app/core/theme/app_theme.dart';

void main() {
  testWidgets('Login screen shows EduSkill branding and demo accounts', (WidgetTester tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('EduSkill'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
    expect(find.text('Siswa SMP (Budi Santoso)'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
