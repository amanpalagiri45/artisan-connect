import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/linkage.dart';
import '../../state/auth_provider.dart';
import '../../state/artisan_provider.dart';
import '../../widgets/metric_card.dart';
import '../catalog/add_product_screen.dart';

class ArtisanDashboardScreen extends StatefulWidget {
  const ArtisanDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends State<ArtisanDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final artisanProv = Provider.of<ArtisanProvider>(context, listen: false);
    artisanProv.fetchDashboardMetrics();
    artisanProv.fetchArtisanLinkages();
  }

  void _handleStatusChange(int linkageId, String newStatus) async {
    final artisanProv = Provider.of<ArtisanProvider>(context, listen: false);
    final success = await artisanProv.updateLinkageStatus(linkageId, newStatus);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inquiry marked as $newStatus! Buyer notified.'),
          backgroundColor: AppTheme.sageAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final artisanProv = Provider.of<ArtisanProvider>(context);
    final data = artisanProv.dashboardData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artisan Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Metrics',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
        backgroundColor: AppTheme.primaryTerracotta,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Listing'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        color: AppTheme.primaryTerracotta,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryTerracotta.withOpacity(0.15),
                      child: const Icon(Icons.handyman, color: AppTheme.primaryTerracotta, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.currentUser?.fullName ?? 'Artisan Maker',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Active Marketplace Linkage Partner',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // KPI Metrics 2x2 Grid
              const Text(
                'Key Sales & Linkage Metrics',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Pipeline Revenue',
                      value: '\$${(data?.totalPotentialRevenue ?? 0.0).toStringAsFixed(0)}',
                      subtitle: 'Active Linkage Value',
                      icon: Icons.monetization_on_outlined,
                      iconColor: AppTheme.sageAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Buyer Inquiries',
                      value: '${data?.totalInquiries ?? 0}',
                      subtitle: '${data?.pendingInquiries ?? 0} awaiting review',
                      icon: Icons.mark_email_unread_outlined,
                      iconColor: AppTheme.primaryOchre,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'Active Listings',
                      value: '${data?.totalProducts ?? 0}',
                      subtitle: 'In global catalog',
                      icon: Icons.storefront_outlined,
                      iconColor: AppTheme.primaryTerracotta,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      title: 'Catalog Views',
                      value: '${data?.totalViews ?? 0}',
                      subtitle: '${data?.conversionRatePercent.toStringAsFixed(1)}% conversion',
                      icon: Icons.insights_outlined,
                      iconColor: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Inquiries / Market Linkages Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Buyer Linkage Inquiries',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  Text(
                    '${artisanProv.linkages.length} total',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (artisanProv.linkages.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 40, color: AppTheme.textSecondary),
                      SizedBox(height: 8),
                      Text('No buyer inquiries yet', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('New inquiries from retail and ethical buyers will appear here.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: artisanProv.linkages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final linkage = artisanProv.linkages[index];
                    return _buildLinkageCard(linkage);
                  },
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkageCard(MarketLinkage linkage) {
    Color statusColor = AppTheme.primaryOchre;
    if (linkage.status == LinkageStatus.accepted) statusColor = AppTheme.badgeVerified;
    if (linkage.status == LinkageStatus.declined) statusColor = Colors.redAccent;
    if (linkage.status == LinkageStatus.completed) statusColor = Colors.blueAccent;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  linkage.buyerName ?? 'Conscious Buyer',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  linkage.status.name.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Order: ${linkage.quantity}x ${linkage.productTitle ?? "Custom Craft"}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
          ),
          if (linkage.proposedUnitPrice != null)
            Text(
              'Offered: \$${linkage.proposedUnitPrice!.toStringAsFixed(2)} / unit • Total: \$${(linkage.proposedUnitPrice! * linkage.quantity).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryTerracotta, fontWeight: FontWeight.w600),
            ),
          const SizedBox(height: 6),
          Text(
            '"${linkage.buyerNotes}"',
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),

          // Actions if pending
          if (linkage.status == LinkageStatus.pending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleStatusChange(linkage.id, 'accepted'),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accept', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.sageAccent,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleStatusChange(linkage.id, 'declined'),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Decline', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
