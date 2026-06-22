/// Kitty Clipboard Encoder - Clipboard operations for Kitty Protocol
///
/// Reference: docs/kitty/docs/clipboard.rst
///
/// This implements OSC 5522 (extended clipboard protocol) and OSC 52 (basic clipboard).
library;
import 'dart:convert';

/// Clipboard location
enum KittyClipboardLocation {
  /// System clipboard (default)
  clipboard(''),
  /// Primary selection
  primary('primary');

  final String value;
  const KittyClipboardLocation(this.value);
}

/// Clipboard operation types
enum KittyClipboardAction {
  /// Read from clipboard
  read('read'),
  /// Write to clipboard
  write('write'),
  /// Write data chunk
  writeData('wdata'),
  /// Write alias
  writeAlias('walias');

  final String value;
  const KittyClipboardAction(this.value);
}

/// Status codes for clipboard operations
enum KittyClipboardStatus {
  /// Operation successful
  ok('OK'),
  /// Data follows
  data('DATA'),
  /// Operation done
  done('DONE'),
  /// Permission denied
  permissionDenied('EPERM'),
  /// Not available
  notSupported('ENOSYS'),
  /// Device busy
  busy('EBUSY'),
  /// I/O error
  ioError('EIO'),
  /// Invalid argument
  invalidArgument('EINVAL');

  final String value;
  const KittyClipboardStatus(this.value);
}

/// Common MIME types for clipboard
class KittyClipboardMimeTypes {
  static const String plainText = 'text/plain';
  static const String textUtf8 = 'text/plain;charset=utf-8';
  static const String html = 'text/html';
  static const String imagePng = 'image/png';
  static const String imageJpeg = 'image/jpeg';
  static const String imageGif = 'image/gif';
  static const String uriList = 'text/uri-list';
}

/// Clipboard Encoder for Kitty Protocol
///
/// Implements OSC 5522 for advanced clipboard operations and OSC 52 for basic operations.
///
/// Basic OSC 52 format:
///   `<OSC>52;c;<base64><ST>`
///
/// Extended OSC 5522 format:
///   `<OSC>5522;metadata;payload<ST>`
class KittyClipboardEncoder {
  /// OSC 52 code for basic clipboard
  static const int osc52Code = 52;

  /// OSC 5522 code for extended clipboard
  static const int osc5522Code = 5522;

  /// Maximum chunk size (before base64 encoding)
  static const int maxChunkSize = 4096;

  const KittyClipboardEncoder();

  // ============ OSC 52 Basic Clipboard ============

  /// Build OSC 52 sequence to read from clipboard
  ///
  /// Format: `<OSC>52;c;<base64><ST>`
  /// Note: For reading, the payload is typically empty or contains the letter 'c'
  String osc52Read({KittyClipboardLocation location = KittyClipboardLocation.clipboard}) {
    // For OSC 52, 'c' means read from clipboard
    final locationChar = location == KittyClipboardLocation.primary ? 'p' : 'c';
    return '\x1b]52;$locationChar;\x1b\\';
  }

  /// Build OSC 52 sequence to write to clipboard
  ///
  /// Format: `<OSC>52;c;<base64><ST>`
  String osc52Write(String data, {KittyClipboardLocation location = KittyClipboardLocation.clipboard}) {
    final encoded = base64Encode(utf8.encode(data));
    return '\x1b]52;$location;$encoded\x07';
  }

  // ============ OSC 5522 Extended Clipboard ============

  /// Build OSC 5522 sequence
  String _buildSequence({
    required String metadata,
    String? payload,
  }) {
    if (payload != null && payload.isNotEmpty) {
      return '\x1b]$osc5522Code;$metadata;$payload\x1b\\';
    }
    return '\x1b]$osc5522Code;$metadata\x1b\\';
  }

  /// Encode metadata key-value pairs
  String _encodeMetadata(Map<String, String> params) {
    final pairs = <String>[];
    params.forEach((key, value) {
      if (value.isNotEmpty) {
        pairs.add('$key=$value');
      }
    });
    return pairs.join(':');
  }

  // ============ Read Operations ============

  /// Start a read request
  ///
  /// Per protocol lines 24-33:
  ///   `<OSC>5522;type=read;<base64 encoded MIME types><ST>`
  String startRead({
    required List<String> mimeTypes,
    KittyClipboardLocation location = KittyClipboardLocation.clipboard,
    String? sessionId,
    String? password,
    String? name,
  }) {
    // Encode MIME types as base64
    final mimeList = mimeTypes.join(' ');
    final encodedMimes = base64Encode(utf8.encode(mimeList));

    // Special case: single period means "list available types"
    final payload = mimeTypes.length == 1 && mimeTypes[0] == '.'
        ? 'Lg=='
        : encodedMimes;

    final metadata = _encodeMetadata({
      'type': KittyClipboardAction.read.value,
      if (location != KittyClipboardLocation.clipboard) 'loc': location.value,
      if (sessionId != null) 'id': sessionId,
      if (password != null) 'pw': base64Encode(utf8.encode(password)),
      if (name != null) 'name': base64Encode(utf8.encode(name)),
    });

    return _buildSequence(metadata: metadata, payload: payload);
  }

