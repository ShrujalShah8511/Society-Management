import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/app/providers.dart';
import 'package:society_management/core/theme/app_theme.dart';
import '../helpers/mock_society_data_source.dart';
import 'package:society_management/features/society/presentation/flat_list_screen.dart';

import 'package:society_management/features/society/presentation/flat_form_dialog.dart';

void main() {
  testWidgets('FlatListScreen renders filters, search bar, and flat list',
      (WidgetTester tester) async {
    final mockDataSource = SocietyMockDataSource();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          societyDataSourceProvider.overrideWithValue(mockDataSource),
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

  testWidgets('FlatFormDialog renders inside AlertDialog without intrinsic dimension exceptions',
      (WidgetTester tester) async {
    final mockDataSource = SocietyMockDataSource();
    final towers = await mockDataSource.getTowers('soc_1');
    final floors = await mockDataSource.getFloors(societyId: 'soc_1');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                FlatFormDialog.show(
                  context,
                  towers: towers,
                  floors: floors,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Add New Flat'), findsOneWidget);
    expect(find.byKey(const Key('flat_number_field')), findsOneWidget);
    expect(find.byKey(const Key('flat_area_field')), findsOneWidget);
    expect(find.text('Save Flat'), findsOneWidget);
  });
}
