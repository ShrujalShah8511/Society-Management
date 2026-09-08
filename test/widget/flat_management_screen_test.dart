import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/app/providers.dart';
import 'package:society_management/core/theme/app_theme.dart';
import 'package:society_management/features/society/data/society_mock_data_source.dart';
import 'package:society_management/features/society/presentation/flat_list_screen.dart';

void main() {
  testWidgets('FlatListScreen renders filters, search bar, and flat list',
      (WidgetTester tester) async {
    final mockDataSource = SocietyMockDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          societyMockDataSourceProvider.overrideWithValue(mockDataSource),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const FlatListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify search field exists
    expect(find.byKey(const Key('flat_search_field')), findsOneWidget);

    // Verify filter dropdowns exist
    expect(find.text('All Towers'), findsOneWidget);
    expect(find.text('All Statuses'), findsOneWidget);
    expect(find.text('All Flat Types'), findsOneWidget);

    // Verify flat cards are rendered
    expect(find.text('A-101'), findsOneWidget);
    expect(find.text('A-102'), findsOneWidget);
  });
}
