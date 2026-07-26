import 'package:flutter/material.dart';

/// Hash Gallery — "Luxury Warm Palette"
/// The exact color system requested for the app. Values are used literally
/// for Light Mode; Dark Mode is derived from the same warm identity.
class AppColors {
  AppColors._();

  // Light mode — literal palette
  static const Color primary = Color(0xFFD97706); // Burnt Orange
  static const Color primaryHover = Color(0xFFB45309); // Deep Orange
  static const Color secondary = Color(0xFF5B4636); // Warm Brown
  static const Color background = Color(0xFFFAF7F2); // Warm Beige
  static const Color surface = Color(0xFFFFFFFF); // Off White
  static const Color border = Color(0xFFE7E1D7); // Soft Gray
  static const Color textPrimary = Color(0xFF1F2937); // Charcoal
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red

  // Dark mode — derived from the same warm identity, keeping Burnt Orange
  // as the signature primary color in both themes.
  static const Color darkBackground = Color(0xFF211A14); // warm near-charcoal
  static const Color darkSurface = Color(0xFF2E2620); // warm dark gray
  static const Color darkBorder = Color(0xFF453B31);
  static const Color darkTextPrimary = Color(0xFFF5F1EA);
  static const Color darkTextSecondary = Color(0xFFB8AFA3);

  /// A curated, "colorful & playful" set of warm-coordinated swatches used
  /// for hashtag colors — either auto-assigned or manually picked by the
  /// user from a grid of these presets. Kept as hex strings (the same
  /// format hashtags are stored in) to avoid depending on any Color
  /// component getters that vary across Flutter SDK versions.
  static const List<String> hashtagPaletteHex = [
    '#D97706', // burnt orange
    '#DC2626', // warm red
    '#E11D48', // rose
    '#DB2777', // magenta pink
    '#9333EA', // plum purple
    '#4F46E5', // indigo
    '#0EA5E9', // sky blue
    '#0D9488', // teal
    '#16A34A', // forest green
    '#65A30D', // olive green
    '#CA8A04', // mustard yellow
    '#EA580C', // terracotta
    '#92400E', // deep brown-orange
    '#7C3AED', // violet
    '#C2410C', // rust
    '#0891B2', // cyan
  ];

  /// Parses a '#RRGGBB' (or '#AARRGGBB') hex string into a [Color]. This is
  /// the only direction we need at runtime — hashtag colors are always
  /// stored and read back as hex strings.
  static Color fromHex(String hex) {
    var value = hex.replaceFirst('#', '').trim();
    if (value.length == 6) value = 'FF$value';
    return Color(int.parse(value, radix: 16));
  }
}
