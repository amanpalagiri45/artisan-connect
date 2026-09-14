import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../state/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _craftTypeController = TextEditingController(text: 'Terracotta Pottery');
  final _materialsController = TextEditingController();
  final _dimensionsController = TextEditingController(text: '15 x 15 x 20 cm');
  final _leadTimeController = TextEditingController(text: '4');
  final _stockController = TextEditingController(text: '10');
  final _imageUrlController = TextEditingController(
    text: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
  );
  final _tagsController = TextEditingController();

  double? _aiSuggestedPrice;

  void _runSmartCatalogAI() async {
    final prodProv = Provider.of<ProductProvider>(context, listen: false);
    if (_craftTypeController.text.isEmpty || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Craft Type and at least a brief Description first.'),
          backgroundColor: AppTheme.primaryOchre,
        ),
      );
      return;
    }

    try {
      await prodProv.requestSmartSuggestion(
        craftType: _craftTypeController.text,
        rawDescription: _descController.text,
        estimatedHours: double.tryParse(_leadTimeController.text) ?? 4.0,
        materialCost: 12.0,
      );

      final suggestion = prodProv.aiSuggestion;
      if (suggestion != null && mounted) {
        setState(() {
          if (_titleController.text.isEmpty) {
            _titleController.text = suggestion.suggestedTitle;
          }
          _descController.text = suggestion.enhancedDescription;
          _priceController.text = suggestion.recommendedPrice.toStringAsFixed(2);
          _aiSuggestedPrice = suggestion.recommendedPrice;
          _materialsController.text = suggestion.detectedMaterials.join(', ');
          _tagsController.text = suggestion.suggestedTags.join(', ');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI Enhanced Listing: Suggested Fair Trade Price \$${suggestion.recommendedPrice.toStringAsFixed(2)}'),
            backgroundColor: AppTheme.sageAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Suggestion error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    final prodProv = Provider.of<ProductProvider>(context, listen: false);
    final price = double.tryParse(_priceController.text) ?? 0.0;

    final success = await prodProv.createProduct(
      title: _titleController.text,
      description: _descController.text,
      price: price,
      craftType: _craftTypeController.text,
      materials: _materialsController.text.isNotEmpty ? _materialsController.text : null,
      dimensions: _dimensionsController.text.isNotEmpty ? _dimensionsController.text : null,
      productionTimeDays: int.tryParse(_leadTimeController.text) ?? 3,
      stockQuantity: int.tryParse(_stockController.text) ?? 1,
      imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
      aiTags: _tagsController.text.isNotEmpty ? _tagsController.text : null,
      aiSuggestedPrice: _aiSuggestedPrice,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Craft listing published successfully to global catalog!'),
          backgroundColor: AppTheme.sageAccent,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(prodProv.errorMessage ?? 'Failed to publish listing.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _craftTypeController.dispose();
    _materialsController.dispose();
    _dimensionsController.dispose();
    _leadTimeController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prodProv = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Craft Listing'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AI Smart Cataloging Assistant Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF6ED), Color(0xFFFAF0E6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryOchre.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppTheme.primaryOchre, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'AI Smart Cataloging Assistant',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryTerracotta),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Provide your raw crafting notes. Our AI will automatically synthesize a rich cultural story, detect materials, recommend fair-trade pricing, and generate SEO discovery tags.',
                        style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary, height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: prodProv.isAnalyzingAI ? null : _runSmartCatalogAI,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppTheme.primaryOchre),
                        ),
                        icon: prodProv.isAnalyzingAI
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryOchre),
                              )
                            : const Icon(Icons.psychology_outlined, color: AppTheme.primaryOchre, size: 18),
                        label: Text(
                          prodProv.isAnalyzingAI ? 'Analyzing Craft...' : 'Auto-Enhance with AI',
                          style: const TextStyle(color: AppTheme.primaryOchre, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Craft Type
                TextFormField(
                  controller: _craftTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Craft Category *',
                    hintText: 'e.g. Pottery, Handloom, Metalcraft',
                    prefixIcon: Icon(Icons.handyman_outlined),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Craft category is required' : null,
                ),
                const SizedBox(height: 14),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Listing Title *',
                    hintText: 'e.g. Cobalt Blue Peacock Floral Urn',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 14),

                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Craft Story & Description *',
                    hintText: 'Describe how this was made, inspiration, and heritage background...',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v == null || v.length < 5 ? 'Description is required' : null,
                ),
                const SizedBox(height: 14),

                // Price & Stock
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Price (\$) *',
                          prefixIcon: const Icon(Icons.attach_money),
                          helperText: _aiSuggestedPrice != null
                              ? 'AI Target: \$${_aiSuggestedPrice!.toStringAsFixed(2)}'
                              : null,
                        ),
                        validator: (v) => v == null || double.tryParse(v) == null ? 'Valid price required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock Qty',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Materials & Dimensions
                TextFormField(
                  controller: _materialsController,
                  decoration: const InputDecoration(
                    labelText: 'Materials Used',
                    hintText: 'e.g. Alluvial clay, cobalt oxide glaze, natural dyes',
                    prefixIcon: Icon(Icons.texture_outlined),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dimensionsController,
                        decoration: const InputDecoration(
                          labelText: 'Dimensions',
                          hintText: 'e.g. 15 x 25 cm',
                          prefixIcon: Icon(Icons.straighten_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _leadTimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Crafting Days',
                          prefixIcon: Icon(Icons.timer_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tags
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'AI Smart & Discovery Tags',
                    hintText: 'Comma-separated, e.g. handwoven, organic, ethical-trade',
                    prefixIcon: Icon(Icons.tag),
                  ),
                ),
                const SizedBox(height: 14),

                // Image URL
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image Web URL',
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.image_outlined),
                  ),
                ),
                const SizedBox(height: 24),

                // Publish Button
                ElevatedButton.icon(
                  onPressed: prodProv.isLoading ? null : _submitListing,
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: prodProv.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Publish Craft to Marketplace'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
