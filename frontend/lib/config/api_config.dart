import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _prefServerKey = 'custom_api_base_url';

  // 1. Check compile-time --dart-define=API_BASE_URL=https://your-cloud-api.com/api/v1
  static const String _environmentUrl = String.fromEnvironment('API_BASE_URL');

  // 2. Default LAN IP for physical mobile devices on Wi-Fi (replaces localhost)
  static const String _defaultLanUrl = 'http://192.168.55.103:8000/api/v1';

  static String? _cachedUrl;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cachedUrl = prefs.getString(_prefServerKey);
  }

  static String get baseUrl {
    if (_cachedUrl != null && _cachedUrl!.isNotEmpty) {
      return _cachedUrl!;
    }
    if (_environmentUrl.isNotEmpty) {
      return _environmentUrl;
    }
    return _defaultLanUrl;
  }

  static Future<void> setCustomBaseUrl(String url) async {
    _cachedUrl = url.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefServerKey, _cachedUrl!);
  }

  static Future<void> resetToDefault() async {
    _cachedUrl = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefServerKey);
  }

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';

  static const String products = '/products';
  static const String myListings = '/products/my/listings';
  static const String smartSuggest = '/products/smart-suggest';

  static const String artisans = '/artisans';
  static const String myArtisanProfile = '/artisans/me/profile';

  static const String linkagesInquire = '/linkages/inquire';
  static const String linkagesMatch = '/linkages/match';
  static const String artisanLinkages = '/linkages/artisan';
  static const String buyerLinkages = '/linkages/buyer';

  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
  static const String markAllRead = '/notifications/mark-all-read';

  static const String artisanDashboard = '/analytics/artisan/dashboard';
}
