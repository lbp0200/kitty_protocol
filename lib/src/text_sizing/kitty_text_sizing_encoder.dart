/// Kitty Text Sizing Encoder - Encodes text sizing commands for Kitty Text Sizing Protocol
///
/// Reference: doc/kitty/docs/text-sizing-protocol.rst
library kitty_protocol_text_sizing_encoder;

/// Text sizing scale (1-7)
class KittyTextScale {
  /// Scale factor 1 (default)
  static const int scale1 = 1;
  /// Scale factor 2 (double size)
  static const int scale2 = 2;
  /// Scale factor 3 (triple size)
  static const int scale3 = 3;
  /// Scale factor 4 (quadruple size)
  static const int scale4 = 4;
  /// Scale factor 5
  static const int scale5 = 5;
  /// Scale factor 6
  static const int scale6 = 6;
  /// Scale factor 7
  static const int scale7 = 7;
}

/// Vertical alignment for fractional scaling
enum KittyVerticalAlignment {
  /// Top alignment (default)
  top(0),
  /// Bottom alignment
  bottom(1),
  /// Centered alignment
  centered(2);

  final int value;
  const KittyVerticalAlignment(this.value);
}

/// Horizontal alignment for fractional scaling
enum KittyHorizontalAlignment {
  /// Left alignment (default)
  left(0),
  /// Right alignment
  right(1),
  /// Centered alignment
  centered(2);

  final int value;
  const KittyHorizontalAlignment(this.value);
}

/// Text sizing encoder for Kitty Protocol
///
/// Reference: doc/kitty/docs/text-sizing-protocol.rst
///
/// The text sizing protocol allows text to be displayed in different sizes
/// in the terminal. It uses OSC escape codes.
///
/// Escape code format:
///   <OSC> _text_size_code ; metadata ; text <terminator>
///
/// OSC = ESC ] (0x1b 0x5d)
/// Terminator = BEL (0x07) or ESC ST (0x1b 0x5c)
///
/// Example:
///   printf "\e]_text_size_code;s=2;Double sized text\a\n"
class KittyTextSizingEncoder {
  /// Text size code identifier
  static const String textSizeCode = '_text_size_code';

  /// BEL terminator
  static const String belTerminator = '\x07';

  /// ESC ST terminator
  static const String stTerminator = '\x1b\\';

  /// Maximum text length
  static const int maxTextLength = 4096;

  const KittyTextSizingEncoder();

  /// Build a text sizing escape sequence
  ///
  /// Format: <OSC> _text_size_code ; metadata ; text <terminator>
  /// Example: \x1b]_text_size_code;s=2;Double sized text\x07
  String encode({
    required String text,
    int? scale,
    int? width,
    int? numerator,
    int? denominator,
    KittyVerticalAlignment? verticalAlignment,
    KittyHorizontalAlignment? horizontalAlignment,
    bool useBelTerminator = true,
  }) {
    final metadata = _buildMetadata(
      scale: scale,
      width: width,
      numerator: numerator,
      denominator: denominator,
      verticalAlignment: verticalAlignment,
      horizontalAlignment: horizontalAlignment,
    );

    final terminator = useBelTerminator ? belTerminator : stTerminator;

    return '\x1b]$textSizeCode;$metadata;$text$terminator';
  }

  /// Build metadata string from parameters
  String _buildMetadata({
    int? scale,
    int? width,
    int? numerator,
    int? denominator,
    KittyVerticalAlignment? verticalAlignment,
    KittyHorizontalAlignment? horizontalAlignment,
  }) {
    final parts = <String>[];

    if (scale != null && scale >= 1 && scale <= 7) {
      parts.add('s=$scale');
    }
    if (width != null && width >= 0 && width <= 7) {
      parts.add('w=$width');
    }
    if (numerator != null && numerator >= 0 && numerator <= 15) {
      parts.add('n=$numerator');
    }
    if (denominator != null && denominator > (numerator ?? 0) && denominator <= 15) {
      parts.add('d=$denominator');
    }
    if (verticalAlignment != null) {
      parts.add('v=${verticalAlignment.value}');
    }
    if (horizontalAlignment != null) {
      parts.add('h=${horizontalAlignment.value}');
    }

    return parts.join(':');
  }

  /// Create double-sized text
  ///
  /// Example: "Double sized text"
  String encodeDoubleSize(String text) {
    return encode(text: text, scale: 2);
  }

  /// Create triple-sized text
  String encodeTripleSize(String text) {
    return encode(text: text, scale: 3);
  }

  /// Create half-sized text (half height, one cell width)
  String encodeHalfSize(String text) {
    return encode(text: text, numerator: 1, denominator: 2);
  }

  /// Create superscript text
  String encodeSuperscript(String text) {
    return encode(text: text, numerator: 1, denominator: 2, verticalAlignment: KittyVerticalAlignment.bottom);
  }

  /// Create subscript text
  String encodeSubscript(String text) {
    return encode(text: text, numerator: 1, denominator: 2, verticalAlignment: KittyVerticalAlignment.top);
  }

  /// Create text with explicit width (fixes character width issues)
  ///
  /// This is useful for ensuring the terminal renders text in the exact
  /// number of cells the client expects.
  String encodeWithWidth(String text, int widthInCells) {
    return encode(text: text, width: widthInCells);
  }

  /// Split text into chunks that fit in specified width
  ///
  /// Per protocol: when using non-zero w, all text must fit in s*w cells.
  /// This helper splits text appropriately.
  List<String> chunkByWidth(String text, int widthInCells) {
    // Simple implementation - splits by words for demonstration
    // A full implementation would use Unicode grapheme segmentation
    final words = text.split(' ');
    final chunks = <String>[];
    var currentChunk = StringBuffer();
    var currentWidth = 0;

    for (final word in words) {
      final wordWidth = _estimateWidth(word);
      if (currentWidth + wordWidth + (currentWidth > 0 ? 1 : 0) <= widthInCells) {
        if (currentWidth > 0) {
          currentChunk.write(' ');
          currentWidth++;
        }
        currentChunk.write(word);
        currentWidth += wordWidth;
      } else {
        if (currentChunk.isNotEmpty) {
          chunks.add(currentChunk.toString());
        }
        currentChunk = StringBuffer(word);
        currentWidth = wordWidth;
      }
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk.toString());
    }

    return chunks;
  }

  /// Estimate width of text (simplified)
  int _estimateWidth(String text) {
    // Simplified - assumes ASCII characters are width 1
    // A full implementation would use Unicode width algorithm
    return text.length;
  }
}
