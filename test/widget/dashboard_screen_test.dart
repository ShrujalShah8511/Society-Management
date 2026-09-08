import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/app/providers.dart';
import 'package:society_management/core/storage/file_storage_service.dart';
import 'package:society_management/core/theme/app_theme.dart';
import 'package:society_management/features/dashboard/presentation/dashboard_screen.dart';
import 'package:society_management/features/society/data/society_mock_data_source.dart';
import 'package:society_management/features/society/presentation/society_profile_notifier.dart';

void main() {
  testWidgets('DashboardScreen renders summary, statistics, and quick action cards',
      (WidgetTester tester) async {
    final mockSocietyDataSource = SocietyMockDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          societyMockDataSourceProvider.overrideWithValue(mockSocietyDataSource),
          societyProfileNotifierProvider.overrideWith(
            (ref) => SocietyProfileNotifier(
              ref.read(societyRepositoryProvider),
              MockFileStorageService(),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(),
        ),
      ),
    );

    // Initial pump & settle to resolve futures
    await tester.pumpAndSettle();

    // Verify statistics cards are rendered
    expect(find.text('Total Towers'), findsOneWidget);
    expect(find.text('Total Floors'), findsOneWidget);
    expect(find.text('Total Flats'), findsOneWidget);
    expect(find.text('Occupied Flats'), findsOneWidget);
    expect(find.text('Vacant Flats'), findsOneWidget);

    // Verify Quick Actions exist
    expect(find.text('Manage Towers'), findsOneWidget);
    expect(find.text('Configure Floors'), findsOneWidget);
    expect(find.text('Flat Inventory'), findsOneWidget);
  });
}
