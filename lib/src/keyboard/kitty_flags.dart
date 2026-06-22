/// Progressive enhancement flags for Kitty Keyboard Protocol
///
/// Reference: docs/kitty/docs/keyboard-protocol.rst lines 299-307
/// Flags for progressive enhancement of keyboard protocol
class KittyKeyboardEncoderFlags {
  /// Disambiguate keys (bit 0)
  ///
  /// When set, the terminal sends escape codes even for keys
  /// that also produce text output.
  final bool disambiguate;

  /// Report key events (bit 1)
  ///
  /// When set, the terminal reports key repeat and key release events.
  final bool reportEvents;

  /// Report alternate key representations (bit 2)
  ///
  /// When set, the terminal reports shifted and base layout key
  /// representations in addition to the actual key.
  final bool reportAlternates;

  /// Report all keys as escape sequences (bit 3)
  ///
  /// When set, ALL keys (including printable) are sent as CSI u sequences.
  final bool reportAllKeys;

  /// Report text (bit 4)
  ///
  /// When set, the terminal also reports the text associated with keys.
  final bool reportText;

  /// Flutter-specific: defer to system for printable characters with modifiers
  ///
  /// This is a **Flutter-specific extension** not part of the Kitty protocol spec.
  /// It helps handle IME/text input conflicts by returning an empty string for
  /// printable characters with modifier keys (e.g., Ctrl+A, Alt+E), allowing
  /// Flutter's text input system to handle them normally.
  final bool deferToSystemOnComplexInput;

  const KittyKeyboardEncoderFlags({
    this.disambiguate = false,
    this.reportEvents = false,
    this.reportAlternates = false,
    this.reportAllKeys = false,
    this.reportText = false,
    this.deferToSystemOnComplexInput = false,
  });

  /// Convert flags to the protocol bitmask value
  int toCSIValue() {
    int value = 0;
    if (disambiguate) value |= 1;
    if (reportEvents) value |= 2;
    if (reportAlternates) value |= 4;
    if (reportAllKeys) value |= 8;
    if (reportText) value |= 16;
    return value;
  }

  /// Check if extended mode is active (any protocol flag set)
  bool get isExtendedMode => toCSIValue() != 0;

  /// Generate a query sequence: `\x1b[?u`
  ///
  /// Asks the terminal to report its current progressive enhancement flags.
  /// The terminal should respond with `\x1b[?flags...u`.
  String toQuerySequence() {
    return '\x1b[?u';
  }

  /// Generate a set sequence: `\x1b[=flags;modeu`
  ///
  /// Sends the current flags to the terminal with the specified [mode]:
  /// - `1`: Set/reset flags as specified
  /// - `2`: Only set flags (never reset)
  /// - `3`: Only reset flags (never set)
  String toSetSequence({int mode = 1}) {
    return '\x1b[=${toCSIValue()};${mode}u';
  }

  /// Generate a push sequence: `\x1b[>flagsu`
  ///
  /// Pushes the current flags onto the terminal's flag stack.
  String toPushSequence() {
    return '\x1b[>${toCSIValue()}u';
  }

  /// Generate a pop sequence: `\x1b[<countu`
  ///
  /// Pops [count] entries from the terminal's flag stack (default: 1).
  static String toPopSequence({int count = 1}) {
    return '\x1b[<$count u';
  }
}
