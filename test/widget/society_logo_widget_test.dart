import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/core/widgets/society_logo_widget.dart';

void main() {
  group('SocietyLogoWidget Tests', () {
    testWidgets('Renders monogram initials when logoUrl is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocietyLogoWidget(
              logoUrl: null,
              societyName: 'Shyam Heights',
              size: 50,
            ),
          ),
        ),
      );

      expect(find.text('SH'), findsOneWidget);
    });

    testWidgets('Renders single-word monogram initials when logoUrl is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocietyLogoWidget(
              logoUrl: null,
              societyName: 'Astra',
              size: 50,
            ),
          ),
        ),
      );

      expect(find.text('AS'), findsOneWidget);
    });

    testWidgets('Renders fallback icon when societyName is empty and logoUrl is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocietyLogoWidget(
              logoUrl: null,
              societyName: '',
              size: 50,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.apartment_rounded), findsOneWidget);
    });

    testWidgets('Renders Image.memory when data URL is provided', (tester) async {
      // 1x1 transparent PNG base64
      const base64Png =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SocietyLogoWidget(
              logoUrl: base64Png,
              societyName: 'Emerald Greens',
              size: 50,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });
  });
}
