import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/app/providers.dart';
import 'package:society_management/core/theme/app_theme.dart';
import '../helpers/mock_society_data_source.dart';
import 'package:society_management/features/society/presentation/flat_list_screen.dart';
import 'package:society_management/features/society/presentation/flat_form_dialog.dart';
import 'package:society_management/features/society/domain/tower.dart';
import 'package:society_management/features/society/domain/floor.dart';

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
    final List<Tower> towers = [
      Tower(
        id: 'tow-1',
        societyId: 'soc-1',
        name: 'Tower A',
        description: 'Tower A description',
        floorCount: 2,
        status: TowerStatus.active,
        createdAt: DateTime(2026, 1, 1),
      ),
    ];
    final List<Floor> floors = [
      Floor(
        id: 'flr-1',
        societyId: 'soc-1',
        towerId: 'tow-1',
        floorNumber: 1,
        displayName: 'Floor 1',
        status: TowerStatus.active,
        createdAt: DateTime(2026, 1, 1),
      ),
    ];

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
    expect(find.byKey(const Key('flat_submit_button')), findsOneWidget);
    expect(find.text('Create Flat'), findsOneWidget);
  });
}
