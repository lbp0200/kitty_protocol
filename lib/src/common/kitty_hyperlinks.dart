/// Kitty Hyperlinks - OSC 8 hyperlinks for Kitty Protocol
///
/// Reference: doc/kitty/docs/integrations.rst (OSC 8)
///
/// Format:
///   \x1b]8;;URL\x1b\Display Text\x1b]8;;\x1b\
library kitty_protocol_hyperlinks;

/// Hyperlink encoder
///
/// Per OSC 8 protocol:
///
///   \x1b]8;;http://example.com\x1b\Link Text\x1b]8;;\x1b\
class KittyHyperlinks {
  KittyHyperlinks._();

  /// OSC 8 code
  static const int oscCode = 8;

  /// Create a hyperlink
  ///
  /// Format: \x1b]8;;URL\x1b\Text\x1b]8;;\x1b\
  static String link({
    required String url,
    required String text,
  }) {
    return '\x1b]8;;$url\x1b\\$text\x1b]8;;\x1b\\';
  }

  /// Create a hyperlink with custom ID
  ///
  /// Format: \x1b]8;id;URL\x1b\Text\x1b]8;;\x1b\
  static String linkWithId({
    required String id,
    required String url,
    required String text,
  }) {
    return '\x1b]8;$id;$url\x1b\\$text\x1b]8;;\x1b\\';
  }

  /// End hyperlink (reset to no link)
  static String end() {
    return '\x1b]8;;\x1b\\';
  }

  /// Quick link helpers
  static String linkTo(String url) => link(url: url, text: url);
}
