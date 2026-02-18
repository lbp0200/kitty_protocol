/// Kitty Protocol - Dart implementation of the Kitty Protocol for terminal emulators
///
/// This library provides encoders for all Kitty Terminal Protocols:
///
/// - **Keyboard Protocol**: Key event encoding with modifiers
///   Reference: doc/kitty/docs/keyboard-protocol.rst
///
/// - **Graphics Protocol**: Image transmission and display
///   Reference: doc/kitty/docs/graphics-protocol.rst
///
/// - **Text Sizing Protocol**: Variable-size text rendering
///   Reference: doc/kitty/docs/text-sizing-protocol.rst
///
/// Reference: doc/kitty/docs/
library kitty_protocol;

// Keyboard protocol exports
export 'src/keyboard/kitty_encoder.dart';
export 'src/keyboard/kitty_key_codes.dart';
export 'src/keyboard/kitty_flags.dart';
export 'src/keyboard/kitty_modifier_codes.dart';

// Graphics protocol exports
export 'src/graphics/kitty_graphics_encoder.dart';

// Text sizing protocol exports
export 'src/text_sizing/kitty_text_sizing_encoder.dart';

// Common exports
export 'src/common/kitty_common.dart';
