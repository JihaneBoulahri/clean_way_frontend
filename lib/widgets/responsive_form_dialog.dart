import 'package:flutter/material.dart';

/// Responsive dialog wrapper that adapts to screen size and orientation
class ResponsiveFormDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool scrollable;
  final EdgeInsets contentPadding;

  const ResponsiveFormDialog({
    Key? key,
    required this.title,
    required this.content,
    this.actions,
    this.scrollable = true,
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmall = mediaQuery.size.width < 500;
    final isMobile = mediaQuery.size.width < 600;

    // Calculate responsive dimensions
    final dialogWidth = isSmall
        ? mediaQuery.size.width * 0.9
        : (isMobile ? mediaQuery.size.width * 0.85 : 600.0);

    final maxHeight = mediaQuery.size.height * 0.8;

    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: contentPadding,
                      child: content,
                    ),
                  ),
                ),
                // Actions footer
                if (actions != null && actions!.isNotEmpty) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: actions!,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
