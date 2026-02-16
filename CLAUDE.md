# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`kitty_key_encoder` is a Flutter package that encodes Flutter KeyEvent to [Kitty Keyboard Protocol](https://sw.kde.org/sites/default/files/documents/keyboard-protocol.md) escape sequences. Used for Flutter terminal emulators to send properly formatted key sequences to backend processes.

## Commands

```bash
# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/kitty_encoder_test.dart
```

## Architecture

The package consists of 4 core components:

1. **KittyEncoder** (`lib/src/kitty_encoder.dart`) - Main class with `encode()` method
2. **KittyEncoderFlags** (`lib/src/kitty_flags.dart`) - Progressive enhancement flags (reportEvent, reportAlternateKeys, deferToSystemOnComplexInput)
3. **KittyKeyCodes** (`lib/src/kitty_key_codes.dart`) - Key code mappings (F1-F12, arrows, etc.)
4. **KittyModifierCodes** (`lib/src/kitty_modifier_codes.dart`) - Modifier bit flags with +1 offset calculation

### Key Design Decisions

- **SimpleKeyEvent**: Uses a custom class instead of Flutter's KeyEvent for cleaner API, but maps to LogicalKeyboardKey from flutter/services.dart
- **Modifier offset**: Uses bit flags (Shift=1, Alt=2, Ctrl=4) with +1 offset per Kitty spec
- **Escape sequence format**: Standard `\x1b[key;mods}u` or extended `\x1b[>flags;key;mods}u`
- **Key release**: When `reportEvent` is enabled, key release events get `~` prefix

### Kitty Protocol Key Points

- Modifier values use +1 offset: Shift=2, Ctrl=5, etc.
- Modifier-specific key code offsets: Ctrl=-15, Shift=-20, Alt=-10
- Functional keys: F1=11, F2=12, ... F12=24
- Navigation: Up=30, Down=31, Right=32, Left=33
