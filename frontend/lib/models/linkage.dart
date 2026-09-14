enum LinkageStatus { pending, accepted, declined, in_progress, completed }

class MarketLinkage {
  final int id;
  final int buyerId;
  final int artisanId;
  final int? productId;
  final LinkageStatus status;
  final int quantity;
  final double? proposedUnitPrice;
  final String buyerNotes;
  final String? artisanNotes;
  final double matchScore;
  final String? targetDeliveryDate;
  final DateTime createdAt;
  final String? buyerName;
  final String? buyerEmail;
  final String? artisanName;
  final String? artisanCraft;
  final String? productTitle;

  MarketLinkage({
    required this.id,
    required this.buyerId,
    required this.artisanId,
    this.productId,
    required this.status,
    required this.quantity,
    this.proposedUnitPrice,
    required this.buyerNotes,
    this.artisanNotes,
    this.matchScore = 0.0,
    this.targetDeliveryDate,
    required this.createdAt,
    this.buyerName,
    this.buyerEmail,
    this.artisanName,
    this.artisanCraft,
    this.productTitle,
  });

  factory MarketLinkage.fromJson(Map<String, dynamic> json) {
    LinkageStatus parsedStatus = LinkageStatus.pending;
    final st = (json['status'] as String?)?.toLowerCase();
    if (st == 'accepted') {
      parsedStatus = LinkageStatus.accepted;
    } else if (st == 'declined') {
      parsedStatus = LinkageStatus.declined;
    } else if (st == 'in_progress') {
      parsedStatus = LinkageStatus.in_progress;
    } else if (st == 'completed') {
      parsedStatus = LinkageStatus.completed;
    }

    return MarketLinkage(
      id: json['id'] ?? 0,
      buyerId: json['buyer_id'] ?? 0,
      artisanId: json['artisan_id'] ?? 0,
      productId: json['product_id'],
      status: parsedStatus,
      quantity: json['quantity'] ?? 1,
      proposedUnitPrice: (json['proposed_unit_price'] as num?)?.toDouble(),
      buyerNotes: json['buyer_notes'] ?? '',
      artisanNotes: json['artisan_notes'],
      matchScore: (json['match_score'] as num?)?.toDouble() ?? 0.0,
      targetDeliveryDate: json['target_delivery_date'],
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
      buyerName: json['buyer_name'],
      buyerEmail: json['buyer_email'],
      artisanName: json['artisan_name'],
      artisanCraft: json['artisan_craft'],
      productTitle: json['product_title'],
    );
  }
}

class MatchedArtisan {
  final int artisanId;
  final String artisanName;
  final String craftType;
  final String region;
  final String? communityCooperative;
  final double matchScore;
  final List<String> matchReasons;
  final int? sampleProductId;
  final String? sampleProductTitle;
  final double? sampleProductPrice;

  MatchedArtisan({
    required this.artisanId,
    required this.artisanName,
    required this.craftType,
    required this.region,
    this.communityCooperative,
    required this.matchScore,
    required this.matchReasons,
    this.sampleProductId,
    this.sampleProductTitle,
    this.sampleProductPrice,
  });

  factory MatchedArtisan.fromJson(Map<String, dynamic> json) {
    return MatchedArtisan(
      artisanId: json['artisan_id'] ?? 0,
      artisanName: json['artisan_name'] ?? 'Artisan',
      craftType: json['craft_type'] ?? 'Craft',
      region: json['region'] ?? '',
      communityCooperative: json['community_cooperative'],
      matchScore: (json['match_score'] as num?)?.toDouble() ?? 0.0,
      matchReasons: List<String>.from(json['match_reasons'] ?? []),
      sampleProductId: json['sample_product_id'],
      sampleProductTitle: json['sample_product_title'],
      sampleProductPrice: (json['sample_product_price'] as num?)?.toDouble(),
    );
  }
}
