import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return '$envUrl/api';

    if (kIsWeb) return 'http://localhost:8000/api';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';

  static const String dashboardStats = '/dashboard/stats';

  static const String categories = '/categories';
  static const String products = '/products';
  static const String customers = '/customers';
  static const String transactions = '/transactions';
}
