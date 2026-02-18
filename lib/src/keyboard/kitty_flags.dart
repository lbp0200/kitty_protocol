/// Progressive enhancement flags for Kitty Keyboard Protocol
///
/// Reference: doc/kitty/docs/keyboard-protocol.rst lines 299-307
library kitty_protocol_keyboard_flags;

/// Flags for progressive enhancement of keyboard protocol
class KittyKeyboardEncoderFlags {
  /// Report key release events (bit 0)
  ///
  /// When enabled, key repeat and key release events are reported.
  /// Per protocol: this is flag 0b1 (1)
  final bool reportEvent;

  /// Report alternate key representations (bit 1)
  ///
  /// When enabled, reports shifted key and base layout key.
  /// Per protocol: this is flag 0b10 (2)
  final bool reportAlternateKeys;

  /// Report all keys as escape sequences (bit 2)
  ///
  /// When enabled, all keys (including printable) are sent as CSI u sequences.
  /// Per protocol: this is flag 0b100 (4)
  final bool reportAllKeysAsEscape;

  /// When enabled, defer to system for printable characters with modifiers
  /// This helps handle IME/text input conflicts
  final bool deferToSystemOnComplexInput;

  const KittyKeyboardEncoderFlags({
    this.reportEvent = false,
    this.reportAlternateKeys = false,
    this.reportAllKeysAsEscape = false,
    this.deferToSystemOnComplexInput = false,
  });

  /// Convert flags to CSI > value
  int toCSIValue() {
    int value = 0;
    if (reportEvent) value |= 1;
    if (reportAlternateKeys) value |= 2;
    if (reportAllKeysAsEscape) value |= 4;
    return value;
  }

  /// Check if extended mode is active
  bool get isExtendedMode => toCSIValue() != 0;
}
