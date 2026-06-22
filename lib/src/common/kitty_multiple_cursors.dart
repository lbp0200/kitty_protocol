/// Kitty Multiple Cursors Protocol - Extra cursor display and control
///
/// Reference: docs/kitty/docs/multiple-cursors-protocol.rst
///
/// This protocol allows terminal programs to request that the terminal display
/// multiple cursors at specific locations on the screen, enabling proper cursor
/// rendering for editors that support multiple cursors.
library;

/// Cursor shapes for the multiple cursors protocol
enum KittyMultiCursorShape {
  /// No cursor (clear shape)
  none(0),
  /// Block cursor
  block(1),
  /// Beam (I-beam) cursor
  beam(2),
  /// Underline cursor
  underline(3),
  /// Follow the shape of the main cursor
  followMain(29),
  /// Change the color of text under extra cursors
  textColor(30),
  /// Change the color of extra cursors themselves
  cursorColor(40),
  /// Used for querying currently set cursors
  query(100);

  final int value;
  const KittyMultiCursorShape(this.value);
}

/// Coordinate types for cursor positioning
enum KittyCursorCoordType {
  /// Main cursor position (no coordinates needed)
  mainCursor(0),
  /// Cell coordinates as y:x pairs (1-based, top-left is 1,1)
  points(2),
  /// Rectangle as top:left:bottom:right
  rectangle(4);

  final int value;
  const KittyCursorCoordType(this.value);
}

/// Color space for extra cursor colors
enum KittyCursorColorSpace {
  /// Unset (same as main cursor)
  unset(0),
  /// Special (reverse video effect)
  special(1),
  /// sRGB color with three parameters (red, green, blue: 0-255)
  srgb(2),
  /// Indexed color with one parameter (0-255)
  indexed(5);

  final int value;
  const KittyCursorColorSpace(this.value);
}

/// Encoder for the Kitty Multiple Cursors Protocol
///
/// Generates `CSI > ... q` escape sequences for controlling extra cursors.
///
/// Per protocol spec:
/// ```
/// CSI > SHAPE;CO-ORD TYPE:CO-ORDINATES;... TRAILER
/// ```
/// where TRAILER is ` q` (space followed by 'q').
class KittyMultiCursor {
  KittyMultiCursor._();

  static const String _csi = '\x1b[>';
  static const String _trailer = ' q';
  static const String _separator = ';';

  /// Show extra cursors with the given [shape] at specified locations.
  ///
  /// [coordType] determines how [coordinates] are interpreted:
  /// - [KittyCursorCoordType.mainCursor]: coordinates are ignored
  /// - [KittyCursorCoordType.points]: pairs of (y, x) positions
  /// - [KittyCursorCoordType.rectangle]: sets of four (top, left, bottom, right)
  ///
  /// For [points], coordinates are grouped into pairs. For [rectangle],
  /// coordinates are grouped into sets of four. Each group becomes a separate
  /// coordinate block, separated by semicolons.
  ///
  /// [extraCoordTypes] can specify additional coordinate type blocks:
  /// ```dart
  /// KittyMultiCursor.show(
  ///   shape: KittyMultiCursorShape.underline,
  ///   coordType: KittyCursorCoordType.points,
  ///   coordinates: [7, 1],
  ///   extraCoordTypes: {
  ///     KittyCursorCoordType.rectangle: [5, 6, 7, 8],
  ///   },
  /// );  // => \x1b[>3;2:7:1;4:5:6:7:8 q
  /// ```
  static String show({
    required KittyMultiCursorShape shape,
    required KittyCursorCoordType coordType,
    List<int> coordinates = const [],
    Map<KittyCursorCoordType, List<int>>? extraCoordTypes,
  }) {
    final buffer = StringBuffer('$_csi${shape.value}$_separator');
    if (coordType != KittyCursorCoordType.mainCursor && coordinates.isNotEmpty) {
      _appendCoordBlock(buffer, coordType, coordinates);
    } else {
      buffer.write('${coordType.value}');
    }
    if (extraCoordTypes != null) {
      for (final entry in extraCoordTypes.entries) {
        if (entry.value.isNotEmpty) {
          buffer.write(_separator);
          _appendCoordBlock(buffer, entry.key, entry.value);
        }
      }
    }
    buffer.write(_trailer);
    return buffer.toString();
  }

