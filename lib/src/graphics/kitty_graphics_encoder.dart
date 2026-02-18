/// Kitty Graphics Encoder - Encodes image data to Kitty Graphics Protocol escape sequences
///
/// Reference: doc/kitty/docs/graphics-protocol.rst
library kitty_protocol_graphics_encoder;

/// Image format types
enum KittyGraphicsFormat {
  /// 32-bit RGBA (default)
  rgba(32),
  /// 24-bit RGB
  rgb(24),
  /// PNG format
  png(100);

  final int value;
  const KittyGraphicsFormat(this.value);
}

/// Compression types
enum KittyGraphicsCompression {
  /// No compression
  none(''),
  /// ZLIB deflate
  deflate('z');

  final String value;
  const KittyGraphicsCompression(this.value);
}

/// Transmission medium types
enum KittyGraphicsTransmission {
  /// Direct transmission in escape code
  direct('d'),
  /// File path
  file('f'),
  /// Temporary file
  temporaryFile('t'),
  /// Shared memory
  sharedMemory('s');

  final String value;
  const KittyGraphicsTransmission(this.value);
}

/// Action types for graphics protocol
///
/// Per graphics-protocol.rst lines 917-1023:
enum KittyGraphicsAction {
  /// Transmit and display (a=T)
  transmitAndDisplay('T'),
  /// Transmit only (store with id) (a=t)
  transmit('t'),
  /// Display previously transmitted image (a=p)
  display('p'),
  /// Delete images (a=d)
  delete('d'),
  /// Query action (a=q)
  query('q'),
  /// Frame data for animation (a=f)
  /// Per line 852-872
  frame('f'),
  /// Animation control (a=a)
  /// Per line 917-952
  animation('a'),
  /// Composition (a=c)
  /// Per line 973-983
  composition('c');

  final String value;
  const KittyGraphicsAction(this.value);
}

/// Animation control types
///
/// Per graphics-protocol.rst line 917-952
enum KittyAnimationAction {
  /// Create animation from image
  create('c'),
  /// Play animation
  play('p'),
  /// Pause animation
  pause('P'),
  /// Clear animation
  clear('C');

  final String value;
  const KittyAnimationAction(this.value);
}

/// Animation loop modes
enum KittyAnimationLoop {
  /// Loop forever
  loop(0),
  /// Play once
  once(1),
  /// Reverse and loop
  bounce(2);

  final int value;
  const KittyAnimationLoop(this.value);
}

/// Cursor movement policy
enum KittyCursorMovement {
  /// Default - move cursor after placement
  autoMove(0),
  /// No cursor movement
  noMove(1);

  final int value;
  const KittyCursorMovement(this.value);
}

/// Graphics z-index positioning
enum KittyGraphicsLayer {
  /// Below text
  belowText(-1),
  /// Default layer
  defaultLayer(0),
  /// Above text
  aboveText(1);

  final int value;
  const KittyGraphicsLayer(this.value);
}

/// Placeholder for Kitty Graphics Encoder
///
/// This is a placeholder implementation. Full implementation will include:
/// - Image transmission (RGB, RGBA, PNG)
/// - Compression support (ZLIB deflate)
/// - Multiple transmission mediums (direct, file, shared memory)
/// - Chunked transmission for large images
/// - Image placement and positioning
/// - Delete operations
/// - Unicode placeholder support
///
/// Reference: doc/kitty/docs/graphics-protocol.rst
///
/// Example escape code format:
///   <ESC>_G<control data>;<payload><ESC>\
///
/// Control data is comma-separated key=value pairs:
///   - f: format (32=RGBA, 24=RGB, 100=PNG)
///   - s: width in pixels
///   - v: height in pixels
///   - o: compression (z=deflate)
///   - t: transmission medium (d=direct, f=file, t=temp, s=shared memory)
///   - m: chunk flag (1=more chunks, 0=last chunk)
///   - a: action (T=transmit+display, t=transmit, p=display, d=delete, q=query)
///   - i: image id
///   - p: placement id
///   - x, y: cursor position offsets
///   - c, r: columns and rows for display
///   - z: z-index
class KittyGraphicsEncoder {
  /// Default chunk size for base64 encoded data
  static const int defaultChunkSize = 4096;

  /// Maximum chunk size (must be multiple of 4 for base64)
  static const int maxChunkSize = 4096;

  const KittyGraphicsEncoder();

  /// Build a graphics escape sequence
  ///
  /// Format: <ESC>_G<control data>;<payload><ESC>\
  String buildSequence({
    required String controlData,
    required String payload,
  }) {
    return '\x1b_G$controlData;$payload\x1b\\';
  }

  /// Build control data from key-value pairs
  String buildControlData(Map<String, dynamic> params) {
    final pairs = <String>[];
    params.forEach((key, value) {
      if (value != null && value != 0 && value != '') {
        pairs.add('$key=$value');
      }
    });
    return pairs.join(',');
  }

