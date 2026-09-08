import 'package:flutter_test/flutter_test.dart';
import 'package:society_management/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('Validators.required', () {
      expect(Validators.required(null, 'Field'), isNotNull);
      expect(Validators.required('', 'Field'), isNotNull);
      expect(Validators.required('   ', 'Field'), isNotNull);
      expect(Validators.required('Valid text', 'Field'), isNull);
    });

    test('Validators.email', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('test@'), isNotNull);
      expect(Validators.email('test@society.com'), isNull);
    });

    test('Validators.emailOrMobile', () {
      expect(Validators.emailOrMobile(null), isNotNull);
      expect(Validators.emailOrMobile(''), isNotNull);
      expect(Validators.emailOrMobile('invalid_input'), isNotNull);
      expect(Validators.emailOrMobile('admin@society.com'), isNull);
      expect(Validators.emailOrMobile('9876543210'), isNull);
      expect(Validators.emailOrMobile('+919876543210'), isNull);
    });

    test('Validators.phone', () {
      expect(Validators.phone(null), isNotNull);
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('abcdefghij'), isNotNull);
      expect(Validators.phone('9876543210'), isNull);
    });

    test('Validators.password', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password('123'), isNotNull);
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('securePassword123'), isNull);
    });

    test('Validators.pinCode', () {
      expect(Validators.pinCode(null), isNotNull);
      expect(Validators.pinCode('123'), isNotNull);
      expect(Validators.pinCode('400001'), isNull);
    });

    test('Validators.positiveInt', () {
      expect(Validators.positiveInt(null, 'Floors'), isNotNull);
      expect(Validators.positiveInt('-1', 'Floors'), isNotNull);
      expect(Validators.positiveInt('abc', 'Floors'), isNotNull);
      expect(Validators.positiveInt('5', 'Floors'), isNull);
      expect(Validators.positiveInt('0', 'Floors'), isNull);
    });

    test('Validators.positiveDouble', () {
      expect(Validators.positiveDouble(null, 'Area'), isNotNull);
      expect(Validators.positiveDouble('0', 'Area'), isNotNull);
      expect(Validators.positiveDouble('-50.5', 'Area'), isNotNull);
      expect(Validators.positiveDouble('1050.75', 'Area'), isNull);
    });
  });
}
