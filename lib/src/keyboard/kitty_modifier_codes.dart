/// Modifier codes for Kitty Keyboard Protocol
///
/// Reference: doc/kitty/docs/keyboard-protocol.rst lines 192-208
library kitty_protocol_keyboard_modifier_codes;

/// Modifier bit flags
class KittyModifierCodes {
  /// Shift modifier bit
  static const int shift = 1;

  /// Alt modifier bit
  static const int alt = 2;

  /// Ctrl modifier bit
  static const int ctrl = 4;

  /// Super (Windows/Command) modifier bit
  static const int superKey = 8;

  /// Hyper modifier bit
  static const int hyper = 16;

  /// Meta modifier bit
  static const int meta = 32;

  /// Caps lock modifier bit
  static const int capsLock = 64;

  /// Num lock modifier bit
  static const int numLock = 128;

  /// Calculate the modifier value for escape sequence
  ///
  /// Per protocol: modifier = 1 + bit_flags
  /// So Shift=2, Ctrl=5, Ctrl+Shift=6, etc.
  static int calculateModifiers(int modifierFlags) {
    return 1 + modifierFlags;
  }
}