  /// Encode image data to base64
  ///
  /// Uses standard Base64 encoding per RFC 4648
  /// Output is always valid Base64 with proper padding
  String encodeBase64(List<int> data) {
    // Use dart:convert for proper Base64 encoding
    const String _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

    if (data.isEmpty) return '';

    final buffer = StringBuffer();
    for (var i = 0; i < data.length; i += 3) {
      final b0 = data[i];
      final b1 = i + 1 < data.length ? data[i + 1] : 0;
      final b2 = i + 2 < data.length ? data[i + 2] : 0;

      buffer.write(_alphabet[(b0 >> 2) & 0x3F]);
      buffer.write(_alphabet[((b0 << 4) | (b1 >> 4)) & 0x3F]);
      buffer.write(i + 1 < data.length ? _alphabet[((b1 << 2) | (b2 >> 6)) & 0x3F] : '=');
      buffer.write(i + 2 < data.length ? _alphabet[b2 & 0x3F] : '=');
    }

    return buffer.toString();
  }

  /// Create a simple PNG transmission sequence
  ///
  /// Per protocol line 292:
  ///   <ESC>_Gf=100;<payload><ESC>\
  String encodePng(List<int> pngData, {int? imageId}) {
    final params = <String, dynamic>{
      'f': 100,
      if (imageId != null) 'i': imageId,
    };
    final controlData = buildControlData(params);
    final payload = encodeBase64(pngData);
    return buildSequence(controlData: controlData, payload: payload);
  }

  /// Create a RGBA image transmission sequence
  ///
  /// Per protocol line 281:
  ///   <ESC>_Gf=24,s=10,v=20;<payload><ESC>\
  String encodeRgba({
    required int width,
    required int height,
    required List<int> rgbaData,
    int? imageId,
    bool compress = false,
  }) {
    final params = <String, dynamic>{
      'f': 32,
      's': width,
      'v': height,
      if (compress) 'o': 'z',
      if (imageId != null) 'i': imageId,
    };
    final controlData = buildControlData(params);
    var data = rgbaData;
    if (compress) {
      // TODO: Implement compression
    }
    final payload = encodeBase64(data);
    return buildSequence(controlData: controlData, payload: payload);
  }

  /// Create an RGB image transmission sequence
  String encodeRgb({
    required int width,
    required int height,
    required List<int> rgbData,
    int? imageId,
    bool compress = false,
  }) {
    final params = <String, dynamic>{
      'f': 24,
      's': width,
      'v': height,
      if (compress) 'o': 'z',
      if (imageId != null) 'i': imageId,
    };
    final controlData = buildControlData(params);
    var data = rgbData;
    if (compress) {
      // TODO: Implement compression
    }
    final payload = encodeBase64(data);
    return buildSequence(controlData: controlData, payload: payload);
  }

  /// Create a delete command
  ///
  /// Per protocol line 782-786:
  ///   <ESC>_Ga=d<ESC>\
  String deleteAll() {
    return buildSequence(controlData: 'a=d', payload: '');
  }

