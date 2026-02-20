# Kitty Key Encoder - Design Document

**Date**: 2026-02-16
**Topic**: Flutter KeyEvent to Kitty Keyboard Protocol Encoder

## Overview

Create a Flutter package `kitty_key_encoder` that encodes Flutter `KeyEvent` and `LogicalKeyboardKey` into Kitty Keyboard Protocol escape sequences. This enables Flutter terminal emulators to send properly formatted key sequences to backend processes (shells, Neovim, etc.).

## Use Case

- **Direction**: Flutter → Kitty Terminal (encoding)
- **Purpose**: Solve key ambiguity in Flutter terminal applications by following the official Kitty Keyboard Protocol spec

## Architecture

### Package Structure

```
lib/
├── kitty_key_encoder.dart        # Main export
├── src/
│   ├── kitty_encoder.dart         # Main KittyEncoder class
│   ├── kitty_key_codes.dart      # Key code mappings (F1-F12, Arrows, etc.)
│   ├── kitty_modifier_codes.dart # Modifier bit flag definitions
│   └── kitty_flags.dart          # Progressive enhancement flags
test/
└── kitty_encoder_test.dart       # Unit tests
```

### Core Classes

#### `KittyEncoderFlags`

Represents the progressive enhancement modes that can be set via CSI > n u:

```dart
class KittyEncoderFlags {
  /// Report key release events (bit 0)
  final bool reportEvent;

  /// Report alternate key representations (bit 1)
  final bool reportAlternateKeys;

  /// Report all keys as escape sequences (bit 2)
  final bool reportAllKeysAsEscape;

  /// Combine flags into the numeric CSI > value
  int toCSIValue();
}
```

#### `KittyEncoder`

Main encoder class:

```dart
class KittyEncoder {
  final KittyEncoderFlags flags;

  const KittyEncoder({this.flags = const KittyEncoderFlags()});

  /// Encode a Flutter KeyEvent to a Kitty Keyboard Protocol sequence
  String encode(KeyEvent event);

  /// Check if extended mode (CSI > n u) is active
  bool get isExtendedMode;

  /// Update flags dynamically
  KittyEncoder withFlags(KittyEncoderFlags newFlags);
}
```

## Modifier Calculation (Kitty Protocol Spec)

Modifiers are encoded as bit flags. The base values are:

| Modifier | Bit Flag |
|----------|----------|
| Shift    | 1        |
| Alt      | 2        |
| Ctrl     | 4        |
| Super    | 8        |
| Hyper    | 16       |
| Meta     | 32       |

**Kitty Protocol Detail**: The modifier value in escape sequences is `actual_modifiers + 1` to avoid ambiguity with 0 (no modifiers). This is a critical implementation detail.

Example:
- No modifiers: 1 (0 + 1)
- Shift: 2 (1 + 1)
- Ctrl+Shift: 6 (5 + 1)

## Key Code Mapping (Kitty Protocol Spec)

### Function Keys

| Key | Kitty Code |
|-----|------------|
| F1  | 11         |
| F2  | 12         |
| F3  | 13         |
| F4  | 14         |
| F5  | 15         |
| F6  | 17         |
| F7  | 18         |
| F8  | 19         |
| F9  | 20         |
| F10 | 21         |
| F11 | 23         |
| F12 | 24         |

### Modifier Keys

| Key         | Kitty Code |
|-------------|------------|
| Shift       | 1          |
| Alt         | 2          |
| Ctrl        | 4          |
| Meta/Super  | 8          |
| CapsLock    | 9          |
| ScrollLock  | 10         |
| NumLock     | 12         |

### Special Keys

| Key         | Kitty Code |
|-------------|------------|
| Enter       | 28         |
| Backspace   | 27         |
| Tab         | 29         |
| Escape      | 53         |
| Space       | 44         |
| Delete      | 127        |

### Navigation Keys

| Key       | Kitty Code |
|-----------|------------|
| Up       | 30         |
| Down     | 31         |
| Right    | 32         |
| Left     | 33         |
| PageDown | 34         |
| PageUp   | 35         |
| Home     | 36         |
| End      | 37         |
| Insert   | 38         |

### Action Keys

| Key         | Kitty Code |
|-------------|------------|
| Pause       | 43         |
| PrintScreen | 45         |

## Progressive Enhancement Modes

### Standard Mode (CSI u)
Simple format: `ESC [ key_code ; modifiers u`

Example: Shift+Enter = `\x1b[13;2u`

### Extended Mode (CSI > n u)

When flags are set via `CSI > n u`, the format can include:
- Modifier bitmap in base-26 encoding
- Character code (for printable keys)
- Sequence number for event tracking

Flag values (bits):
- Bit 0 (1): `reportEvent` - report key release
- Bit 1 (2): `reportAlternateKeys` - alternate representations
- Bit 2 (4): `reportAllKeysAsEscape` - all keys as escape sequences

## Encoding Algorithm

1. Extract modifier state from `KeyEvent` using `event.modifierMeta` or `RawKeyboard`
2. Map `LogicalKeyboardKey` to Kitty key code
3. Apply modifier offset (+1) per spec
4. Build escape sequence:
   - Standard: `\x1b[{key};{modifiers}u`
   - Extended: `\x1b[>{flags};{key};{modifiers}u` (when flags != 0)
5. For key release events: use `~` prefix when `reportEvent` flag is set

## Testing Requirements

### Test Cases

1. **Ctrl+Enter**: Should produce `\x1b[13;5u` (key 13, modifiers 4+1=5)
2. **Shift+Tab**: Should produce `\x1b[9;2u` (Tab=9, Shift=1+1=2)
3. **Alt+F4**: Should produce `\x1b[25;3u` (F4=15, Alt=2+1=3) - note: actual key code may vary
4. **F1**: Should produce `\x1b[11;1u` (with Shift modifier default)

### Test Coverage

- Functional keys: F1-F12
- Navigation: Arrow keys, PageUp/Down, Home/End
- Modifiers: Shift, Ctrl, Alt, combinations (Ctrl+Shift, Alt+Shift, etc.)
- Special: Tab, Enter, Backspace, Escape
- Edge cases: Key release events, unknown keys

## Dependencies

- `flutter` (SDK dependency)
- `flutter_test` (dev dependency for testing)

## Considerations

- Dynamic flag updates: The encoder should be able to change modes mid-session
- UTF-8 handling: Extended mode supports sending raw character codes
- Error handling: Unknown keys should fall back gracefully (perhaps to raw character)

## References

- [Kitty Keyboard Protocol Specification](https://sw.kovidgoyal.net/kitty/keyboard-protocol/)
