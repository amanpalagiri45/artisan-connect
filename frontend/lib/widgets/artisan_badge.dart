import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ArtisanBadge extends StatelessWidget {
  final bool isVerified;
  final String? region;
  final String? craftType;

  const ArtisanBadge({
    Key? key,
    this.isVerified = false,
    this.region,
    this.craftType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (isVerified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.badgeVerified.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.badgeVerified.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 13, color: AppTheme.badgeVerified),
                SizedBox(width: 3),
                Text(
                  'Verified Maker',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.badgeVerified),
                ),
              ],
            ),
          ),
        if (region != null && region!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.borderLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textSecondary),
                const SizedBox(width: 3),
                Text(
                  region!,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        if (craftType != null && craftType!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryOchre.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              craftType!,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.primaryOchre),
            ),
          ),
      ],
    );
  }
}
