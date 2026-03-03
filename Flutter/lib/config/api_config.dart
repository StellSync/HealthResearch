/// API Configuration - Centralized settings for all API calls
///
/// This file contains all API configuration settings including base URLs,
/// endpoints, and other constants. Update the baseUrl here to easily switch
/// between development, staging, and production servers.

class ApiConfig {
  /// Main API Base URL - Change this to switch servers
  ///
  /// Development: http://10.33.135.43:8000
  /// Staging: http://staging-api.example.com:8000
  /// Production: https://api.example.com
  static const String baseUrl = 'http://10.55.234.43:8000';

  /// API Version (optional, for future use)
  static const String apiVersion = '/api';

  // ──────────────────────────────────────────────────────────────
  // Authentication Endpoints
  // ──────────────────────────────────────────────────────────────

  static const String loginEndpoint = '$apiVersion/patients/login';
  static String get loginUrl => '$baseUrl$loginEndpoint';

  static const String registerEndpoint = '$apiVersion/patients/register';
  static String get registerUrl => '$baseUrl$registerEndpoint';

  // ──────────────────────────────────────────────────────────────
  // Session Endpoints
  // ──────────────────────────────────────────────────────────────

  static const String sessionsEndpoint = '$apiVersion/sessions';
  static String get sessionsUrl => '$baseUrl$sessionsEndpoint';

  static const String doctorsAvailableEndpoint = '$apiVersion/sessions/doctors/available';
  static String get doctorsAvailableUrl => '$baseUrl$doctorsAvailableEndpoint';

  static const String sessionCreateEndpoint = '$apiVersion/sessions/SessionCreate';
  static String get sessionCreateUrl => '$baseUrl$sessionCreateEndpoint';

  // ──────────────────────────────────────────────────────────────
  // Dashboard Endpoints
  // ──────────────────────────────────────────────────────────────

  static const String dashboardEndpoint = '$apiVersion/patients/dashboard';
  static String get dashboardUrl => '$baseUrl$dashboardEndpoint';

  // ──────────────────────────────────────────────────────────────
  // HTTP Headers
  // ──────────────────────────────────────────────────────────────

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ──────────────────────────────────────────────────────────────
  // Timeouts (in seconds)
  // ──────────────────────────────────────────────────────────────

  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // ──────────────────────────────────────────────────────────────
  // Environment Configuration
  // ──────────────────────────────────────────────────────────────

  /// Get current environment
  static String getEnvironment() {
    if (baseUrl.contains('localhost') || baseUrl.contains('127.0.0.1') || baseUrl.contains('10.33')) {
      return 'Development';
    } else if (baseUrl.contains('staging')) {
      return 'Staging';
    } else {
      return 'Production';
    }
  }

  /// Get base URL with optional suffix
  static String buildUrl(String endpoint) {
    if (endpoint.startsWith('/')) {
      return '$baseUrl$endpoint';
    }
    return '$baseUrl/$endpoint';
  }

  /// Print current configuration (useful for debugging)
  static void printConfig() {
    print('╔════════════════════════════════════════════════════╗');
    print('║        API CONFIGURATION                           ║');
    print('╠════════════════════════════════════════════════════╣');
    print('║ Environment: ${getEnvironment().padRight(38)}║');
    print('║ Base URL: ${baseUrl.padRight(41)}║');
    print('║ API Version: ${apiVersion.padRight(39)}║');
    print('║ Connection Timeout: ${connectionTimeout}s${' ' * 27}║');
    print('║ Receive Timeout: ${receiveTimeout}s${' ' * 29}║');
    print('╚════════════════════════════════════════════════════╝');
  }
}

/// Quick reference for all available endpoints
class ApiEndpoints {
  // Authentication
  static const String LOGIN = ApiConfig.loginEndpoint;
  static const String REGISTER = ApiConfig.registerEndpoint;

  // Sessions
  static const String SESSIONS = ApiConfig.sessionsEndpoint;
  static const String DOCTORS_AVAILABLE = ApiConfig.doctorsAvailableEndpoint;
  static const String SESSION_CREATE = ApiConfig.sessionCreateEndpoint;

  // Dashboard
  static const String DASHBOARD = ApiConfig.dashboardEndpoint;
}
