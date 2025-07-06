class AppConfig {
  static const String baseUrl = 'https://api.rdxexchange.com'; // Replace with your API
  static const String apiVersion = 'v1';
  static const String appVersion = '1.0.0';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String walletsEndpoint = '/wallets';
  static const String tradesEndpoint = '/trades';
  static const String rewardsEndpoint = '/rewards';
  
  // App Settings
  static const int requestTimeout = 30000; // 30 seconds
  static const bool enableLogging = true;
}