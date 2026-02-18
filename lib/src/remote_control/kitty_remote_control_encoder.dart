/// Kitty Remote Control Encoder - Remote control for Kitty Protocol
///
/// Reference: doc/kitty/docs/rc_protocol.rst
library kitty_protocol_remote_control_encoder;

/// Remote control encoder
///
/// Per protocol lines 8-20:
///
/// Format:
///   <ESC>P@kitty-cmd<JSON object><ESC>\
///
/// Example:
///   <ESC>P@kitty-cmd{"cmd":"ls","version":[0,14,2]}<ESC>\
class KittyRemoteControlEncoder {
  /// DCS code for kitty remote control
  static const String dcsPrefix = '\x1bP@kitty-cmd';

  /// String terminator
  static const String terminator = '\x1b\\';

  /// Current kitty version
  static const List<int> defaultVersion = [0, 14, 2];

  const KittyRemoteControlEncoder();

  /// Build a remote control command
  ///
  /// Per protocol lines 10-20:
  ///   {
  ///     "cmd": "command name",
  ///     "version": [0, 14, 2],
  ///     "no_response": false,
  ///     "kitty_window_id": "...",
  ///     "payload": {...}
  ///   }
  String buildCommand({
    required String command,
    List<int>? version,
    bool noResponse = false,
    String? kittyWindowId,
    Map<String, dynamic>? payload,
  }) {
    final cmd = <String, dynamic>{
      'cmd': command,
      'version': version ?? defaultVersion,
      if (noResponse) 'no_response': true,
      if (kittyWindowId != null) 'kitty_window_id': kittyWindowId,
      if (payload != null) 'payload': payload,
    };

    final json = _encodeJson(cmd);
    return '$dcsPrefix$json$terminator';
  }

  /// Simple JSON encoder (for basic types)
  String _encodeJson(dynamic value) {
    if (value == null) return 'null';
    if (value is bool) return value.toString();
    if (value is num) return value.toString();
    if (value is String) return '"${_escapeString(value)}"';
    if (value is List) {
      return '[${value.map(_encodeJson).join(',')}]';
    }
    if (value is Map) {
      final entries = value.entries.map((e) => '"${e.key}":${_encodeJson(e.value)}');
      return '{${entries.join(',')}}';
    }
    return 'null';
  }

  String _escapeString(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t')
        // CRITICAL: Escape ESC character to prevent DCS sequence truncation
        // Per rc_protocol.rst, ESC in JSON payload could prematurely terminate DCS
        .replaceAll('\x1b', '\\x1b');
  }

  // ============ Common Commands ============

  /// List windows
  String listWindows() {
    return buildCommand(command: 'ls');
  }

  /// Get window information
  String getWindowInfo({int? windowId}) {
    return buildCommand(
      command: 'get_window_info',
      payload: windowId != null ? {'window_id': windowId} : null,
    );
  }

  /// Close a window
  String closeWindow(int windowId, {bool? noResponse}) {
    return buildCommand(
      command: 'close_window',
      payload: {'window_id': windowId},
      noResponse: noResponse ?? true,
    );
  }

