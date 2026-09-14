import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final Function(String?) onCategorySelected;
  final String? selectedCategory;

  const SearchBarWidget({
    Key? key,
    required this.onSearchChanged,
    required this.onCategorySelected,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  final List<String> _categories = [
    'All',
    'Pottery',
    'Handloom',
    'Metalcraft',
    'Chikankari',
    'Woodwork',
  ];

  void _onQueryChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      widget.onSearchChanged(val);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            onChanged: _onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search craft, materials, region, maker...',
              hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryTerracotta, size: 20),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        widget.onSearchChanged('');
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Horizontal Craft Category Chips
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = (cat == 'All' && widget.selectedCategory == null) ||
                  (widget.selectedCategory == cat);

              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (selected) {
                  widget.onCategorySelected(cat == 'All' ? null : cat);
                },
                selectedColor: AppTheme.primaryTerracotta,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryTerracotta : AppTheme.borderLight,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              );
            },
          ),
        ),
      ],
    );
  }
}
