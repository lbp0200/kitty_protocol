/// Kitty File Transfer Encoder - Encodes file transfer commands for Kitty File Transfer Protocol
///
/// Reference: doc/kitty/docs/file-transfer-protocol.rst
library kitty_protocol_file_transfer_encoder;

import 'dart:convert';

/// File transfer action types
enum KittyFileTransferAction {
  /// Send files to terminal
  send('send'),
  /// Receive files from terminal
  receive('receive'),
  /// File metadata
  file('file'),
  /// File data chunk
  data('data'),
  /// End of file data
  endData('end_data'),
  /// Cancel transfer
  cancel('cancel'),
  /// Status response
  status('status'),
  /// Finish session
  finish('finish');

  final String value;
  const KittyFileTransferAction(this.value);
}

/// File types
enum KittyFileType {
  /// Regular file
  regular('regular'),
  /// Directory
  directory('directory'),
  /// Symbolic link
  symlink('symlink'),
  /// Hard link
  link('link');

  final String value;
  const KittyFileType(this.value);
}

/// Transmission types
enum KittyTransmissionType {
  /// Simple transmission
  simple('simple'),
  /// Rsync delta transmission
  rsync('rsync');

  final String value;
  const KittyTransmissionType(this.value);
}

/// Compression types
enum KittyFileCompression {
  /// No compression
  none('none'),
  /// ZLIB compression
  zlib('zlib');

  final String value;
  const KittyFileCompression(this.value);
}

/// Response quiet levels
enum KittyQuietLevel {
  /// Verbose - all responses
  verbose(0),
  /// Only errors
  errors(1),
  /// Totally silent
  silent(2);

  final int value;
  const KittyQuietLevel(this.value);
}

/// File Transfer Encoder for Kitty Protocol
///
/// This encoder builds escape sequences for file transfer operations.
/// It is data-agnostic and only handles protocol serialization.
///
/// Escape code format (per protocol line 543-545):
///   <OSC> 5113 ; key=value ; key=value ... <ST>
///
/// OSC = ESC ] (0x1b 0x5d)
/// ST = ESC \ (0x1b 0x5c)
///
/// Example:
///   <OSC> 5113 ; ac=send ; id=session123 <ST>
class KittyFileTransferEncoder {
  /// OSC number for file transfer protocol
  static const int fileTransferCode = 5113;

  /// Maximum chunk size per protocol spec
  static const int maxChunkSize = 4096;

  const KittyFileTransferEncoder();

  /// Build an escape sequence for file transfer
  ///
  /// Format: <OSC> 5113 ; key=value ; key=value ... <ST>
  String _buildSequence(Map<String, String> params) {
    final pairs = <String>[];
    params.forEach((key, value) {
      if (value.isNotEmpty) {
        pairs.add('$key=$value');
      }
    });

    final payload = pairs.join(' ; ');
    return '\x1b]$fileTransferCode;$payload\x1b\\';
  }

  /// Encode a string as base64
  String _encodeBase64String(String input) {
    return base64Encode(utf8.encode(input));
  }

  /// Encode bytes as base64
  String _encodeBase64Bytes(List<int> data) {
    return base64Encode(data);
  }

  // ============ Session Commands ============

  /// Start a send session (client → terminal)
  ///
  /// Per protocol lines 41-56:
  ///   → action=send id=someid
  String startSendSession({
    required String sessionId,
    KittyQuietLevel quiet = KittyQuietLevel.verbose,
    String? bypassHash,
  }) {
    return _buildSequence({
      'ac': KittyFileTransferAction.send.value,
      'id': sessionId,
      if (quiet != KittyQuietLevel.verbose) 'q': quiet.value.toString(),
      if (bypassHash != null) 'pw': bypassHash,
    });
  }

  /// Start a receive session (client → terminal)
  ///
  /// Per protocol lines 117-133:
  ///   → action=receive id=someid size=num_of_paths
  String startReceiveSession({
    required String sessionId,
    required int pathCount,
    KittyQuietLevel quiet = KittyQuietLevel.verbose,
    String? bypassHash,
  }) {
    return _buildSequence({
      'ac': KittyFileTransferAction.receive.value,
      'id': sessionId,
      'sz': pathCount.toString(),
      if (quiet != KittyQuietLevel.verbose) 'q': quiet.value.toString(),
      if (bypassHash != null) 'pw': bypassHash,
    });
  }

  /// Cancel a transfer session
  ///
  /// Per protocol lines 198-210:
  ///   → action=cancel id=someid
  String cancelSession(String sessionId) {
    return _buildSequence({
      'ac': KittyFileTransferAction.cancel.value,
      'id': sessionId,
    });
  }

  /// Finish a transfer session
  ///
  /// Per protocol lines 102-111:
  ///   → action=finish id=someid
  String finishSession(String sessionId) {
    return _buildSequence({
      'ac': KittyFileTransferAction.finish.value,
      'id': sessionId,
    });
  }

  // ============ File Commands ============

