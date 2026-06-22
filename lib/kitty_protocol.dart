/// Kitty Protocol - Dart implementation of the Kitty Protocol for terminal emulators
///
/// This library provides encoders for all Kitty Terminal Protocols:
///
/// - **Keyboard Protocol**: Key event encoding with modifiers
///   Reference: docs/kitty/docs/keyboard-protocol.rst
///
/// - **Graphics Protocol**: Image transmission and display
///   Reference: docs/kitty/docs/graphics-protocol.rst
///
/// - **Text Sizing Protocol**: Variable-size text rendering
///   Reference: docs/kitty/docs/text-sizing-protocol.rst
///
/// - **File Transfer Protocol**: File transfer over TTY
///   Reference: docs/kitty/docs/file-transfer-protocol.rst
///
/// - **Notifications Protocol**: Desktop notifications via OSC 99
///   Reference: docs/kitty/docs/desktop-notifications.rst
///
/// - **Remote Control Protocol**: Terminal control via DCS/JSON
///   Reference: docs/kitty/docs/rc_protocol.rst
///
/// Reference: docs/kitty/docs/
library;

// Keyboard protocol exports
export 'src/keyboard/kitty_encoder.dart';
export 'src/keyboard/kitty_key_codes.dart';
export 'src/keyboard/kitty_flags.dart';
export 'src/keyboard/kitty_modifier_codes.dart';

// Graphics protocol exports
export 'src/graphics/kitty_graphics_encoder.dart';

// Text sizing protocol exports
export 'src/text_sizing/kitty_text_sizing_encoder.dart';

// File transfer protocol exports
export 'src/file_transfer/kitty_file_transfer_encoder.dart';

// Clipboard protocol exports
export 'src/clipboard/kitty_clipboard_encoder.dart';

// Notifications protocol exports
export 'src/notifications/kitty_notification_encoder.dart';

// Common exports
export 'src/common/kitty_common.dart';
export 'src/common/kitty_underline.dart';
export 'src/common/kitty_pointer_shapes.dart';
export 'src/common/kitty_color_stack.dart';
export 'src/common/kitty_hyperlinks.dart';
export 'src/common/kitty_shell_integration.dart';
export 'src/common/kitty_wide_gamut_colors.dart';
export 'src/common/kitty_misc_protocol.dart';
export 'src/common/kitty_multiple_cursors.dart';

// Remote control exports
export 'src/remote_control/kitty_remote_control_encoder.dart';
