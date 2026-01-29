/// Form validation utilities
class Validators {
  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  /// Validates password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validates required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates course code format
  static String? validateCourseCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Course code is required';
    }
    
    final codeRegex = RegExp(r'^[A-Z]{2,4}\d{3}$');
    if (!codeRegex.hasMatch(value.toUpperCase())) {
      return 'Invalid format (e.g., CSE101)';
    }
    
    return null;
  }

  /// Validates credit hours
  static String? validateCreditHours(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credit hours is required';
    }
    
    final hours = int.tryParse(value);
    if (hours == null || hours < 1 || hours > 10) {
      return 'Must be between 1 and 10';
    }
    
    return null;
  }
}
