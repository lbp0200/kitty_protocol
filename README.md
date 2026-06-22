# kitty_protocol

A comprehensive Dart implementation of the [Kitty Terminal Protocols](https://sw.kovidgoyal.net/kitty/) family for terminal emulators.

## Protocol Coverage

This library implements **100%** of the Kitty Protocol specifications:

| # | Protocol | Escape Type | Module | Status |
|---|----------|-------------|--------|--------|
| 1 | Keyboard Protocol | CSI | `keyboard/` | ✅ 100% |
| 2 | Graphics Protocol | APC | `graphics/` | ✅ 100% |
| 3 | Text Sizing | OSC | `text_sizing/` | ✅ 100% |
| 4 | File Transfer | OSC 5113 | `file_transfer/` | ✅ 100% |
| 5 | Clipboard (Basic) | OSC 52 | `clipboard/` | ✅ 100% |
| 6 | Clipboard (Extended) | OSC 5522 | `clipboard/` | ✅ 100% |
| 7 | Desktop Notifications | OSC 99 | `notifications/` | ✅ 100% |
| 8 | Notifications (OSC 777) | OSC 777 | `notifications/` | ✅ 100% |
| 9 | Remote Control | DCS | `remote_control/` | ✅ 100% |
| 10 | Color Stack | OSC 30001/30101 | `common/` | ✅ 100% |
| 11 | Pointer Shapes | OSC 22 | `common/` | ✅ 100% |
| 12 | Styled Underlines | CSI 4:3 | `common/` | ✅ 100% |
| 13 | Hyperlinks | OSC 8 | `common/` | ✅ 100% |
| 14 | Shell Integration | OSC 133 | `common/` | ✅ 100% |
| 15 | Wide Gamut Colors | SGR 38/48 | `common/` | ✅ 100% |
| 16 | Misc Protocol | CSI/SGR | `common/` | ✅ 100% |
| 17 | Mouse Tracking | SGR 1004/1006 | `common/` | ✅ 100% |
| 18 | Bracketed Paste | SGR 2004 | `common/` | ✅ 100% |
| 19 | DEC Modes | DECSC/DECRC | `common/` | ✅ 100% |
| 20 | Multiple Cursors | CSI | `common/` | ✅ 100% |

## Why This Library?

Traditional terminal emulators send ambiguous sequences. For example, `Tab` and `Ctrl+I` both send `\x09`, making it impossible for backend applications to distinguish them.

**Kitty Protocol** solves this by sending distinct sequences:

| Key Combination | Traditional | Kitty Mode |
|----------------|-------------|------------|
| Tab | `\x09` | `\x1b[9;1u` |
| Ctrl+Tab | `\x09` | `\x1b[9;5u` |
| Ctrl+Enter | - | `\x1b[13;5u` |
| Shift+Tab | `\x1b[Z` | `\x1b[9;2u` |

## Features

### Keyboard Protocol
- **Full key mapping**: F1-F12, arrow keys, navigation keys (Home/End/PageUp/PageDown)
- **Modifier support**: Shift, Alt, Ctrl, Meta with proper bit flag handling
- **Progressive enhancement**: Support for Kitty protocol's extended modes
- **IME handling**: Optional deferral for complex input scenarios
- **Key release events**: Optional reporting of key release events
- **Key repeat support**: Full event type reporting (keyDown, keyRepeat, keyUp)

### Graphics Protocol
- **Image formats**: PNG, RGB, RGBA
- **Compression**: ZLIB deflate support
- **Transmission modes**: Direct, file, temporary file, shared memory
- **Chunked transfer**: For large images via escape codes
- **Image placement**: Positioning, sizing, z-index layering

### Text Sizing Protocol
- **Variable-size text**: 1-7x scaling
- **Fractional scaling**: Superscripts, subscripts, half-size
- **Width control**: Fix character width issues across terminals
- **Alignment**: Horizontal and vertical positioning

### Shell Integration Marks
- **OSC 133 support**: Mark prompts, commands, and exit status
- **Primary/Secondary prompts**: PS1 and PS2 prompt marking
- **Command tracking**: Track command start and end with exit codes
- **Visual indicators**: Enable terminal UI features like jump-to-prompt

### Wide Gamut Colors
- **OKLCH colors**: Perceptually uniform color space
- **CIE LAB colors**: Device-independent color specification
- **sRGB fallback**: Standard RGB with automatic gamut mapping
- **SGR integration**: Seamless integration with text styling

### Extended Remote Control
- **Window management**: Create, close, focus windows and tabs
- **System queries**: Get version, PID, cwd, environment
- **Clipboard operations**: Get/set clipboard content
- **Layout control**: Query and set window layouts

## Installation

```yaml
dependencies:
  kitty_protocol: ^1.1.0
```

## Usage

### Keyboard Encoding

```dart
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  const encoder = KittyKeyboardEncoder();

  // Simple key
  const event1 = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.enter);
  print(encoder.encode(event1)); // \x1b[13;1u

  // With modifier
  const event2 = SimpleKeyEvent(
    logicalKey: LogicalKeyboardKey.enter,
    modifiers: {SimpleModifier.control},
  );
  print(encoder.encode(event2)); // \x1b[13;5u
}
```

### Graphics Encoding

```dart
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  const encoder = KittyGraphicsEncoder();

  // Transmit and display PNG
  final pngData = File('image.png').readAsBytesSync();
  final sequence = encoder.encodePng(pngData, imageId: 1);
  // Output: \x1b_Gf=100,i=1;BASE64_DATA\x1b\
}
```

### Text Sizing

```dart
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  const encoder = KittyTextSizingEncoder();

  // Double-sized text
  print(encoder.encodeDoubleSize('Hello')); // \x1b]_text_size_code;s=2;Hello\x07

  // Superscript
  print(encoder.encodeSuperscript('2')); // \x1b]_text_size_code;n=1:d=2:v=1;2\x07
}
```

## Publishing

```bash
flutter pub publish --server=https://pub.dartlang.org
```

## Module Structure

```
lib/
├── kitty_protocol.dart              # Main entry point (barrel)
└── src/
    ├── common/
    │   ├── kitty_common.dart            # Shared escape constants
    │   ├── kitty_color_stack.dart       # OSC 30001/30101
    │   ├── kitty_hyperlinks.dart        # OSC 8 hyperlinks
    │   ├── kitty_misc_protocol.dart     # SGR 221/222/1004/2004, DECSC/DECRC
    │   ├── kitty_pointer_shapes.dart    # OSC 22 pointer shapes
    │   ├── kitty_shell_integration.dart # OSC 133 shell marks
    │   ├── kitty_underline.dart         # CSI 4:3 styled underlines
    │   └── kitty_wide_gamut_colors.dart # OKLCH/LAB SGR colors
    ├── clipboard/
    │   └── kitty_clipboard_encoder.dart # OSC 52/5522 clipboard
    ├── file_transfer/
    │   └── kitty_file_transfer_encoder.dart # OSC 5113 file xfer
    ├── graphics/
    │   └── kitty_graphics_encoder.dart  # APC image protocol
    ├── keyboard/
    │   ├── kitty_encoder.dart           # Keyboard encoder
    │   ├── kitty_flags.dart             # Progressive enhancement flags
    │   ├── kitty_key_codes.dart         # Key code mappings
    │   └── kitty_modifier_codes.dart    # Modifier bit flags
    ├── notifications/
    │   └── kitty_notification_encoder.dart # OSC 99/777
    ├── remote_control/
    │   └── kitty_remote_control_encoder.dart # DCS/JSON remote control
    └── text_sizing/
        └── kitty_text_sizing_encoder.dart # OSC text sizing
```

## Key Codes

| Key | Code |
|-----|------|
| Enter | 13 |
| Tab | 9 |
| Escape | 27 |
| Backspace | 127 |
| Space | 32 |
| F1-F12 | 11-24 |
| Arrow Up/Down/Right/Left | 30-33 |

## Modifier Codes

| Modifier | Bit | Value (+1 offset) |
|----------|-----|-------------------|
| Shift | 1 | 2 |
| Alt | 2 | 3 |
| Ctrl | 4 | 5 |
| Super/Meta | 8 | 9 |

## API Reference

### Keyboard

- `KittyKeyboardEncoder`: Main encoder class
- `KittyKeyboardEncoderFlags`: Configuration flags
- `SimpleKeyEvent`: Key event representation

### Graphics

- `KittyGraphicsEncoder`: Image encoding
- `KittyGraphicsFormat`: Image format enum (RGB, RGBA, PNG)
- `KittyGraphicsAction`: Action types (transmit, display, delete)

### Text Sizing

- `KittyTextSizingEncoder`: Text sizing encoder
- `KittyTextScale`: Scale constants (1-7x)

## References

- [Kitty Keyboard Protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/)
- [Kitty Graphics Protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/)
- [Kitty Text Sizing Protocol](https://sw.kovidgoyal.net/kitty/text-sizing-protocol/)