  /// Delete specific image by id
  String deleteImage(int imageId, {int? placementId}) {
    final params = <String, dynamic>{
      'a': 'd',
      'd': 'i',
      'i': imageId,
      if (placementId != null) 'p': placementId,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Delete all images in cell range
  String deleteInRegion(int startX, int startY, int endX, int endY) {
    final params = <String, dynamic>{
      'a': 'd',
      'd': 'r',
      'x': startX,
      'y': startY,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Delete by z-index
  ///
  /// Per graphics-protocol.rst line 785:
  ///   <ESC>_Ga=d,d=Z,z=-1<ESC>\
  String deleteByZIndex(int zIndex, {bool freeData = true}) {
    final params = <String, dynamic>{
      'a': 'd',
      'd': 'Z',
      'z': zIndex,
      if (!freeData) 'f': 0,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Delete by cell position
  ///
  /// Per graphics-protocol.rst line 786:
  ///   <ESC>_Ga=d,d=p,x=3,y=4<ESC>\
  String deleteAtPosition(int x, int y, {bool freeData = true}) {
    final params = <String, dynamic>{
      'a': 'd',
      'd': 'p',
      'x': x,
      'y': y,
      if (!freeData) 'f': 0,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  // ============ Query Commands ============

  /// Query graphics protocol support
  ///
  /// Per graphics-protocol.rst line 427-444:
  String querySupport() {
    final params = <String, dynamic>{
      'a': 'q',
      't': 'd',
      'f': 24, // Request minimal format
    };
    return buildSequence(controlData: buildControlData(params), payload: 'AAAA');
  }

  /// Query image by ID
  ///
  /// Per graphics-protocol.rst line 811-814:
  String queryImage(int imageId) {
    final params = <String, dynamic>{
      'a': 'q',
      'd': 'i',
      'i': imageId,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Query image by number
  String queryImageByNumber(int imageNumber) {
    final params = <String, dynamic>{
      'a': 'q',
      'd': 'I',
      'I': imageNumber,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Query placement by ID
  String queryPlacement(int placementId) {
    final params = <String, dynamic>{
      'a': 'q',
      'd': 'p',
      'p': placementId,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Query at current cursor position
  String queryAtCursor() {
    final params = <String, dynamic>{
      'a': 'q',
      'd': 'c', // cursor position
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Query all images
  String queryAllImages() {
    final params = <String, dynamic>{
      'a': 'q',
      'd': 'a', // all
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Create a placement command
  ///
  /// Per protocol lines 457-459:
  ///   <ESC>_Ga=p,i=10<ESC>\
  String placeImage({
    required int imageId,
    int? placementId,
    int? columns,
    int? rows,
    int? xOffset,
    int? yOffset,
    int? zIndex,
    KittyCursorMovement cursorMovement = KittyCursorMovement.autoMove,
  }) {
    final params = <String, dynamic>{
      'a': 'p',
      'i': imageId,
      if (placementId != null) 'p': placementId,
      if (columns != null) 'c': columns,
      if (rows != null) 'r': rows,
      if (xOffset != null) 'X': xOffset,
      if (yOffset != null) 'Y': yOffset,
      if (zIndex != null) 'z': zIndex,
      'C': cursorMovement.value,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Transmit and display image in one command
  ///
  /// Per protocol line 457:
  ///   <ESC>_Ga=T,f=100,<payload><ESC>\
  String transmitAndDisplay({
    required int imageId,
    int? columns,
    int? rows,
    int? xOffset,
    int? yOffset,
    int? zIndex,
  }) {
    final params = <String, dynamic>{
      'a': 'T',
      'i': imageId,
      if (columns != null) 'c': columns,
      if (rows != null) 'r': rows,
      if (xOffset != null) 'X': xOffset,
      if (yOffset != null) 'Y': yOffset,
      if (zIndex != null) 'z': zIndex,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Chunk data for transmission
  ///
  /// Per protocol lines 383-401:
  /// Split data into chunks of maxChunkSize bytes
  List<String> chunkData(List<int> data) {
    final chunks = <String>[];
    final base64Data = encodeBase64(data);

    for (var i = 0; i < base64Data.length; i += maxChunkSize) {
      final end = (i + maxChunkSize < base64Data.length)
          ? i + maxChunkSize
          : base64Data.length;
      chunks.add(base64Data.substring(i, end));
    }

    return chunks;
  }

  // ============ Frame Transmission (Animation) ============

  /// Transmit frame data for animation
  ///
  /// Per graphics-protocol.rst line 852-872:
  ///   <ESC>_Ga=f,i=<image_id>,I=<frame_number>;<payload><ESC>\
  String transmitFrame({
    required int imageId,
    required int frameNumber,
    required List<int> frameData,
    KittyGraphicsFormat format = KittyGraphicsFormat.rgba,
    bool compress = false,
    bool moreChunks = false,
  }) {
    final params = <String, dynamic>{
      'a': 'f',
      'i': imageId,
      'I': frameNumber,
      'f': format.value,
      if (compress) 'o': 'z',
      if (moreChunks) 'm': 1,
    };
    final payload = compress ? _compress(frameData) : frameData;
    return buildSequence(
      controlData: buildControlData(params),
      payload: encodeBase64(payload),
    );
  }

  /// Transmit PNG frame for animation
  ///
  /// Per graphics-protocol.rst line 872:
  String transmitPngFrame({
    required int imageId,
    required int frameNumber,
    required List<int> pngData,
    bool moreChunks = false,
  }) {
    final params = <String, dynamic>{
      'a': 'f',
      'i': imageId,
      'I': frameNumber,
      'f': 100, // PNG format
      if (moreChunks) 'm': 1,
    };
    return buildSequence(
      controlData: buildControlData(params),
      payload: encodeBase64(pngData),
    );
  }

  // ============ Animation Control ============

  /// Create animation from existing frames
  ///
  /// Per graphics-protocol.rst line 917-924:
  ///   <ESC>_Ga=a,i=3,c=7<ESC>\
  String animationCreate({
    required int imageId,
    required int frameCount,
    int? intervalMs,
    KittyAnimationLoop loop = KittyAnimationLoop.loop,
  }) {
    final params = <String, dynamic>{
      'a': 'a',
      'i': imageId,
      'c': frameCount,
      if (intervalMs != null) 'I': intervalMs,
      'l': loop.value,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Play animation
  ///
  /// Per graphics-protocol.rst line 924:
  ///   <ESC>_Ga=a,i=7,r=3,z=48<ESC>\
  String animationPlay({
    required int imageId,
    required int fromFrame,
    required int toFrame,
    int? zIndex,
    bool loop = true,
  }) {
    final params = <String, dynamic>{
      'a': 'a',
      'i': imageId,
      'r': '$fromFrame-$toFrame',
      if (zIndex != null) 'z': zIndex,
      if (loop) 'l': 0,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Pause animation
  ///
  /// Per graphics-protocol.rst line 924:
  /// Uses 'a=a' for animation action with sub-action parameter
  String animationPause({required int imageId}) {
    // Animation pause uses 'a' key for animation type and 'f' for pause action
    final params = <String, dynamic>{
      'a': 'a',
      'i': imageId,
      'f': 'P', // pause - using 'f' as sub-action for pause
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Clear animation
  ///
  /// Uses 'a=a' for animation action
  String animationClear({required int imageId}) {
    final params = <String, dynamic>{
      'a': 'a',
      'i': imageId,
      'f': 'C', // clear - using 'f' as sub-action for clear
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  // ============ Composition ============

  /// Create composition (frame overlay)
  ///
  /// Per graphics-protocol.rst line 973-983:
  ///   <ESC>_Ga=c,i=1,r=7,c=9,w=23,h=27,X=4,Y=8,x=1,y=3<ESC>\
  String compositionCreate({
    required int sourceImageId,
    required int destImageId,
    required int sourceColumns,
    required int sourceRows,
    required int destColumns,
    required int destRows,
    int? sourceX,
    int? sourceY,
    int? destX,
    int? destY,
  }) {
    final params = <String, dynamic>{
      'a': 'c',
      'i': sourceImageId,
      'I': destImageId,
      'c': sourceColumns,
      'r': sourceRows,
      'w': destColumns,
      'h': destRows,
      if (sourceX != null) 'X': sourceX,
      if (sourceY != null) 'Y': sourceY,
      if (destX != null) 'x': destX,
      if (destY != null) 'y': destY,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  // ============ Advanced Positioning ============

  /// Create virtual placement (U parameter)
  ///
  /// Per graphics-protocol.rst line 578-581:
  /// Creates a virtual image that can be positioned independently
  String virtualPlacement({
    required int imageId,
    int? columns,
    int? rows,
    int? xOffset,
    int? yOffset,
    int? zIndex,
  }) {
    final params = <String, dynamic>{
      'a': 'p',
      'U': 1, // Create virtual placement
      'i': imageId,
      if (columns != null) 'c': columns,
      if (rows != null) 'r': rows,
      if (xOffset != null) 'X': xOffset,
      if (yOffset != null) 'Y': yOffset,
      if (zIndex != null) 'z': zIndex,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  /// Create relative placement (P/Q parameters)
  ///
  /// Per graphics-protocol.rst line 692-695:
  String relativePlacement({
    required int imageId,
    required int placementId,
    required int parentImageId,
    int? parentPlacementId,
    int? xOffset,
    int? yOffset,
  }) {
    final params = <String, dynamic>{
      'a': 'p',
      'i': imageId,
      'p': placementId,
      'P': parentImageId,
      if (parentPlacementId != null) 'Q': parentPlacementId,
      if (xOffset != null) 'X': xOffset,
      if (yOffset != null) 'Y': yOffset,
    };
    return buildSequence(controlData: buildControlData(params), payload: '');
  }

  // ============ Compression Helper ============

  /// Compress data using zlib deflate
  List<int> _compress(List<int> data) {
    // Placeholder - in full implementation use dart:zlib
    return data;
  }
}

/// Unicode Placeholders for Graphics
///
/// Per graphics-protocol.rst, Unicode placeholders can be used to ensure
/// images scroll with text content.
///
/// The terminal will replace these with the actual image when rendering.
class KittyGraphicsPlaceholders {
  KittyGraphicsPlaceholders._();

  /// Get placeholder character for image width
  ///
  /// Use this to create a placeholder that matches image dimensions
  static String getPlaceholder({
    required int widthInCells,
    int heightInCells = 1,
  }) {
    // For single cell, use thin space
    if (widthInCells == 1 && heightInCells == 1) {
      return '\u200B'; // Zero width space
    }

    // For multi-cell, use block characters
    final buffer = StringBuffer();
    for (var y = 0; y < heightInCells; y++) {
      for (var x = 0; x < widthInCells; x++) {
        // Use medium shade for placeholder
        buffer.write('\u2591');
      }
      if (heightInCells > 1) buffer.write('\n');
    }
    return buffer.toString();
  }

  /// Generate a transparent placeholder (zero-width)
  static String get transparent => '\u200B';

  /// Generate a 1-cell placeholder
  static String get singleCell => '\u2588'; // Full block
}
