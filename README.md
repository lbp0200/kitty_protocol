# kitty_protocol

A comprehensive Dart implementation of the [Kitty Terminal Protocols](https://sw.kovidgoyal.net/kitty/) family for terminal emulators.

## Overview

This library provides encoders for all Kitty Protocol specifications:

| Protocol | Escape Type | Description |
|----------|-------------|-------------|
| Keyboard | CSI (`\x1b[`) | Key event encoding with modifiers |
| Graphics | APC (`\x1b_G`) | Image transmission and display |
| Text Sizing | OSC (`\x1b]`) | Variable-size text rendering |

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

## Module Structure

```
lib/
├── kitty_protocol.dart          # Main entry point
└── src/
    ├── common/
    │   └── kitty_common.dart  # Shared constants (CSI, APC, OSC)
    ├── keyboard/
    │   ├── kitty_encoder.dart       # Keyboard encoder
    │   ├── kitty_key_codes.dart     # Key code mappings
    │   ├── kitty_flags.dart         # Protocol flags
    │   └── kitty_modifier_codes.dart # Modifier definitions
    ├── graphics/
    │   └── kitty_graphics_encoder.dart # Graphics encoder
    └── text_sizing/
        └── kitty_text_sizing_encoder.dart # Text sizing encoder
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