  /// Query available MIME types (special case)
  ///
  /// Per protocol line 36: payload is just a period "."
  String queryAvailableTypes({
    KittyClipboardLocation location = KittyClipboardLocation.clipboard,
    String? sessionId,
  }) {
    // "." in base64 is "Lg=="
    final metadata = _encodeMetadata({
      'type': KittyClipboardAction.read.value,
      if (location != KittyClipboardLocation.clipboard) 'loc': location.value,
      if (sessionId != null) 'id': sessionId,
    });

    return _buildSequence(metadata: metadata, payload: 'Lg==');
  }

  // ============ Write Operations ============

  /// Start a write request
  ///
/// Per protocol lines 84-90:
///   `<OSC>5522;type=write<ST>`
  String startWrite({
    KittyClipboardLocation location = KittyClipboardLocation.clipboard,
    String? sessionId,
    String? password,
    String? name,
  }) {
    final metadata = _encodeMetadata({
      'type': KittyClipboardAction.write.value,
      if (location != KittyClipboardLocation.clipboard) 'loc': location.value,
      if (sessionId != null) 'id': sessionId,
      if (password != null) 'pw': base64Encode(utf8.encode(password)),
      if (name != null) 'name': base64Encode(utf8.encode(name)),
    });

    return _buildSequence(metadata: metadata);
  }

  /// Send a chunk of data for a specific MIME type
  ///
  /// Per protocol lines 85-86:
  ///   `<OSC>5522;type=wdata:mime=<base64 mime>;<base64 data><ST>`
  String sendDataChunk({
    required String mimeType,
    required List<int> data,
    bool isLastChunk = false,
  }) {
    final encodedMime = base64Encode(utf8.encode(mimeType));
    final encodedData = base64Encode(data);

    final metadata = _encodeMetadata({
      'type': KittyClipboardAction.writeData.value,
      'mime': encodedMime,
    });

    return _buildSequence(metadata: metadata, payload: encodedData);
  }

  /// End write operation
  ///
  /// Per protocol line 90:
  ///   `<OSC>5522;type=wdata<ST>`
  String endWrite() {
    final metadata = _encodeMetadata({
      'type': KittyClipboardAction.writeData.value,
    });

    return _buildSequence(metadata: metadata);
  }

  /// Write alias
  ///
  /// Per protocol lines 130-139:
  ///   `<OSC>5522;type=walias;mime=<base64 target>;<base64 aliases><ST>`
  String writeAlias({
    required String targetMimeType,
    required List<String> aliases,
  }) {
    final encodedTarget = base64Encode(utf8.encode(targetMimeType));
    final encodedAliases = base64Encode(utf8.encode(aliases.join(' ')));

    final metadata = _encodeMetadata({
      'type': KittyClipboardAction.writeAlias.value,
      'mime': encodedTarget,
    });

    return _buildSequence(metadata: metadata, payload: encodedAliases);
  }

  // ============ Utility Methods ============

  /// Split data into chunks
  List<List<int>> chunkData(List<int> data, {int? chunkSize}) {
    final size = chunkSize ?? maxChunkSize;
    final chunks = <List<int>>[];

    for (var i = 0; i < data.length; i += size) {
      final end = (i + size < data.length) ? i + size : data.length;
      chunks.add(data.sublist(i, end));
    }

    return chunks;
  }

  /// Write text to clipboard in chunks
  List<String> writeTextInChunks({
    required String text,
    String mimeType = KittyClipboardMimeTypes.plainText,
    KittyClipboardLocation location = KittyClipboardLocation.clipboard,
    String? sessionId,
  }) {
    final sequences = <String>[];

    // Start write
    sequences.add(startWrite(location: location, sessionId: sessionId));

    // Get bytes
    final bytes = utf8.encode(text);

    // Chunk and send
    final chunks = chunkData(bytes);

    for (var i = 0; i < chunks.length; i++) {
      final isLast = (i == chunks.length - 1);
      sequences.add(sendDataChunk(
        mimeType: mimeType,
        data: chunks[i],
        isLastChunk: isLast,
      ));
    }

    // End write
    sequences.add(endWrite());

    return sequences;
  }

  /// Parse a response from terminal
  Map<String, String> parseResponse(String response) {
    // Format: <OSC>5522;key=value:key=value<ST>
    final pattern = RegExp(r'^\x1b\]5522;(.*)\x1b\\$');
    final match = pattern.firstMatch(response);

    if (match == null) {
      return {};
    }

    final content = match.group(1) ?? '';
    final result = <String, String>{};

    final pairs = content.split(':');
    for (final pair in pairs) {
      final idx = pair.indexOf('=');
      if (idx > 0) {
        final key = pair.substring(0, idx);
        final value = pair.substring(idx + 1);
        result[key] = value;
      }
    }

    return result;
  }

  /// Check if response indicates success
  bool isSuccessResponse(Map<String, String> parsed) {
    final status = parsed['status'] ?? '';
    return status == 'OK' || status == 'DONE' || status == 'DATA';
  }

  /// Get status from response
  String getStatus(Map<String, String> parsed) {
    return parsed['status'] ?? '';
  }
}
