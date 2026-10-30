class AppConstants {
  AppConstants._();

  static const String appName = 'EduSkill';
  static const String appVersion = '1.0.0';

  // Android Emulator → Host 10.0.2.2; Physical Device → Your LAN IP
  // ponytail: use flavor/env config when deploying to staging/production
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String baseUrlFallback = 'http://localhost:8000/api/v1';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Storage Keys
  static const String tokenKey = 'eduskill_auth_token';
  static const String userKey = 'eduskill_user_data';
  static const String themeKey = 'eduskill_app_theme';
  static const String onboardingKey = 'eduskill_onboarding_done';

  static const int defaultPageSize = 20;

  // Duolingo-style hearts
  static const int maxHearts = 5;

  // Developer League XP thresholds
  static const Map<String, int> leagueTiers = {
    'Bronze': 0,
    'Silver': 500,
    'Gold': 1000,
    'Diamond': 2000,
    'Cyber Master': 3000,
  };
}
