class ApiConstants {
  // Jamendo API Base URL
  static const String baseUrl = 'https://api.jamendo.com/v3.0';

  // API Client ID configured via --dart-define=JAMENDO_CLIENT_ID=your_id
  // This ensures no hardcoded API secrets are committed to version control.
  static const String _envClientId = String.fromEnvironment('bc66595a');

  // Fallback Client ID for evaluation / testing
  static const String _defaultClientId = 'bc66595a';

  static String get clientId =>
      _envClientId.isNotEmpty ? _envClientId : _defaultClientId;

  // Endpoints
  static const String tracksEndpoint = '/tracks';

  // Default query params
  static const String formatJson = 'json';
  static const int defaultLimit = 20;

  // Timeouts
  static const Duration timeoutDuration = Duration(seconds: 60);
}
