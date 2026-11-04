import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'EduSkill';
  static const String appVersion = '1.0.0';

  // Android Emulator → Host 10.0.2.2; Web & Desktop → 127.0.0.1; Physical Device → Your LAN IP
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

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