  /// Clear extra cursors.
  ///
  /// Without arguments, clears all extra cursors (full-screen rectangle).
  /// With [coordType] and [coordinates], clears only at specified locations.
  static String clear({
    KittyCursorCoordType? coordType,
    List<int> coordinates = const [],
  }) {
    if (coordType == null || coordinates.isEmpty) {
      return '$_csi${KittyMultiCursorShape.none.value}$_separator'
          '${KittyCursorCoordType.rectangle.value}$_trailer';
    }
    final buffer = StringBuffer('$_csi${KittyMultiCursorShape.none.value}$_separator');
    _appendCoordBlock(buffer, coordType, coordinates);
    buffer.write(_trailer);
    return buffer.toString();
  }

  /// Query if the terminal supports the multiple cursors protocol.
  ///
  /// The terminal should respond with `\x1b[>1;2;3;29;30;40;100;101 q`.
  static String querySupport() {
    return '$_csi$_trailer';
  }

  /// Query currently set extra cursors.
  ///
  /// The terminal should respond with the active cursors.
  static String queryCursors() {
    return '$_csi${KittyMultiCursorShape.query.value}$_trailer';
  }

  /// Query extra cursor colors.
  ///
  /// The terminal should respond with the current cursor color settings.
  static String queryColors() {
    return '${_csi}101$_trailer';
  }

  /// Set the color of extra cursors.
  ///
  /// [colorSpace] and [parameters] define the color (see [KittyCursorColorSpace]).
  ///
  /// Example with sRGB red:
  /// ```dart
  /// KittyMultiCursor.setCursorColor(
  ///   colorSpace: KittyCursorColorSpace.srgb,
  ///   parameters: [255, 0, 0],
  /// );  // => \x1b[>40;2:255:0:0 q
  /// ```
  static String setCursorColor({
    required KittyCursorColorSpace colorSpace,
    List<int> parameters = const [],
  }) {
    return _setColor(KittyMultiCursorShape.cursorColor, colorSpace, parameters);
  }

  /// Set the color of text under extra cursors.
  ///
  /// [colorSpace] and [parameters] define the color (see [KittyCursorColorSpace]).
  static String setTextColor({
    required KittyCursorColorSpace colorSpace,
    List<int> parameters = const [],
  }) {
    return _setColor(KittyMultiCursorShape.textColor, colorSpace, parameters);
  }

  static String _setColor(
    KittyMultiCursorShape which,
    KittyCursorColorSpace colorSpace,
    List<int> parameters,
  ) {
    final buffer = StringBuffer('$_csi${which.value}$_separator${colorSpace.value}');
    for (final param in parameters) {
      buffer.write(':$param');
    }
    buffer.write(_trailer);
    return buffer.toString();
  }

  /// Append coordinate block(s) for the given [coordType] and flat [coordinates].
  ///
  /// Coordinates are split into groups based on coord type:
  /// - [points]: groups of 2 (y:x pairs), each group prefixed with coord type
  /// - [rectangle]: groups of 4 (top:left:bottom:right), each group prefixed
  static void _appendCoordBlock(
    StringBuffer buffer,
    KittyCursorCoordType coordType,
    List<int> coordinates,
  ) {
    final groupSize = coordType == KittyCursorCoordType.rectangle ? 4 : 2;
    var first = true;
    for (var i = 0; i + groupSize <= coordinates.length; i += groupSize) {
      if (!first) {
        buffer.write(_separator);
      }
      first = false;
      buffer.write('${coordType.value}');
      for (var j = 0; j < groupSize; j++) {
        buffer.write(':${coordinates[i + j]}');
      }
    }
  }
}
