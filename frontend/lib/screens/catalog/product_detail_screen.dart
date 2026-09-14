import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/product.dart';
import '../../state/auth_provider.dart';
import '../../state/product_provider.dart';
import '../../state/artisan_provider.dart';
import '../../widgets/artisan_badge.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final prodProv = Provider.of<ProductProvider>(context, listen: false);
    final p = await prodProv.fetchProductDetail(widget.productId);
    if (mounted) {
      setState(() {
        _product = p;
        _isLoading = false;
      });
    }
  }

  void _openInquiryModal() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in as a buyer or guest to send an inquiry.'),
          backgroundColor: AppTheme.primaryOchre,
        ),
      );
      return;
    }

    final quantityController = TextEditingController(text: '10');
    final priceController = TextEditingController(
      text: _product?.price.toStringAsFixed(2) ?? '',
    );
    final notesController = TextEditingController(
      text: 'We are interested in procuring this handcrafted piece for our boutique collection. Please share availability and lead times.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Direct Market Linkage Inquiry',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.primaryTerracotta),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Inquire directly with ${_product?.artisanName ?? "Artisan"}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity (units)',
                          prefixIcon: Icon(Icons.numbers_outlined, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Target Unit Price (\$)',
                          prefixIcon: Icon(Icons.attach_money, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Inquiry Notes & Requirements',
                    hintText: 'Describe your customization, delivery timeline, or retail needs...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () async {
                    final qty = int.tryParse(quantityController.text) ?? 1;
                    final unitP = double.tryParse(priceController.text);
                    final artisanProv = Provider.of<ArtisanProvider>(context, listen: false);

                    Navigator.pop(ctx);
                    final success = await artisanProv.submitBuyerInquiry(
                      artisanId: _product!.artisanId,
                      productId: _product!.id,
                      quantity: qty,
                      proposedUnitPrice: unitP,
                      notes: notesController.text,
                    );

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Inquiry sent successfully! The artisan has been notified.'),
                          backgroundColor: AppTheme.sageAccent,
                        ),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(artisanProv.errorMessage ?? 'Failed to submit inquiry.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: const Text('Send Market Linkage Inquiry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryTerracotta)),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Not Found')),
        body: const Center(child: Text('This product listing is no longer available.')),
      );
    }

    final p = _product!;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppTheme.borderLight)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fair Trade Price', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                Text(
                  '\$${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryTerracotta),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _openInquiryModal,
                icon: const Icon(Icons.handshake_outlined, size: 20),
                label: const Text('Direct Connect'),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image or Placeholder
            AspectRatio(
              aspectRatio: 1.3,
              child: p.imageUrl != null && p.imageUrl!.isNotEmpty
                  ? Image.network(
                      p.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  ArtisanBadge(
                    isVerified: true,
                    craftType: p.craftType,
                    region: p.artisanRegion,
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    p.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Views counter & creation date
                  Row(
                    children: [
                      const Icon(Icons.visibility_outlined, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('${p.viewsCount} market views', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(width: 16),
                      const Icon(Icons.schedule, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('Crafting lead: ${p.productionTimeDays} days', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Artisan Story Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.parchmentBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppTheme.primaryTerracotta.withOpacity(0.2),
                              child: const Icon(Icons.person, color: AppTheme.primaryTerracotta),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.artisanName ?? 'Master Artisan',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  if (p.artisanCooperative != null)
                                    Text(
                                      p.artisanCooperative!,
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.description,
                          style: const TextStyle(fontSize: 13.5, height: 1.45, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Craft Specifications Grid
                  const Text('Craft & Material Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildSpecRow('Materials', p.materials ?? 'Traditional indigenous materials'),
                  if (p.dimensions != null) _buildSpecRow('Dimensions', p.dimensions!),
                  _buildSpecRow('Stock Available', '${p.stockQuantity} units in cooperative storage'),
                  _buildSpecRow('Fair Wages', 'Direct artisan payout without predatory middlemen'),
                  const SizedBox(height: 20),

                  // AI Smart Tags
                  if (p.tagsList.isNotEmpty) ...[
                    const Text('Market Linkage & SEO Tags', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: p.tagsList.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFE8DFD3),
      child: const Center(
        child: Icon(Icons.handyman_outlined, size: 64, color: AppTheme.primaryTerracotta),
      ),
    );
  }
}
