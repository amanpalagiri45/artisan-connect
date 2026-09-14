class ArtisanProfile {
  final int id;
  final int userId;
  final String craftType;
  final String? heritageStory;
  final String? bio;
  final String region;
  final String? communityCooperative;
  final int yearsOfExperience;
  final bool isVerified;
  final String? avatarUrl;
  final String artisanName;
  final String artisanEmail;
  final String? artisanPhone;
  final int totalProducts;

  ArtisanProfile({
    required this.id,
    required this.userId,
    required this.craftType,
    this.heritageStory,
    this.bio,
    required this.region,
    this.communityCooperative,
    this.yearsOfExperience = 1,
    this.isVerified = false,
    this.avatarUrl,
    required this.artisanName,
    required this.artisanEmail,
    this.artisanPhone,
    this.totalProducts = 0,
  });

  factory ArtisanProfile.fromJson(Map<String, dynamic> json) {
    return ArtisanProfile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      craftType: json['craft_type'] ?? 'Traditional Craft',
      heritageStory: json['heritage_story'],
      bio: json['bio'],
      region: json['region'] ?? 'Artisan Cluster',
      communityCooperative: json['community_cooperative'],
      yearsOfExperience: json['years_of_experience'] ?? 1,
      isVerified: json['is_verified'] ?? false,
      avatarUrl: json['avatar_url'],
      artisanName: json['artisan_name'] ?? 'Artisan Maker',
      artisanEmail: json['artisan_email'] ?? '',
      artisanPhone: json['artisan_phone'],
      totalProducts: json['total_products'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'craft_type': craftType,
      'heritage_story': heritageStory,
      'bio': bio,
      'region': region,
      'community_cooperative': communityCooperative,
      'years_of_experience': yearsOfExperience,
      'is_verified': isVerified,
      'avatar_url': avatarUrl,
      'artisan_name': artisanName,
      'artisan_email': artisanEmail,
      'artisan_phone': artisanPhone,
      'total_products': totalProducts,
    };
  }
}