  /// Set window title
  String setWindowTitle(String title, {int? windowId}) {
    return buildCommand(
      command: 'set_window_title',
      payload: {
        'title': title,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Send text to window
  String sendText(String text, {int? windowId, bool? noResponse}) {
    return buildCommand(
      command: 'send_text',
      payload: {
        'text': text,
        if (windowId != null) 'window_id': windowId,
      },
      noResponse: noResponse ?? true,
    );
  }

  /// Input Unicode text
  String input(String text, {int? windowId}) {
    return buildCommand(
      command: 'input',
      payload: {
        'text': text,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Clear screen
  String clearScreen({int? windowId}) {
    return buildCommand(
      command: 'clear_screen',
      payload: windowId != null ? {'window_id': windowId} : null,
    );
  }

  /// Scroll screen
  String scroll(int lines, {int? windowId}) {
    return buildCommand(
      command: 'scroll',
      payload: {
        'lines': lines,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Get colors
  String getColors() {
    return buildCommand(command: 'get_colors');
  }

  /// Get configuration
  String getConfig() {
    return buildCommand(command: 'get_config');
  }

  /// Query terminal capability
  String getTerminfo({String? name}) {
    return buildCommand(
      command: 'get_terminal_attribute',
      payload: name != null ? {'attr': name} : null,
    );
  }

  // ============ Tab Management ============

  /// Create a new tab
  String newTab({String? title, String? cwd, bool noResponse = true}) {
    return buildCommand(
      command: 'new_tab',
      payload: {
        if (title != null) 'title': title,
        if (cwd != null) 'cwd': cwd,
      },
      noResponse: noResponse,
    );
  }

  /// Close a tab
  String closeTab(int tabId, {bool noResponse = true}) {
    return buildCommand(
      command: 'close_tab',
      payload: {'tab_id': tabId},
      noResponse: noResponse,
    );
  }

  /// Focus a tab
  String focusTab(int tabId, {bool noResponse = true}) {
    return buildCommand(
      command: 'focus_tab',
      payload: {'tab_id': tabId},
      noResponse: noResponse,
    );
  }

  /// Set tab title
  String setTabTitle(String title, {int? tabId}) {
    return buildCommand(
      command: 'set_tab_title',
      payload: {
        'title': title,
        if (tabId != null) 'tab_id': tabId,
      },
    );
  }

  // ============ System/Resource Queries ============

  /// Get system version
  String getVersion() {
    return buildCommand(command: 'version');
  }

  /// Get environmental variables
  String getEnvironment() {
    return buildCommand(command: 'get_environment');
  }

  /// Get OS information
  String getOs() {
    return buildCommand(command: 'get_os');
  }

  /// Get current working directory
  String getCwd({int? windowId}) {
    return buildCommand(
      command: 'get_cwd',
      payload: windowId != null ? {'window_id': windowId} : null,
    );
  }

  /// Get process ID
  String getPid({int? windowId}) {
    return buildCommand(
      command: 'get_pid',
      payload: windowId != null ? {'window_id': windowId} : null,
    );
  }

  // ============ Clipboard Operations ============

  /// Get clipboard content
  String getClipboard() {
    return buildCommand(command: 'get_clipboard');
  }

  /// Set clipboard content
  String setClipboard(String text, {bool noResponse = true}) {
    return buildCommand(
      command: 'set_clipboard',
      payload: {'text': text},
      noResponse: noResponse,
    );
  }

  // ============ Layout Control ============

  /// Get layout information
  String getLayout() {
    return buildCommand(command: 'get_layout');
  }

  /// Set layout
  String setLayout(String layoutName, {int? windowId}) {
    return buildCommand(
      command: 'set_layout',
      payload: {
        'name': layoutName,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  // ============ Window Resize & Position ============

  /// Resize a window
  ///
  /// Adjusts the size of a window
  String resizeWindow(int width, int height, {int? windowId}) {
    return buildCommand(
      command: 'resize_window',
      payload: {
        'width': width,
        'height': height,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Set window size (in cells)
  ///
  /// Sets the window size in character cells
  String setWindowSize({
    required int width,
    required int height,
    int? windowId,
  }) {
    return buildCommand(
      command: 'set_window_size',
      payload: {
        'width': width,
        'height': height,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Set window padding
  ///
  /// Per rc_protocol.rst - sets window padding
  String setWindowPadding({
    int? left,
    int? top,
    int? right,
    int? bottom,
    int? windowId,
  }) {
    return buildCommand(
      command: 'set_window_padding',
      payload: {
        if (left != null) 'left': left,
        if (top != null) 'top': top,
        if (right != null) 'right': right,
        if (bottom != null) 'bottom': bottom,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Move a window
  String moveWindow(int x, int y, {int? windowId}) {
    return buildCommand(
      command: 'move_window',
      payload: {
        'x': x,
        'y': y,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  // ============ Window Visual Enhancement ============

  /// Set window logo
  ///
  /// Per rc_protocol.rst - sets a logo image for the window
  String setWindowLogo(String path, {int? windowId}) {
    return buildCommand(
      command: 'set_window_logo',
      payload: {
        'path': path,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Set window background opacity
  ///
  /// Per rc_protocol.rst - sets window background transparency
  String setWindowBackgroundOpacity(double opacity, {int? windowId}) {
    return buildCommand(
      command: 'set_window_background_opacity',
      payload: {
        'opacity': opacity,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  // ============ Tab Operations ============

  /// Detach a tab
  ///
  /// Moves a tab to a new OS window
  String detachTab(int tabId, {bool noResponse = true}) {
    return buildCommand(
      command: 'detach_tab',
      payload: {'tab_id': tabId},
      noResponse: noResponse,
    );
  }

  /// Move a tab
  String moveTab(int tabId, int toIndex, {bool noResponse = true}) {
    return buildCommand(
      command: 'move_tab',
      payload: {
        'tab_id': tabId,
        'to': toIndex,
      },
      noResponse: noResponse,
    );
  }

  /// Previous tab
  String previousTab({int? tabId, bool noResponse = true}) {
    return buildCommand(
      command: 'previous_tab',
      payload: tabId != null ? {'tab_id': tabId} : null,
      noResponse: noResponse,
    );
  }

  /// Next tab
  String nextTab({int? tabId, bool noResponse = true}) {
    return buildCommand(
      command: 'next_tab',
      payload: tabId != null ? {'tab_id': tabId} : null,
      noResponse: noResponse,
    );
  }

  // ============ OS Window Operations ============

  /// Create a new OS window
  String newOsWindow({
    String? title,
    String? cwd,
    String? layout,
    bool? keepForeground,
    bool noResponse = true,
  }) {
    return buildCommand(
      command: 'new_os_window',
      payload: {
        if (title != null) 'title': title,
        if (cwd != null) 'cwd': cwd,
        if (layout != null) 'layout': layout,
        if (keepForeground != null) 'keepForeground': keepForeground,
      },
      noResponse: noResponse,
    );
  }

  /// Close an OS window
  String closeOsWindow(int windowId, {bool noResponse = true}) {
    return buildCommand(
      command: 'close_os_window',
      payload: {'os_window_id': windowId},
      noResponse: noResponse,
    );
  }

  /// Get list of OS windows
  String listOsWindows() {
    return buildCommand(command: 'ls_os_windows');
  }

  /// Focus an OS window
  String focusOsWindow(int windowId, {bool noResponse = true}) {
    return buildCommand(
      command: 'focus_os_window',
      payload: {'os_window_id': windowId},
      noResponse: noResponse,
    );
  }

  // ============ Advanced Operations ============

  /// Set clipboard (alias for setClipboard)
  String writeToClipboard(String text, {bool noResponse = true}) {
    return setClipboard(text, noResponse: noResponse);
  }

  /// Get textual representation of an image
  String getImage({int? imageId, int? windowId}) {
    return buildCommand(
      command: 'get_image',
      payload: {
        if (imageId != null) 'id': imageId,
        if (windowId != null) 'window_id': windowId,
      },
    );
  }

  /// Reload config file
  String reloadConfig({bool noResponse = true}) {
    return buildCommand(
      command: 'reload_config',
      noResponse: noResponse,
    );
  }

  /// Display a notification
  String showNotification({
    required String message,
    String? title,
    bool noResponse = true,
  }) {
    return buildCommand(
      command: 'show_notification',
      payload: {
        'message': message,
        if (title != null) 'title': title,
      },
      noResponse: noResponse,
    );
  }

  // ============ Read-Only Queries ============

  /// Get platform information
  ///
  /// Returns OS, version, and other platform details
  String getPlatformInfo() {
    return buildCommand(command: 'get_platform_info');
  }

  /// Get font information
  ///
  /// Returns current font family, size, and rendering details
  String getFontInfo() {
    return buildCommand(command: 'get_font_info');
  }

  /// Get list of available layouts
  String getAvailableLayouts() {
    return buildCommand(command: 'get_available_layouts');
  }

  /// Get mouse buttons
  String getMouseButtons() {
    return buildCommand(command: 'get_pointer');
  }

  /// Get keyboard LEDs state
  String getKeyboardLeds() {
    return buildCommand(command: 'get_keyboard_leds');
  }

  // ============ Colors Management ============

  /// Set colors with reset option
  ///
  /// To reset all colors, pass an empty map or use resetAll: true
  String setColors({
    Map<String, String>? colors,
    bool resetAll = false,
    bool noResponse = true,
  }) {
    if (resetAll) {
      return buildCommand(
        command: 'set_colors',
        payload: {'all': 'default'},
        noResponse: noResponse,
      );
    }

    return buildCommand(
      command: 'set_colors',
      payload: colors,
      noResponse: noResponse,
    );
  }

  /// Reset all colors to defaults
  String resetColors({bool noResponse = true}) {
    return setColors(resetAll: true, noResponse: noResponse);
  }

  /// Set specific color
  String setColor({
    required int colorNumber,
    required String color,
    bool noResponse = true,
  }) {
    return buildCommand(
      command: 'set_colors',
      payload: {'$colorNumber': color},
      noResponse: noResponse,
    );
  }

  // ============ Signal Handling ============

  /// Send signal to process
  String signalProcess({
    required int pid,
    required String signal,
    bool noResponse = true,
  }) {
    return buildCommand(
      command: 'signal_child',
      payload: {
        'pid': pid,
        'signal': signal,
      },
      noResponse: noResponse,
    );
  }

  /// Remove watermark (clear background image)
  String removeWatermark({bool noResponse = true}) {
    return buildCommand(
      command: 'remove_watermark',
      noResponse: noResponse,
    );
  }
}
