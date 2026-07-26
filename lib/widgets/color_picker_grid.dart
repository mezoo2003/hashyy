import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class ColorPickerGrid extends StatelessWidget {
  final String selectedHex;
  final ValueChanged<String> onSelect;

  const ColorPickerGrid({super.key, required this.selectedHex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppColors.hashtagPaletteHex.map((hex) {
        final color = AppColors.fromHex(hex);
        final isSelected = hex.toUpperCase() == selectedHex.toUpperCase();
        return GestureDetector(
          onTap: () => onSelect(hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: isSelected ? 40 : 34,
            height: isSelected ? 40 : 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: AppColors.textPrimary, width: 2.5)
                  : null,
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                  : null,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
          ),
        );
      }).toList(),
    );
  }
}
