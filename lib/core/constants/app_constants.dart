class AppConstants {
  AppConstants._();

  // ─── App Info ─────────────────────────────────────────────
  static const String appName = 'Learning App';
  static const String appVersion = '1.0.0';

  // ─── API ──────────────────────────────────────────────────
  static const String baseUrl = 'https://api.example.com';
  static const int connectTimeout = 15000; // ms
  static const int receiveTimeout = 15000; // ms

  // ─── Storage Keys ─────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String themeKey = 'app_theme';
  static const String localeKey = 'app_locale';
  static const String onboardingKey = 'onboarding_complete';

  // ─── Pagination ───────────────────────────────────────────
  static const int defaultPageSize = 20;
}
