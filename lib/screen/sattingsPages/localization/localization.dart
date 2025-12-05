
class AppStrings {

  static const loginTitle = {
    'en': 'Login',
    'ur': 'لاگ ان',
  };

  static const emailLabel = {
    'en': 'Email',
    'ur': 'ای میل',
  };

  static const emailHint = {
    'en': 'Enter your email',
    'ur': 'اپنا ای میل درج کریں',
  };

  static const passwordLabel = {
    'en': 'Password',
    'ur': 'پاس ورڈ',
  };

  static const passwordHint = {
    'en': 'Enter your password',
    'ur': 'اپنا پاس ورڈ درج کریں',
  };

  static const loginButton = {
    'en': 'Login',
    'ur': 'لاگ ان کریں',
  };

  // Signup Screen
  static const signupTitle = {
    'en': 'Signup',
    'ur': 'سائن اپ',
  };

  static const cnicLabel = {
    'en': 'CNIC',
    'ur': 'شناختی کارڈ نمبر',
  };

  static const cnicHint = {
    'en': 'Enter your CNIC',
    'ur': 'اپنا شناختی کارڈ نمبر درج کریں',
  };

  // Error Messages
  static const invalidEmail = {
    'en': 'Please enter a valid email',
    'ur': 'براہِ کرم درست ای میل درج کریں',
  };

  static const shortPassword = {
    'en': 'Password must be at least 6 characters long',
    'ur': 'پاس ورڈ کم از کم 6 حروف کا ہونا ضروری ہے',
  };

  static const loginFailed = {
    'en': 'Login failed. Please try again.',
    'ur': 'لاگ ان ناکام ہوگیا۔ دوبارہ کوشش کریں۔',
  };

  // Utility function to fetch string
  static String get(String key, String lang) {
    switch (key) {
      case 'loginTitle':
        return loginTitle[lang]!;
      case 'emailLabel':
        return emailLabel[lang]!;
      case 'emailHint':
        return emailHint[lang]!;
      case 'passwordLabel':
        return passwordLabel[lang]!;
      case 'passwordHint':
        return passwordHint[lang]!;
      case 'loginButton':
        return loginButton[lang]!;
      case 'signupTitle':
        return signupTitle[lang]!;
      case 'cnicLabel':
        return cnicLabel[lang]!;
      case 'cnicHint':
        return cnicHint[lang]!;
      case 'invalidEmail':
        return invalidEmail[lang]!;
      case 'shortPassword':
        return shortPassword[lang]!;
      case 'loginFailed':
        return loginFailed[lang]!;
      default:
        return '';
    }
  }
}
