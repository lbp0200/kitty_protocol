/// Kitty Misc Protocol Extensions - Additional escape sequences
///
/// Reference: doc/kitty/docs/misc-protocol.rst
///
/// Contains:
/// - Screen to scrollback (\x1b[22J)
/// - Independent bold/faint reset (SGR 221/222)
/// - Focus reporting (SGR 1004)
library kitty_protocol_misc;

/// SGR (Select Graphic Rendition) codes for text styling
class KittySgrCodes {
  KittySgrCodes._();

  // ============ Basic SGR Codes ============

  /// Reset all attributes
  static const int reset = 0;

  /// Bold (increased intensity)
  static const int bold = 1;

  /// Faint (decreased intensity)
  static const int faint = 2;

  /// Italic
  static const int italic = 3;

  /// Underline
  static const int underline = 4;

  /// Blink (slow)
  static const int blink = 5;

  /// Reverse video
  static const int reverse = 7;

  /// Hidden (conceal)
  static const int hidden = 8;

  /// Strikethrough
  static const int strikethrough = 9;

  // ============ Kitty Extensions ============

  /// Reset bold only (independent of faint)
  /// Per misc-protocol.rst line 29-30
  static const int resetBold = 221;

  /// Reset faint only (independent of bold)
  /// Per misc-protocol.rst line 29-30
  static const int resetFaint = 222;

  // ============ Color SGR Codes ============

  /// Set foreground color (256 colors)
  static const int foreground256 = 38;

  /// Set background color (256 colors)
  static const int background256 = 48;

  /// Set foreground color (24-bit)
  static const int foreground24 = 38;

  /// Set background color (24-bit)
  static const int background24 = 48;
}

/// Screen control escape sequences
class KittyScreenControl {
  KittyScreenControl._();

  /// Move screen contents to scrollback
  ///
  /// Per misc-protocol.rst line 47-52:
  ///   \x1b[22J
  ///
  /// This moves all screen contents (text and images) into the scrollback
  /// leaving the screen in the same state as a standard clear.
  static String moveScreenToScrollback() {
    return '\x1b[22J';
  }

  /// Clear screen (standard)
  static String clearScreen() {
    return '\x1b[2J';
  }

  /// Clear from cursor to end of screen
  static String clearToEnd() {
    return '\x1b[0J';
  }

  /// Clear from cursor to beginning of screen
  static String clearToStart() {
    return '\x1b[1J';
  }
}

/// Focus reporting (Mouse tracking)
///
/// Per misc-protocol.rst line 32-44
class KittyFocusReporting {
  KittyFocusReporting._();

  /// Enable focus reporting
  ///
  /// SGR 1004 enables the terminal to report focus in/out events
  static String enable() {
    return '\x1b[?1004h';
  }

  /// Disable focus reporting
  static String disable() {
    return '\x1b[?1004l';
  }

  /// Focus in event (received from terminal)
  static String get focusIn => '\x1b[I';

  /// Focus out event (received from terminal)
  static String get focusOut => '\x1b[O';
}

/// Text styling helper with Kitty extensions
class KittyTextStyle {
  KittyTextStyle._();

  /// Reset bold only (keep other attributes)
  static String get resetBold => '\x1b[${ KittySgrCodes.resetBold }m';

  /// Reset faint only (keep other attributes)
  static String get resetFaint => '\x1b[${ KittySgrCodes.resetFaint }m';

  /// Reset all text styling
  static String get reset => '\x1b[${ KittySgrCodes.reset }m';

  /// Bold text
  static String get bold => '\x1b[${ KittySgrCodes.bold }m';

  /// Faint text
  static String get faint => '\x1b[${ KittySgrCodes.faint }m';

  /// Bold + Faint (normal intensity - reset both)
  static String get normalIntensity => '\x1b[${ KittySgrCodes.resetBold }m\x1b[${ KittySgrCodes.resetFaint }m';
}

/// SGR Mouse Tracking (1006)
///
/// Per xterm documentation - Extended Mouse Tracking
class KittyMouseTracking {
  KittyMouseTracking._();

  /// Enable SGR Mouse Tracking (1006)
  static String enable() {
    return '\x1b[?1006h';
  }

  /// Disable SGR Mouse Tracking
  static String disable() {
    return '\x1b[?1006l';
  }

  /// Enable URXVT Mouse Tracking (1015)
  static String enableUrxvt() {
    return '\x1b[?1015h';
  }

  /// Disable URXVT Mouse Tracking
  static String disableUrxvt() {
    return '\x1b[?1015l';
  }

  /// Enable basic Mouse Tracking (1000)
  static String enableBasic() {
    return '\x1b[?1000h';
  }

  /// Disable basic Mouse Tracking
  static String disableBasic() {
    return '\x1b[?1000l';
  }

  /// Enable mouse events on button press (1002)
  static String enableButtonEvents() {
    return '\x1b[?1002h';
  }

  /// Disable button events
  static String disableButtonEvents() {
    return '\x1b[?1002l';
  }

  /// Enable all mouse events (1003)
  static String enableAllEvents() {
    return '\x1b[?1003h';
  }

  /// Disable all events
  static String disableAllEvents() {
    return '\x1b[?1003l';
  }
}

/// Bracketed Paste Mode (2004)
///
/// Per xterm documentation - allows applications to distinguish
/// pasted text from typed text
class KittyBracketedPaste {
  KittyBracketedPaste._();

  /// Enable Bracketed Paste Mode
  ///
  /// Pasted text will be wrapped with:
  /// - Start: \x1b[200~
  /// - End: \x1b[201~
  static String enable() {
    return '\x1b[?2004h';
  }

  /// Disable Bracketed Paste Mode
  static String disable() {
    return '\x1b[?2004l';
  }

  /// Start paste marker (received from terminal)
  static String get pasteStart => '\x1b[200~';

  /// End paste marker (received from terminal)
  static String get pasteEnd => '\x1b[201~';
}

/// DEC Private Modes for Cursor and Screen
class KittyDecModes {
  KittyDecModes._();

  /// Save cursor position (DECSC)
  ///
  /// Per VT510 manual - Saves cursor position, attributes, and character set
  static String saveCursor() {
    return '\x1b7'; // DECSC
  }

  /// Restore cursor position (DECRC)
  ///
  /// Per VT510 manual - Restores cursor position, attributes, and character set
  static String restoreCursor() {
    return '\x1b8'; // DECRC
  }

  /// Alternative: CSI s (ANSI Save Cursor)
  static String ansiSaveCursor() {
    return '\x1b[s';
  }

  /// Alternative: ANSI Restore Cursor
  static String ansiRestoreCursor() {
    return '\x1b[u';
  }

  /// Hide cursor
  static String hideCursor() {
    return '\x1b[?25l';
  }

  /// Show cursor
  static String showCursor() {
    return '\x1b[?25h';
  }

  /// Enable origin mode (DECOM)
  static String enableOriginMode() {
    return '\x1b[?6h';
  }

  /// Disable origin mode
  static String disableOriginMode() {
    return '\x1b[?6l';
  }
}
