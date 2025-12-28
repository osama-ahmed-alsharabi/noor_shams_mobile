class AppErrorHandler {
  static String handleAuthError(dynamic error) {
    final String message = error.toString().toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid_grant')) {
      return 'رقم الهاتف أو كلمة المرور غير صحيحة';
    }
    if (message.contains('user not found')) {
      return 'هذا الحساب غير موجود';
    }
    if (message.contains('email already in use') ||
        message.contains('user already registered')) {
      return 'رقم الهاتف مسجل بالفعل';
    }
    if (message.contains('weak password') ||
        message.contains('password should be at least')) {
      return 'كلمة المرور ضعيفة، يجب أن تكون 6 أحرف على الأقل';
    }
    if (message.contains('invalid email') ||
        message.contains('is invalid') ||
        message.contains('email_address_invalid')) {
      return 'رقم الهاتف غير صحيح';
    }
    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('socketexception')) {
      return 'يرجى التحقق من الاتصال بالإنترنت';
    }
    if (message.contains('security purposes') ||
        message.contains('request this after')) {
      return 'يرجى الانتظار قليلاً قبل المحاولة مرة أخرى (قيود أمان)';
    }

    // Default fallback
    return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
  }

  static String validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الاسم الكامل';
    }
    if (value.trim().length < 3) {
      return 'الاسم يجب أن يكون 3 أحرف على الأقل';
    }
    return ''; // Valid
  }

  static String validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'رقم الهاتف غير صحيح';
    }
    return ''; // Valid
  }

  static String validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }

    // Normalize and sanitize
    String cleanPhone = normalizeArabicNumbers(value);
    cleanPhone = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');

    // Yemeni phone validation: Starts with 7, 9 digits total
    if (!RegExp(r'^(77|78|73|71|70)[0-9]{7}$').hasMatch(cleanPhone) &&
        cleanPhone.length != 9) {
      return 'رقم الهاتف يجب أن يتكون من 9 أرقام ويبدأ بـ 7';
    }
    return ''; // Valid
  }

  static String normalizeArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input;
  }

  static String validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return ''; // Valid
  }
}
