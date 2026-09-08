class Validators {
  Validators._();

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? emailOrMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or mobile number is required';
    }
    final trimmed = value.trim();
    final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed);
    final isMobile = RegExp(r'^\+?[0-9]{10,13}$').hasMatch(trimmed);

    if (!isEmail && !isMobile) {
      return 'Enter a valid email address or 10-digit mobile number';
    }
    return null;
  }

  static String? phone(String? value, [String fieldName = 'Contact number']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number (10-13 digits)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? pinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN code is required';
    }
    final pinRegex = RegExp(r'^[0-9]{5,6}$');
    if (!pinRegex.hasMatch(value.trim())) {
      return 'Enter a valid 5-6 digit PIN code';
    }
    return null;
  }

  static String? positiveInt(String? value, [String fieldName = 'Value']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0) {
      return '$fieldName must be a valid positive whole number';
    }
    return null;
  }

  static String? positiveDouble(String? value, [String fieldName = 'Area']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }
}
