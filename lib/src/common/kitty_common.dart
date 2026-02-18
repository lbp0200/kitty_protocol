/// Kitty Protocol Common - Shared constants and utilities
///
/// Contains common escape sequence constants used across all Kitty protocol modules.
///
/// Reference:
/// - keyboard-protocol.rst (CSI sequences)
/// - graphics-protocol.rst (APC sequences)
/// - text-sizing-protocol.rst (OSC sequences)
library kitty_protocol_common;

/// Escape sequence constants
///
/// Kitty Protocol uses three main escape sequence types:
/// - CSI (Control Sequence Introducer): Keyboard protocol
/// - APC (Application Programming Command): Graphics protocol
/// - OSC (Operating System Command): Text sizing, clipboard, etc.
class KittyProtocolConstants {
  /// ESC character (0x1b)
  static const int esc = 0x1b;

  /// BEL character (0x07) - String terminator
  static const int bel = 0x07;

  // ============ CSI Sequences (Keyboard Protocol) ============

  /// CSI (Control Sequence Introducer) - ESC [
  /// Used by: Keyboard Protocol
  /// Format: ESC [ params key-code ; modifiers u
  static const String csi = '\x1b[';

  /// CSI with private marker >
  /// Used by: Keyboard Protocol extended mode
  /// Format: ESC [ > flags ; ... u
  static const String csiPrivate = '\x1b[>';

  // ============ APC Sequences (Graphics Protocol) ============

  /// APC (Application Programming Command) - ESC _
  /// Used by: Graphics Protocol
  /// Format: ESC _ control_data ; payload ESC \
  static const String apc = '\x1b_G';

  /// APC end marker - ESC \
  static const String apcEnd = '\x1b\\';

  // ============ OSC Sequences (Text Sizing, Clipboard, etc.) ============

  /// OSC (Operating System Command) - ESC ]
  /// Used by: Text Sizing Protocol, Clipboard, Notifications
  /// Format: OSC number ; parameters ST
  static const String osc = '\x1b]';

  /// ST (String Terminator) - ESC \
  static const String st = '\x1b\\';

  // ============ Common Constants ============

  /// Chunk size for base64 encoded data (per protocol spec)
  static const int chunkSize = 4096;

  /// Maximum chunk size must be multiple of 4 for base64
  static const int maxChunkSize = 4096;

  /// Maximum text length for text sizing protocol
  static const int maxTextLength = 4096;
}

/// Base class for Kitty protocol encoders
///
/// Provides common functionality for building escape sequences.
abstract class KittyEncoderBase {
  /// Build the final escape sequence
  String buildSequence(String controlData, String payload) {
    return '${KittyProtocolConstants.apc}$controlData;$payload${KittyProtocolConstants.apcEnd}';
  }

  /// Build a simple key=value pair for control data
  String buildKeyValue(String key, dynamic value) {
    if (value == null || value == 0 || value == false) {
      return '';
    }
    return '$key=$value';
  }

  /// Build comma-separated control data from key=value pairs
  String buildControlData(Map<String, dynamic> params) {
    final pairs = <String>[];
    params.forEach((key, value) {
      final pair = buildKeyValue(key, value);
      if (pair.isNotEmpty) {
        pairs.add(pair);
      }
    });
    return pairs.join(',');
  }
}
