/// Kitty Pointer Shapes - Mouse pointer shape control for Kitty Protocol
///
/// Reference: docs/kitty/docs/pointer-shapes.rst
/// Pointer shape names
enum KittyPointerShape {
  /// A link/button (CSS: pointer)
  pointer('pointer'),
  /// Text selection (CSS: text)
  text('text'),
  /// Vertical text (CSS: vertical-text)
  verticalText('vertical-text'),
  /// Crosshair
  crosshair('crosshair'),
  /// Default cursor
  default_('default'),
  /// Alias/shortcut
  alias('alias'),
  /// Copy operation
  copy('copy'),
  /// Move operation
  move('move'),
  /// Grabbing (when actively grabbing)
  grabbing('grabbing'),
  /// Can grab
  canGrab('grab'),
  /// Not allowed
  notAllowed('not-allowed'),
  /// No drop
  noDrop('no-drop'),
  /// Resize: east-west
  eResize('e-resize'),
  /// Resize: north-south
  nResize('n-resize'),
  /// Resize: northeast-southwest
  neResize('ne-resize'),
  /// Resize: northwest-southeast
  nwResize('nw-resize'),
  /// Resize: east-west (both)
  ewResize('ew-resize'),
  /// Resize: north-south (both)
  nsResize('ns-resize'),
  /// Resize: diagonal (both)
  neswResize('nesw-resize'),
  /// Resize: diagonal (both)
  nwseResize('nwse-resize'),
  /// Help cursor
  help('help'),
  /// Wait/busy
  wait('wait'),
  /// Progress
  progress('progress'),
  /// Cell pointer
  cell('cell'),
  /// Zoom in
  zoomIn('zoom-in'),
  /// Zoom out
  zoomOut('zoom-out');

  final String value;
  const KittyPointerShape(this.value);
}

/// Pointer command types
enum KittyPointerCommand {
  /// Set pointer shape
  set('='),
  /// Push shape onto stack
  push('>'),
  /// Pop shape from stack
  pop('<'),
  /// Query
  query('?');

  final String value;
  const KittyPointerCommand(this.value);
}

/// Special pointer query names
class KittyPointerQueryNames {
  /// Current pointer shape
  static const String current = '__current__';
  /// Default pointer shape
  static const String default_ = '__default__';
  /// Grabbed pointer shape
  static const String grabbed = '__grabbed__';
}

/// Helper class for generating pointer shape escape sequences
///
/// Per protocol lines 13-31:
///
/// Examples:
///   // Set the pointer to a pointing hand
///   `<OSC> 22 ; pointer <ESC>`
///   // Reset the pointer to default
///   `<OSC> 22 ; <ESC>`
///   // Push a shape onto the stack
///   `<OSC> 22 ; >wait <ESC>`
///   // Pop a shape from the stack
///   `<OSC> 22 ; < <ESC>`
///   // Query current shape
///   `<OSC> 22 ; ?__current__ <ESC>`
class KittyPointerShapes {
  KittyPointerShapes._();

  /// OSC code for pointer shapes
  static const int oscCode = 22;

  /// Build a set pointer shape sequence
  ///
/// Per protocol line 23:
///   `<OSC> 22 ; pointer <ESC>`
  static String set(KittyPointerShape shape) {
    return '\x1b]$oscCode;${shape.value}\x1b\\';
  }

  /// Reset to default (no shape)
  ///
/// Per protocol line 25:
///   `<OSC> 22 ; <ESC>`
  static String reset() {
    return '\x1b]$oscCode;\x1b\\';
  }

  /// Push a shape onto the stack
  ///
/// Per protocol line 27:
///   `<OSC> 22 ; >wait <ESC>`
  static String push(List<KittyPointerShape> shapes) {
    final shapeNames = shapes.map((s) => s.value).join(',');
    return '\x1b]$oscCode;>$shapeNames\x1b\\';
  }

  /// Push a single shape onto the stack
  static String pushShape(KittyPointerShape shape) {
    return push([shape]);
  }

  /// Pop a shape from the stack
  ///
/// Per protocol line 29:
///   `<OSC> 22 ; < <ESC>`
  static String pop() {
    return '\x1b]$oscCode;<\x1b\\';
  }

  /// Query current shape
  ///
/// Per protocol lines 31-32:
///   `<OSC> 22 ; ?__current__ <ESC>`
  static String queryCurrent() {
    return '\x1b]$oscCode;?${KittyPointerQueryNames.current}\x1b\\';
  }

  /// Query default shape
  static String queryDefault() {
    return '\x1b]$oscCode;?${KittyPointerQueryNames.default_}\x1b\\';
  }

  /// Query grabbed shape
  static String queryGrabbed() {
    return '\x1b]$oscCode;?${KittyPointerQueryNames.grabbed}\x1b\\';
  }

  /// Query support for specific shapes
  ///
/// Per protocol lines 79-85:
///   `<OSC> 22 ; ?pointer,crosshair <ESC>`
  static String querySupport(List<KittyPointerShape> shapes) {
    final shapeNames = shapes.map((s) => s.value).join(',');
    return '\x1b]$oscCode;?$shapeNames\x1b\\';
  }

  // ============ Convenience Methods ============

  /// Set pointer to link/hand
  static String get link => set(KittyPointerShape.pointer);

  /// Set pointer to text selection
  static String get text => set(KittyPointerShape.text);

  /// Set pointer to crosshair
  static String get crosshair => set(KittyPointerShape.crosshair);

  /// Set pointer to wait/busy
  static String get wait => set(KittyPointerShape.wait);

  /// Set pointer to grab
  static String get grab => set(KittyPointerShape.canGrab);

  /// Set pointer to grabbing
  static String get grabbing => set(KittyPointerShape.grabbing);

  /// Set pointer to not allowed
  static String get notAllowed => set(KittyPointerShape.notAllowed);

  /// Set pointer to move
  static String get move => set(KittyPointerShape.move);

  /// Set pointer to copy
  static String get copy => set(KittyPointerShape.copy);

  /// Push wait cursor (for loading states)
  static String pushWait() => pushShape(KittyPointerShape.wait);

  /// Push pointer cursor (for clickable elements)
  static String pushPointer() => pushShape(KittyPointerShape.pointer);

  /// Pop cursor (restore previous)
  static String popCursor() => pop();
}
