/// Kitty Underline Helper - Styled and colored underlines for Kitty Protocol
///
/// Reference: docs/kitty/docs/underlines.rst
/// Underline styles per Kitty protocol
enum KittyUnderlineStyle {
  /// No underline
  none(0),
  /// Straight underline
  straight(1),
  /// Double underline
  double_(2),
  /// Curly underline (wavy)
  curly(3),
  /// Dotted underline
  dotted(4),
  /// Dashed underline
  dashed(5);

  final int value;
  const KittyUnderlineStyle(this.value);
}

/// Underline color modes
enum KittyUnderlineColorMode {
  /// 256-color mode
  color256(5),
  /// True color (24-bit RGB)
  trueColor(2);

  final int value;
  const KittyUnderlineColorMode(this.value);
}

/// Helper class for generating underline escape sequences
///
/// This provides CSI-based sequences for styled and colored underlines
/// as defined in the Kitty underlines protocol.
///
/// Example usage:
///   print(KittyUnderline.curly().build()); // \x1b[4:3m
///   print(KittyUnderline.curly().withColor(255, 0, 0).build()); // red curly underline
class KittyUnderline {
  final KittyUnderlineStyle? style;
  final int? colorRed;
  final int? colorGreen;
  final int? colorBlue;
  final int? colorValue;
  final bool resetUnderlineColor;

  const KittyUnderline._({
    this.style,
    this.colorRed,
    this.colorGreen,
    this.colorBlue,
    this.colorValue,
    this.resetUnderlineColor = false,
  });

  /// Create an underline with specified style
  factory KittyUnderline.style(KittyUnderlineStyle style) {
    return KittyUnderline._(style: style);
  }

  /// No underline
  static const KittyUnderline none = KittyUnderline._(style: KittyUnderlineStyle.none);

  /// Straight underline
  static const KittyUnderline straight = KittyUnderline._(style: KittyUnderlineStyle.straight);

  /// Double underline
  static const KittyUnderline double_ = KittyUnderline._(style: KittyUnderlineStyle.double_);

  /// Curly (wavy) underline
  static const KittyUnderline curly = KittyUnderline._(style: KittyUnderlineStyle.curly);

  /// Dotted underline
  static const KittyUnderline dotted = KittyUnderline._(style: KittyUnderlineStyle.dotted);

  /// Dashed underline
  static const KittyUnderline dashed = KittyUnderline._(style: KittyUnderlineStyle.dashed);

  /// Set underline color using RGB (true color)
  KittyUnderline withColor(int r, int g, int b) {
    return KittyUnderline._(
      style: style,
      colorRed: r,
      colorGreen: g,
      colorBlue: b,
    );
  }

  /// Set underline color using 256-color mode
  KittyUnderline withColor256(int color) {
    return KittyUnderline._(
      style: style,
      colorValue: color,
    );
  }

  /// Reset underline color to default
  KittyUnderline resetColor() {
    return KittyUnderline._(
      style: style,
      resetUnderlineColor: true,
    );
  }

  /// Build the escape sequence(s)
  List<String> build() {
    final sequences = <String>[];

    // Underline style
    final s = style;
    if (s != null) {
      if (s == KittyUnderlineStyle.none) {
        sequences.add('\x1b[24m'); // Reset underline
      } else {
        sequences.add('\x1b[4:${s.value}m');
      }
    }

    // Underline color
    if (resetUnderlineColor) {
      sequences.add('\x1b[59m');
    } else if (colorRed != null && colorGreen != null && colorBlue != null) {
      // True color: CSI 58:2:r:g:bm
      sequences.add('\x1b[58:2:$colorRed:$colorGreen:${colorBlue}m');
    } else if (colorValue != null) {
      // 256 color: CSI 58:5:cm
      sequences.add('\x1b[58:5:${colorValue}m');
    }

    return sequences;
  }

  /// Build as single concatenated string
  String buildString() {
    return build().join('');
  }

  @override
  String toString() {
    return 'KittyUnderline(style: $style, rgb: $colorRed,$colorGreen,$colorBlue, 256: $colorValue)';
  }
}

/// Quick builder for common underline styles
class KittyUnderlines {
  KittyUnderlines._();

  /// No underline
  static const none = KittyUnderline.none;

  /// Straight underline
  static const straight = KittyUnderline.straight;

  /// Double underline
  static const double_ = KittyUnderline.double_;

  /// Curly (wavy) underline
  static const curly = KittyUnderline.curly;

  /// Dotted underline
  static const dotted = KittyUnderline.dotted;

  /// Dashed underline
  static const dashed = KittyUnderline.dashed;

  /// Red curly underline (common for errors)
  static final redCurly = KittyUnderline.curly.withColor(255, 0, 0);

  /// Yellow curly underline (common for warnings)
  static final yellowCurly = KittyUnderline.curly.withColor(255, 255, 0);

  /// Green curly underline (common for info)
  static final greenCurly = KittyUnderline.curly.withColor(0, 255, 0);

  /// Blue curly underline (common for hints)
  static final blueCurly = KittyUnderline.curly.withColor(0, 0, 255);
}
