import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class FilterSection {
  final String id;
  final String title;
  final List<String> options;
  final String selected;
  final String? defaultValue;

  const FilterSection({
    required this.id,
    required this.title,
    required this.options,
    required this.selected,
    this.defaultValue,
  });
}

class FilterBottomSheet extends StatefulWidget {
  final String title;
  final List<FilterSection> sections;
  final void Function(Map<String, String> values) onApply;
  final String applyLabel;
  final String resetLabel;

  const FilterBottomSheet({
    super.key,
    required this.title,
    required this.sections,
    required this.onApply,
    this.applyLabel = 'Appliquer',
    this.resetLabel = 'Reinitialiser',
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<FilterSection> sections,
    required void Function(Map<String, String> values) onApply,
    String applyLabel = 'Appliquer',
    String resetLabel = 'Reinitialiser',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (_) => FilterBottomSheet(
        title: title,
        sections: sections,
        onApply: onApply,
        applyLabel: applyLabel,
        resetLabel: resetLabel,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {
      for (final section in widget.sections)
        section.id: _initialValue(section),
    };
  }

  String _initialValue(FilterSection section) {
    final candidate = section.selected.trim();
    if (section.options.contains(candidate)) {
      return candidate;
    }
    if (section.defaultValue != null &&
        section.options.contains(section.defaultValue)) {
      return section.defaultValue!;
    }
    return section.options.isNotEmpty ? section.options.first : '';
  }

  void _reset() {
    setState(() {
      _selected = {
        for (final section in widget.sections)
          section.id: section.defaultValue ??
              (section.options.isNotEmpty ? section.options.first : ''),
      };
    });
  }

  void _apply() {
    widget.onApply(_selected);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
             
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ..._buildSections(scheme),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: Text(widget.resetLabel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      child: Text(widget.applyLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections(ColorScheme scheme) {
    final List<Widget> widgets = [];
    for (final section in widget.sections) {
      widgets.addAll([
        Text(
          section.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: section.options.map((option) {
            final selected = _selected[section.id] == option;
            return ChoiceChip(
              label: Text(option),
              selected: selected,
              showCheckmark: false,
              selectedColor: scheme.secondary.withValues(alpha: 0.16),
              backgroundColor: scheme.surface,
              labelStyle: TextStyle(
                color: selected ? scheme.secondary : scheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: selected
                      ? scheme.secondary
                      : scheme.onSurface.withValues(alpha: 0.18),
                ),
              ),
              onSelected: (_) {
                setState(() {
                  _selected[section.id] = option;
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
      ]);
    }
    return widgets;
  }
}
