import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

class SearchableDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String hint;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  const SearchableDropdown({
    Key? key,
    required this.label,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.value,
    this.validator,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _SearchDialog(
          title: widget.label,
          items: widget.items,
          initialValue: widget.value,
          onSelected: (value) {
            widget.onChanged(value);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _showSearchDialog,
          borderRadius: BorderRadius.circular(12),
          child: FormField<String>(
            validator: widget.validator,
            initialValue: widget.value,
            builder: (state) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.hasError ? AppColors.error : AppColors.borderColor,
                    width: state.hasError ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      Icon(widget.prefixIcon, color: AppColors.cyan),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        widget.value ?? widget.hint,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: widget.value == null 
                              ? AppColors.textSecondary.withOpacity(0.5)
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: AppColors.cyan, size: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchDialog extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? initialValue;
  final Function(String) onSelected;

  const _SearchDialog({
    required this.title,
    required this.items,
    this.initialValue,
    required this.onSelected,
  });

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  late List<String> _filteredItems;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select ${widget.title}', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, color: AppColors.cyan),
                filled: true,
                fillColor: AppColors.cardBackgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                separatorBuilder: (_, __) => const Divider(color: AppColors.borderColor),
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    title: Text(item, style: AppTextStyles.bodyMedium),
                    onTap: () => widget.onSelected(item),
                    tileColor: widget.initialValue == item ? AppColors.cyan.withOpacity(0.1) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
