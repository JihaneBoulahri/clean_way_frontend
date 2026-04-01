import 'package:flutter/material.dart';

class SearchBarField extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onFilterTap;
  final bool filterActive;
  final String filterTooltip;

  const SearchBarField({
    super.key,
    this.hint = 'Rechercher...',
    this.onChanged,
    this.controller,
    this.onFilterTap,
    this.filterActive = false,
    this.filterTooltip = 'Filtrer',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark ? 0.26 : 0.08,
              ),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
            suffixIcon: onFilterTap == null ? null : _buildFilterButton(context),
            suffixIconConstraints: const BoxConstraints(
              minHeight: 42,
              minWidth: 42,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = filterActive
        ? scheme.secondary
        : scheme.onSurface.withValues(alpha: 0.6);
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: filterActive
            ? scheme.secondary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onFilterTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.tune_rounded, color: iconColor),
                if (filterActive)
                  Positioned(
                    top: 8,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: scheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
