import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _currentUser != null;

  bool get isArtisan => _currentUser?.role == UserRole.artisan;
  bool get isBuyer => _currentUser?.role == UserRole.buyer;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.post(
        ApiConfig.login,
        body: {'email': email.trim(), 'password': password},
        requireAuth: false,
      );

      _token = res['access_token'];
      await StorageService.saveToken(_token!);

      _currentUser = User.fromJson(res);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerArtisan({
    required String email,
    required String password,
    required String fullName,
    required String craftType,
    required String region,
    String? phone,
    String? cooperative,
    String? heritageStory,
    String? bio,
    int yearsOfExperience = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        'email': email.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'phone': phone,
        'role': 'artisan',
        'craft_type': craftType.trim(),
        'region': region.trim(),
        'community_cooperative': cooperative,
        'heritage_story': heritageStory,
        'bio': bio,
        'years_of_experience': yearsOfExperience,
      };

      final res = await ApiService.post(
        ApiConfig.register,
        body: payload,
        requireAuth: false,
      );

      _token = res['access_token'];
      await StorageService.saveToken(_token!);
      _currentUser = User.fromJson(res);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerBuyer({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        'email': email.trim(),
        'password': password,
        'full_name': fullName.trim(),
        'phone': phone,
        'role': 'buyer',
      };

      final res = await ApiService.post(
        ApiConfig.register,
        body: payload,
        requireAuth: false,
      );

      _token = res['access_token'];
      await StorageService.saveToken(_token!);
      _currentUser = User.fromJson(res);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    final storedToken = await StorageService.getToken();
    if (storedToken == null || storedToken.isEmpty) return;

    _token = storedToken;
    try {
      final res = await ApiService.get(ApiConfig.me);
      _currentUser = User.fromJson(res);
      notifyListeners();
    } catch (_) {
      await logout();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    await StorageService.clearAuth();
    notifyListeners();
  }
}