  /// Send file metadata (client → terminal)
  ///
  /// Per protocol lines 58-75:
  ///   → action=file id=someid file_id=f1 name=/path/to/destination
  String sendFileMetadata({
    required String sessionId,
    required String fileId,
    required String destinationPath,
    KittyFileType fileType = KittyFileType.regular,
    int? modificationTime,
    int? permissions,
    KittyTransmissionType transmissionType = KittyTransmissionType.simple,
    KittyFileCompression compression = KittyFileCompression.none,
  }) {
    return _buildSequence({
      'ac': KittyFileTransferAction.file.value,
      'id': sessionId,
      'fid': fileId,
      'n': _encodeBase64String(destinationPath),
      if (fileType != KittyFileType.regular) 'ft': fileType.value,
      if (modificationTime != null) 'mod': modificationTime.toString(),
      if (permissions != null) 'prm': permissions.toString(),
      if (transmissionType != KittyTransmissionType.simple) 'tt': transmissionType.value,
      if (compression != KittyFileCompression.none) 'zip': compression.value,
    });
  }

  /// Request file from terminal (client → terminal)
  ///
  /// Per protocol lines 168-178:
  ///   → action=file id=someid file_id=f1 name=/some/path
  String requestFile({
    required String sessionId,
    required String fileId,
    required String filePath,
    KittyTransmissionType transmissionType = KittyTransmissionType.simple,
    KittyFileCompression compression = KittyFileCompression.none,
  }) {
    return _buildSequence({
      'ac': KittyFileTransferAction.file.value,
      'id': sessionId,
      'fid': fileId,
      'n': _encodeBase64String(filePath),
      if (transmissionType != KittyTransmissionType.simple) 'tt': transmissionType.value,
      if (compression != KittyFileCompression.none) 'zip': compression.value,
    });
  }

  // ============ Data Commands ============

  /// Send file data chunk
  ///
  /// Per protocol lines 76-85:
  ///   → action=data id=someid file_id=f1 data=chunk of bytes
  ///
  /// [isLastChunk] should be false for all chunks except the last one.
  /// Non-last chunks will include m=1 flag.
  String sendDataChunk({
    required String sessionId,
    required String fileId,
    required List<int> data,
    bool isLastChunk = false,
  }) {
    return _buildSequence({
      'ac': (isLastChunk ? KittyFileTransferAction.endData : KittyFileTransferAction.data).value,
      'id': sessionId,
      'fid': fileId,
      'd': _encodeBase64Bytes(data),
      if (!isLastChunk) 'm': '1',  // More chunks coming
    });
  }

  /// Send end of file data
  ///
  /// This is a convenience method that always sets isLastChunk=true
  String sendEndOfData({
    required String sessionId,
    required String fileId,
    List<int>? trailingData,
  }) {
    return sendDataChunk(
      sessionId: sessionId,
      fileId: fileId,
      data: trailingData ?? [],
      isLastChunk: true,
    );
  }

  // ============ Response Parsing Helpers ============

  /// Parse a status response from terminal
  ///
  /// Returns a map of parsed values
  Map<String, String> parseResponse(String response) {
    // Strip the OSC prefix and terminator
    // Format: <OSC> 5113 ; key=value ; key=value ... <ST>
    final pattern = RegExp(r'^\x1b\]5113;(.*)\x1b\\$');
    final match = pattern.firstMatch(response);

    if (match == null) {
      return {};
    }

    final content = match.group(1) ?? '';
    final result = <String, String>{};

    // Parse key=value pairs (separated by ;)
    final pairs = content.split(';');
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
    final status = parsed['st'] ?? parsed['status'] ?? '';
    return status == 'OK' || status.startsWith('STARTED');
  }

  /// Get status message from response
  String getStatusMessage(Map<String, String> parsed) {
    return parsed['st'] ?? parsed['status'] ?? '';
  }

  // ============ Utility Methods ============

  /// Generate a unique session ID
  String generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.abs().toRadixString(36);
    return 'ft_$random';
  }

  /// Generate a unique file ID
  String generateFileId(int index) {
    return 'f${index + 1}';
  }

  /// Split data into chunks of maxChunkSize
  ///
  /// Returns list of data chunks, each at most maxChunkSize bytes
  List<List<int>> chunkData(List<int> data, {int? chunkSize}) {
    final size = chunkSize ?? maxChunkSize;
    final chunks = <List<int>>[];

    for (var i = 0; i < data.length; i += size) {
      final end = (i + size < data.length) ? i + size : data.length;
      chunks.add(data.sublist(i, end));
    }

    return chunks;
  }

  /// Send a file in chunks
  ///
  /// This is a convenience method that handles chunking automatically
  List<String> sendFileInChunks({
    required String sessionId,
    required String fileId,
    required List<int> fileData,
    int? chunkSize,
  }) {
    final chunks = chunkData(fileData, chunkSize: chunkSize);
    final sequences = <String>[];

    for (var i = 0; i < chunks.length; i++) {
      final isLast = (i == chunks.length - 1);
      sequences.add(sendDataChunk(
        sessionId: sessionId,
        fileId: fileId,
        data: chunks[i],
        isLastChunk: isLast,
      ));
    }

    return sequences;
  }
}
