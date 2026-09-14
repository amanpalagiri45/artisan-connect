class Product {
  final int id;
  final int artisanId;
  final String title;
  final String description;
  final double price;
  final String craftType;
  final String? materials;
  final String? dimensions;
  final double? weightGrams;
  final int productionTimeDays;
  final int stockQuantity;
  final String? imageUrl;
  final String? aiTags;
  final double? aiSuggestedPrice;
  final bool isAvailable;
  final int viewsCount;
  final DateTime createdAt;
  final String? artisanName;
  final String? artisanRegion;
  final String? artisanCooperative;

  Product({
    required this.id,
    required this.artisanId,
    required this.title,
    required this.description,
    required this.price,
    required this.craftType,
    this.materials,
    this.dimensions,
    this.weightGrams,
    this.productionTimeDays = 3,
    this.stockQuantity = 1,
    this.imageUrl,
    this.aiTags,
    this.aiSuggestedPrice,
    this.isAvailable = true,
    this.viewsCount = 0,
    required this.createdAt,
    this.artisanName,
    this.artisanRegion,
    this.artisanCooperative,
  });

  List<String> get tagsList {
    if (aiTags == null || aiTags!.isEmpty) return [];
    return aiTags!.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      artisanId: json['artisan_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      craftType: json['craft_type'] ?? 'Handcrafted',
      materials: json['materials'],
      dimensions: json['dimensions'],
      weightGrams: (json['weight_grams'] as num?)?.toDouble(),
      productionTimeDays: json['production_time_days'] ?? 3,
      stockQuantity: json['stock_quantity'] ?? 1,
      imageUrl: json['image_url'],
      aiTags: json['ai_tags'],
      aiSuggestedPrice: (json['ai_suggested_price'] as num?)?.toDouble(),
      isAvailable: json['is_available'] ?? true,
      viewsCount: json['views_count'] ?? 0,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now() 
          : DateTime.now(),
      artisanName: json['artisan_name'],
      artisanRegion: json['artisan_region'],
      artisanCooperative: json['artisan_cooperative'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'craft_type': craftType,
      'materials': materials,
      'dimensions': dimensions,
      'weight_grams': weightGrams,
      'production_time_days': productionTimeDays,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
      'ai_tags': aiTags,
      'ai_suggested_price': aiSuggestedPrice,
    };
  }
}

class SmartCatalogSuggestion {
  final String suggestedTitle;
  final String enhancedDescription;
  final double suggestedPriceMin;
  final double suggestedPriceMax;
  final double recommendedPrice;
  final List<String> suggestedTags;
  final List<String> detectedMaterials;
  final String craftCategory;
  final double fairTradeMarginPercent;

  SmartCatalogSuggestion({
    required this.suggestedTitle,
    required this.enhancedDescription,
    required this.suggestedPriceMin,
    required this.suggestedPriceMax,
    required this.recommendedPrice,
    required this.suggestedTags,
    required this.detectedMaterials,
    required this.craftCategory,
    required this.fairTradeMarginPercent,
  });

  factory SmartCatalogSuggestion.fromJson(Map<String, dynamic> json) {
    return SmartCatalogSuggestion(
      suggestedTitle: json['suggested_title'] ?? '',
      enhancedDescription: json['enhanced_description'] ?? '',
      suggestedPriceMin: (json['suggested_price_min'] as num?)?.toDouble() ?? 0.0,
      suggestedPriceMax: (json['suggested_price_max'] as num?)?.toDouble() ?? 0.0,
      recommendedPrice: (json['recommended_price'] as num?)?.toDouble() ?? 0.0,
      suggestedTags: List<String>.from(json['suggested_tags'] ?? []),
      detectedMaterials: List<String>.from(json['detected_materials'] ?? []),
      craftCategory: json['craft_category'] ?? 'Artisan Craft',
      fairTradeMarginPercent: (json['fair_trade_margin_percent'] as num?)?.toDouble() ?? 30.0,
    );
  }
}
