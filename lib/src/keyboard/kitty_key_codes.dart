/// Key codes for Kitty Keyboard Protocol
///
/// Reference: doc/kitty/docs/keyboard-protocol.rst lines 585-668
library kitty_protocol_keyboard_key_codes;

import 'package:flutter/services.dart';

/// Key codes per Kitty Keyboard Protocol spec
///
/// References:
/// - Functional key definitions: doc/kitty/docs/keyboard-protocol.rst lines 585-668
/// - C0 control code mapping: doc/kitty/docs/keyboard-protocol.rst lines 684-706
///
/// Encoding format (line 98):
///   CSI <unicode-key-code> ; <modifiers> u
///
/// Modifier encoding (lines 192-208):
///   modifier = 1 + bit_flags (Shift=1, Alt=2, Ctrl=4, Super=8, Hyper=16, Meta=32)
///
/// Important notes from protocol:
/// - Line 150: The unicode-key-code is the Unicode codepoint representing the key
/// - Line 155: The codepoint used is ALWAYS the lower-case (un-shifted) version
/// - Lines 684-706: Ctrl mapping to C0 control codes for legacy compatibility
class KittyKeyCodes {
  // Function keys
  static const int f1 = 11;
  static const int f2 = 12;
  static const int f3 = 13;
  static const int f4 = 14;
  static const int f5 = 15;
  static const int f6 = 17;
  static const int f7 = 18;
  static const int f8 = 19;
  static const int f9 = 20;
  static const int f10 = 21;
  static const int f11 = 23;
  static const int f12 = 24;

  // Navigation keys
  static const int arrowUp = 30;
  static const int arrowDown = 31;
  static const int arrowRight = 32;
  static const int arrowLeft = 33;
  static const int pageDown = 34;
  static const int pageUp = 35;
  static const int home = 36;
  static const int end = 37;
  static const int insert = 38;

  // Special keys - Unicode codepoints per Kitty Keyboard Protocol
  static const int enter = 13;
  static const int backspace = 127;
  static const int tab = 9;
  static const int escape = 27;
  static const int space = 32;
  static const int delete = 127;

  // Action keys
  static const int pause = 43;
  static const int printScreen = 45;

  /// Map Flutter LogicalKeyboardKey to Kitty key code
  static int? getKeyCode(LogicalKeyboardKey key) {
    return _keyMap[key];
  }

  static final Map<LogicalKeyboardKey, int> _keyMap = {
    LogicalKeyboardKey.f1: f1,
    LogicalKeyboardKey.f2: f2,
    LogicalKeyboardKey.f3: f3,
    LogicalKeyboardKey.f4: f4,
    LogicalKeyboardKey.f5: f5,
    LogicalKeyboardKey.f6: f6,
    LogicalKeyboardKey.f7: f7,
    LogicalKeyboardKey.f8: f8,
    LogicalKeyboardKey.f9: f9,
    LogicalKeyboardKey.f10: f10,
    LogicalKeyboardKey.f11: f11,
    LogicalKeyboardKey.f12: f12,
    LogicalKeyboardKey.arrowUp: arrowUp,
    LogicalKeyboardKey.arrowDown: arrowDown,
    LogicalKeyboardKey.arrowRight: arrowRight,
    LogicalKeyboardKey.arrowLeft: arrowLeft,
    LogicalKeyboardKey.pageDown: pageDown,
    LogicalKeyboardKey.pageUp: pageUp,
    LogicalKeyboardKey.home: home,
    LogicalKeyboardKey.end: end,
    LogicalKeyboardKey.insert: insert,
    LogicalKeyboardKey.enter: enter,
    LogicalKeyboardKey.backspace: backspace,
    LogicalKeyboardKey.tab: tab,
    LogicalKeyboardKey.escape: escape,
    LogicalKeyboardKey.space: space,
    LogicalKeyboardKey.delete: delete,
    LogicalKeyboardKey.pause: pause,
    LogicalKeyboardKey.printScreen: printScreen,
  };

