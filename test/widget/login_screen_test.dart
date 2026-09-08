import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/core/storage/session_storage.dart';
import 'package:society_management/core/theme/app_theme.dart';
import 'package:society_management/features/authentication/data/auth_mock_data_source.dart';
import 'package:society_management/features/authentication/data/auth_repository_impl.dart';
import 'package:society_management/features/authentication/presentation/auth_notifier.dart';
import 'package:society_management/features/authentication/presentation/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders fields, toggles password, and validates input',
      (WidgetTester tester) async {
    final mockAuthDataSource = AuthMockDataSource();
    final inMemoryStorage = InMemorySessionStorage();
    final authRepo = AuthRepositoryImpl(
      dataSource: mockAuthDataSource,
      sessionStorage: inMemoryStorage,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith((ref) => AuthNotifier(authRepo)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify fields exist
    expect(find.byKey(const Key('login_identifier_field')), findsOneWidget);
    expect(find.byKey(const Key('login_password_field')), findsOneWidget);
    expect(find.byKey(const Key('login_submit_button')), findsOneWidget);

    // Verify password visibility toggle icon exists
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    // Tap visibility toggle
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    // Clear identifier and try submit -> validation triggers
    await tester.enterText(find.byKey(const Key('login_identifier_field')), '');
    await tester.tap(find.byKey(const Key('login_submit_button')));
    await tester.pump();

    expect(find.text('Email or mobile number is required'), findsOneWidget);
  });
}
