import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../state/auth_provider.dart';
import '../../state/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/search_bar_widget.dart';
import 'product_detail_screen.dart';
import 'add_product_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _onSearch(String query) {
    final prodProv = Provider.of<ProductProvider>(context, listen: false);
    prodProv.fetchProducts(query: query, craftType: prodProv.selectedCategory);
  }

  void _onCategory(String? category) {
    final prodProv = Provider.of<ProductProvider>(context, listen: false);
    prodProv.fetchProducts(query: prodProv.searchQuery, craftType: category);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primaryOchre, size: 20),
            SizedBox(width: 8),
            Text('Smart Craft Catalog'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Catalog',
            onPressed: () => productProvider.fetchProducts(),
          ),
        ],
      ),
      floatingActionButton: authProvider.isArtisan
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
              backgroundColor: AppTheme.primaryTerracotta,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('List Craft'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Search & Category Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SearchBarWidget(
                onSearchChanged: _onSearch,
                onCategorySelected: _onCategory,
                selectedCategory: productProvider.selectedCategory,
              ),
            ),

            // Products Grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => productProvider.fetchProducts(),
                color: AppTheme.primaryTerracotta,
                child: productProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryTerracotta),
                      )
                    : productProvider.products.isEmpty
                        ? _buildEmptyState(productProvider)
                        : _buildProductGrid(productProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 800 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.72,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            return ProductCard(
              product: product,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(productId: product.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ProductProvider provider) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Handcrafted Items Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching with different keywords, craft terms, or clear the active category filter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                provider.fetchProducts(query: '', craftType: 'All');
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Reset Search & Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