  /// C0 control code mapping for Ctrl+key combinations
  ///
  /// Per Kitty Keyboard Protocol (lines 684-706):
  /// When Ctrl is held, some keys map to C0 control codes (0-31).
  /// Keys not in this table remain unchanged.
  ///
  /// Examples:
  /// - Ctrl+a through Ctrl+z map to 1-26
  /// - Ctrl+space = 0, Ctrl+? = 127
  static final Map<int, int> _ctrlToC0Mapping = {
    // Space and punctuation (line 688)
    32: 0,   // Ctrl+Space -> NUL (0)
    47: 31,  // Ctrl+/ -> US (31)
    48: 48,  // Ctrl+0 -> '0' (no mapping, stays 48)
    // Numbers (lines 689-691)
    49: 49,  // Ctrl+1 -> '1' (no mapping)
    50: 0,   // Ctrl+2 -> NUL (0) - same as Ctrl+@
    51: 27,  // Ctrl+3 -> ESC (27)
    52: 28,  // Ctrl+4 -> FS (28)
    53: 29,  // Ctrl+5 -> GS (29)
    54: 30,  // Ctrl+6 -> RS (30)
    55: 31,  // Ctrl+7 -> US (31)
    56: 127, // Ctrl+8 -> DEL (127)
    57: 57,  // Ctrl+9 -> '9' (no mapping)
    // Punctuation (lines 692-694)
    63: 127, // Ctrl+? -> DEL (127)
    64: 0,   // Ctrl+@ -> NUL (0)
    91: 27,  // Ctrl+[ -> ESC (27)
    92: 28,  // Ctrl+\ -> FS (28)
    93: 29,  // Ctrl+] -> GS (29)
    94: 30,  // Ctrl+^ -> RS (30)
    95: 31,  // Ctrl+_ -> US (31)
    // Lowercase letters (lines 695-702)
    97: 1,   // Ctrl+a -> SOH (1)
    98: 2,   // Ctrl+b -> STX (2)
    99: 3,   // Ctrl+c -> ETX (3)
    100: 4,  // Ctrl+d -> EOT (4)
    101: 5,  // Ctrl+e -> ENQ (5)
    102: 6,  // Ctrl+f -> ACK (6)
    103: 7,  // Ctrl+g -> BEL (7)
    104: 8,  // Ctrl+h -> BS (8)
    105: 9,  // Ctrl+i -> HT (9)
    106: 10, // Ctrl+j -> LF (10)
    107: 11, // Ctrl+k -> VT (11)
    108: 12, // Ctrl+l -> FF (12)
    109: 13, // Ctrl+m -> CR (13)
    110: 14, // Ctrl+n -> SO (14)
    111: 15, // Ctrl+o -> SI (15)
    112: 16, // Ctrl+p -> DLE (16)
    113: 17, // Ctrl+q -> DC1 (17)
    114: 18, // Ctrl+r -> DC2 (18)
    115: 19, // Ctrl+s -> DC3 (19)
    116: 20, // Ctrl+t -> DC4 (20)
    117: 21, // Ctrl+u -> NAK (21)
    118: 22, // Ctrl+v -> SYN (22)
    119: 23, // Ctrl+w -> ETB (23)
    120: 24, // Ctrl+x -> CAN (24)
    121: 25, // Ctrl+y -> EM (25)
    122: 26, // Ctrl+z -> SUB (26)
    // Tilde (line 703)
    126: 30, // Ctrl+~ -> RS (30)
  };

  /// Apply C0 control code mapping for Ctrl modifier
  ///
  /// Per protocol line 154-155:
  /// "If the user presses, for example, ctrl+shift+a the escape code
  /// would be CSI 97;modifiers u. It must not be CSI 65; modifiers u."
  ///
  /// Important: When Shift is also pressed with Ctrl, we should NOT apply
  /// C0 mapping - use the base key codepoint instead (line 155).
  ///
  /// [keyCode] - the base Unicode codepoint
  /// [hasCtrl] - whether Ctrl modifier is active
  /// [hasShift] - whether Shift modifier is active (if true, skip C0 mapping)
  ///
  /// Returns the mapped codepoint for encoding
  static int applyCtrlMapping(int keyCode, bool hasCtrl, bool hasShift) {
    // If Ctrl is not pressed, return keyCode as-is
    if (!hasCtrl) return keyCode;

    // Per protocol: If Shift is also pressed, don't apply C0 mapping
    // Use the base (un-shifted) codepoint instead
    if (hasShift) return keyCode;

    // Apply C0 mapping if available
    return _ctrlToC0Mapping[keyCode] ?? keyCode;
  }
}
