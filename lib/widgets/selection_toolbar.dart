import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../l10n/app_strings.dart';

class SelectionToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onAddHashtag;
  final VoidCallback onCancel;
  final VoidCallback? onRemove;
  final String? removeLabel;

  const SelectionToolbar({
    super.key,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onAddHashtag,
    required this.onCancel,
    this.onRemove,
    this.removeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardTheme.color ?? AppColors.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(onPressed: onCancel, icon: const Icon(Icons.close)),
              Expanded(
                child: Text(
                  '$selectedCount ${context.tr('selectedCount')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(onPressed: onSelectAll, child: Text(context.tr('selectAll'))),
              if (onRemove != null)
                IconButton(
                  tooltip: removeLabel,
                  onPressed: selectedCount == 0 ? null : onRemove,
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                ),
              const SizedBox(width: 4),
              ElevatedButton.icon(
                onPressed: selectedCount == 0 ? null : onAddHashtag,
                icon: const Icon(Icons.local_offer_outlined, size: 18),
                label: Text(context.tr('addHashtag')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
