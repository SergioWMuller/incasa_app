class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://api.incasa.com';

  // Endpoints
  static const String products = '/products';
  static const String categories = '/categories';
  static const String stores = '/stores';
  static const String users = '/users';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
