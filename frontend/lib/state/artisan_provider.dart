import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/linkage.dart';
import '../services/api_service.dart';

class ArtisanDashboardData {
  final int totalProducts;
  final int totalInquiries;
  final int pendingInquiries;
  final int acceptedLinkages;
  final int completedLinkages;
  final double totalPotentialRevenue;
  final int totalViews;
  final double conversionRatePercent;
  final List<dynamic> recentInquiries;
  final List<dynamic> topProducts;

  ArtisanDashboardData({
    required this.totalProducts,
    required this.totalInquiries,
    required this.pendingInquiries,
    required this.acceptedLinkages,
    required this.completedLinkages,
    required this.totalPotentialRevenue,
    required this.totalViews,
    required this.conversionRatePercent,
    required this.recentInquiries,
    required this.topProducts,
  });

  factory ArtisanDashboardData.fromJson(Map<String, dynamic> json) {
    return ArtisanDashboardData(
      totalProducts: json['total_products'] ?? 0,
      totalInquiries: json['total_inquiries'] ?? 0,
      pendingInquiries: json['pending_inquiries'] ?? 0,
      acceptedLinkages: json['accepted_linkages'] ?? 0,
      completedLinkages: json['completed_linkages'] ?? 0,
      totalPotentialRevenue: (json['total_potential_revenue'] as num?)?.toDouble() ?? 0.0,
      totalViews: json['total_views'] ?? 0,
      conversionRatePercent: (json['conversion_rate_percent'] as num?)?.toDouble() ?? 0.0,
      recentInquiries: json['recent_inquiries'] ?? [],
      topProducts: json['top_performing_products'] ?? [],
    );
  }
}

class ArtisanProvider extends ChangeNotifier {
  ArtisanDashboardData? _dashboardData;
  List<MarketLinkage> _linkages = [];
  List<MatchedArtisan> _matchedArtisans = [];
  bool _isLoading = false;
  String? _errorMessage;

  ArtisanDashboardData? get dashboardData => _dashboardData;
  List<MarketLinkage> get linkages => _linkages;
  List<MatchedArtisan> get matchedArtisans => _matchedArtisans;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardMetrics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.get(ApiConfig.artisanDashboard);
      _dashboardData = ArtisanDashboardData.fromJson(res);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchArtisanLinkages() async {
    try {
      final res = await ApiService.get(ApiConfig.artisanLinkages);
      if (res is List) {
        _linkages = res.map((item) => MarketLinkage.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> updateLinkageStatus(int linkageId, String newStatus, {String? notes}) async {
    try {
      final body = {
        'status': newStatus,
        'artisan_notes': notes,
      };
      await ApiService.put('${ApiConfig.baseUrl}/linkages/$linkageId/status', body: body);
      await fetchArtisanLinkages();
      await fetchDashboardMetrics();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitBuyerInquiry({
    required int artisanId,
    int? productId,
    required int quantity,
    double? proposedUnitPrice,
    required String notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {
        'artisan_id': artisanId,
        'product_id': productId,
        'quantity': quantity,
        'proposed_unit_price': proposedUnitPrice,
        'buyer_notes': notes,
      };

      await ApiService.post(ApiConfig.linkagesInquire, body: body);
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

  Future<void> findMatches({
    required String craftType,
    String? materialsNeeded,
    double? maxBudget,
    String? preferredRegion,
    int quantity = 10,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final body = {
        'craft_type': craftType,
        'materials_needed': materialsNeeded,
        'max_budget_per_unit': maxBudget,
        'preferred_region': preferredRegion,
        'order_quantity': quantity,
      };

      final res = await ApiService.post(ApiConfig.linkagesMatch, body: body, requireAuth: false);
      if (res is List) {
        _matchedArtisans = res.map((item) => MatchedArtisan.fromJson(item)).toList();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
