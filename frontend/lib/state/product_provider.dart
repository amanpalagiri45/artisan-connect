import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _myProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String _searchQuery = '';

  SmartCatalogSuggestion? _aiSuggestion;
  bool _isAnalyzingAI = false;

  List<Product> get products => _products;
  List<Product> get myProducts => _myProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  SmartCatalogSuggestion? get aiSuggestion => _aiSuggestion;
  bool get isAnalyzingAI => _isAnalyzingAI;

  Future<void> fetchProducts({String? query, String? craftType}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
        _searchQuery = query;
      } else {
        _searchQuery = '';
      }

      if (craftType != null && craftType.isNotEmpty && craftType != 'All') {
        queryParams['craft_type'] = craftType;
        _selectedCategory = craftType;
      } else if (craftType == 'All') {
        _selectedCategory = null;
      }

      final res = await ApiService.get(ApiConfig.products, queryParams: queryParams, requireAuth: false);
      if (res is List) {
        _products = res.map((item) => Product.fromJson(item)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchMyListings() async {
    try {
      final res = await ApiService.get(ApiConfig.myListings);
      if (res is List) {
        _myProducts = res.map((item) => Product.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<Product?> fetchProductDetail(int productId) async {
    try {
      final res = await ApiService.get('${ApiConfig.products}/$productId', requireAuth: false);
      final product = Product.fromJson(res);
      // Update in local list if present
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
      return product;
    } catch (e) {
      return null;
    }
  }

  Future<void> requestSmartSuggestion({
    required String craftType,
    required String rawDescription,
    double estimatedHours = 4.0,
    double materialCost = 10.0,
  }) async {
    _isAnalyzingAI = true;
    notifyListeners();

    try {
      final body = {
        'craft_type': craftType,
        'raw_description': rawDescription,
        'estimated_hours': estimatedHours,
        'material_cost': materialCost,
      };

      final res = await ApiService.post(ApiConfig.smartSuggest, body: body, requireAuth: false);
      _aiSuggestion = SmartCatalogSuggestion.fromJson(res);
      _isAnalyzingAI = false;
      notifyListeners();
    } catch (e) {
      _isAnalyzingAI = false;
      notifyListeners();
      rethrow;
    }
  }

  void clearAiSuggestion() {
    _aiSuggestion = null;
    notifyListeners();
  }

  Future<bool> createProduct({
    required String title,
    required String description,
    required double price,
    required String craftType,
    String? materials,
    String? dimensions,
    int productionTimeDays = 3,
    int stockQuantity = 1,
    String? imageUrl,
    String? aiTags,
    double? aiSuggestedPrice,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final body = {
        'title': title,
        'description': description,
        'price': price,
        'craft_type': craftType,
        'materials': materials,
        'dimensions': dimensions,
        'production_time_days': productionTimeDays,
        'stock_quantity': stockQuantity,
        'image_url': imageUrl,
        'ai_tags': aiTags,
        'ai_suggested_price': aiSuggestedPrice,
      };

      final res = await ApiService.post(ApiConfig.products, body: body);
      final newProd = Product.fromJson(res);
      _products.insert(0, newProd);
      _myProducts.insert(0, newProd);
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
}
