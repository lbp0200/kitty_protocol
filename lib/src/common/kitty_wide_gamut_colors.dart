/// Kitty Wide Gamut Colors - OKLCH and CIE LAB color formats for SGR sequences
///
/// Reference: doc/kitty/docs/wide-gamut-colors.rst
///
/// This module provides color encoders for wide gamut color spaces:
/// - OKLCH: Perceptually uniform color space
/// - CIE LAB: Device-independent color space
library kitty_protocol_wide_gamut_colors;

/// Color space types
enum KittyColorSpace {
  /// sRGB (standard)
  srgb,
  /// OKLCH - Perceptually uniform
  oklch,
  /// CIE LAB
  lab,
}

/// Wide gamut color encoder
///
/// Per wide-gamut-colors.rst:
///
/// OKLCH format: oklch(L C H)
/// - L: Lightness 0-1
/// - C: Chroma 0-0.4
/// - H: Hue 0-360
///
/// LAB format: lab(L a b)
/// - L: Lightness 0-100
/// - a: Green(-) to Red(+)
/// - b: Blue(-) to Yellow(+)
class KittyWideGamutColor {
  KittyWideGamutColor._();

  // ============ sRGB Colors (standard) ============

  /// Create sRGB color from 8-bit RGB values
  ///
  /// Format: 2;R;G;B
  static String rgb8(int r, int g, int b) {
    return '2;$r;$g;$b';
  }

  /// Create sRGB color from hex string
  ///
  /// Format: 2;R;G;B
  /// Accepts: #RGB, #RRGGBB, #RRGGBBAA
  static String fromHex(String hex) {
    // Remove # prefix
    hex = hex.replaceFirst('#', '');

    int r, g, b;
    if (hex.length == 3) {
      // #RGB
      r = int.parse(hex[0] + hex[0], radix: 16);
      g = int.parse(hex[1] + hex[1], radix: 16);
      b = int.parse(hex[2] + hex[2], radix: 16);
    } else if (hex.length == 6) {
      // #RRGGBB
      r = int.parse(hex.substring(0, 2), radix: 16);
      g = int.parse(hex.substring(2, 4), radix: 16);
      b = int.parse(hex.substring(4, 6), radix: 16);
    } else if (hex.length == 8) {
      // #RRGGBBAA
      r = int.parse(hex.substring(0, 2), radix: 16);
      g = int.parse(hex.substring(2, 4), radix: 16);
      b = int.parse(hex.substring(4, 6), radix: 16);
    } else {
      throw ArgumentError('Invalid hex color: $hex');
    }

    return rgb8(r, g, b);
  }

  // ============ OKLCH Colors ============

  /// Create OKLCH color
  ///
  /// Per wide-gamut-colors.rst line 12-14:
  ///   foreground oklch(0.9 0.05 140)
  ///
  /// Format: 4;L;C;H
  /// - L: Lightness 0-1
  /// - C: Chroma 0-0.4
  /// - H: Hue 0-360
  static String oklch(double lightness, double chroma, double hue) {
    // Clamp values to valid ranges
    lightness = lightness.clamp(0.0, 1.0);
    chroma = chroma.clamp(0.0, 0.4);
    hue = hue % 360;

    return '4;${lightness.toStringAsFixed(3)};${chroma.toStringAsFixed(3)};${hue.toStringAsFixed(1)}';
  }

  /// Create OKLCH color from string
  ///
  /// Accepts: oklch(0.9 0.05 140)
  static String parseOklch(String oklchStr) {
    // Extract numbers from oklch(L C H)
    final match = RegExp(r'oklch\(([\d.]+)\s+([\d.]+)\s+([\d.]+)\)').firstMatch(oklchStr);
    if (match == null) {
      throw ArgumentError('Invalid OKLCH format: $oklchStr');
    }

    final l = double.parse(match.group(1)!);
    final c = double.parse(match.group(2)!);
    final h = double.parse(match.group(3)!);

    return oklch(l, c, h);
  }

  // ============ CIE LAB Colors ============

  /// Create CIE LAB color
  ///
  /// Per wide-gamut-colors.rst line 41-44:
  ///   background lab(20 5 -10)
  ///
  /// Format: 5;L;a;b
  /// - L: Lightness 0-100
  /// - a: Green(-) to Red(+), typically -100 to +100
  /// - b: Blue(-) to Yellow(+), typically -100 to +100
  static String lab(double lightness, double a, double b) {
    // Clamp L to valid range
    lightness = lightness.clamp(0.0, 100.0);

    return '5;${lightness.toStringAsFixed(1)};${a.toStringAsFixed(1)};${b.toStringAsFixed(1)}';
  }

  /// Create LAB color from string
  ///
  /// Accepts: lab(20 5 -10)
  static String parseLab(String labStr) {
    // Extract numbers from lab(L a b)
    final match = RegExp(r'lab\(([+-]?\d+\.?\d*)\s+([+-]?\d+\.?\d*)\s+([+-]?\d+\.?\d*)\)').firstMatch(labStr);
    if (match == null) {
      throw ArgumentError('Invalid LAB format: $labStr');
    }

    final l = double.parse(match.group(1)!);
    final a = double.parse(match.group(2)!);
    final b = double.parse(match.group(3)!);

    return lab(l, a, b);
  }

  // ============ SGR Sequence Builder ============

  /// Build SGR color sequence
  ///
  /// Format: CSI 38 or 48 ; color_spec m
  /// - 38 = foreground
  /// - 48 = background
  static String foreground(String colorSpec) {
    return '38;$colorSpec';
  }

  /// Build SGR background color sequence
  static String background(String colorSpec) {
    return '48;$colorSpec';
  }
}

/// SGR sequence helper for wide gamut colors
class KittySgrWideGamut {
  KittySgrWideGamut._();

  /// Create foreground color escape sequence
  ///
  /// Example: \x1b[38;4;0.9;0.05;140m for OKLCH foreground
  static String foreground(String colorSpec) {
    return '\x1b[38;${colorSpec}m';
  }

  /// Create background color escape sequence
  static String background(String colorSpec) {
    return '\x1b[48;${colorSpec}m';
  }

  // ============ Convenience Methods ============

  /// Set foreground to OKLCH color
  static String foregroundOklch(double l, double c, double h) {
    return foreground(KittyWideGamutColor.oklch(l, c, h));
  }

  /// Set background to OKLCH color
  static String backgroundOklch(double l, double c, double h) {
    return background(KittyWideGamutColor.oklch(l, c, h));
  }

  /// Set foreground to LAB color
  static String foregroundLab(double l, double a, double b) {
    return foreground(KittyWideGamutColor.lab(l, a, b));
  }

  /// Set background to LAB color
  static String backgroundLab(double l, double a, double b) {
    return background(KittyWideGamutColor.lab(l, a, b));
  }

  /// Reset to default colors
  static String reset() {
    return '\x1b[0m';
  }
}
