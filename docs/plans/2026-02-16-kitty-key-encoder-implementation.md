# Kitty Key Encoder Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task.

**Goal:** Create a Flutter package `kitty_key_encoder` that encodes Flutter KeyEvent and LogicalKeyboardKey into Kitty Keyboard Protocol escape sequences.

**Architecture:** Single `KittyEncoder` class with supporting immutable value classes for key codes, modifiers, and flags. Uses TDD - tests drive implementation.

**Tech Stack:** Flutter/Dart, flutter_test

---

## Implementation Steps

### Task 1: Initialize Flutter Package Structure

**Files:**
- Create: `pubspec.yaml`
- Create: `lib/kitty_key_encoder.dart`
- Create: `lib/src/kitty_key_codes.dart`
- Create: `lib/src/kitty_modifier_codes.dart`
- Create: `lib/src/kitty_flags.dart`
- Create: `lib/src/kitty_encoder.dart`
- Create: `test/kitty_encoder_test.dart`

**Step 1: Create pubspec.yaml**

```yaml
name: kitty_key_encoder
description: Encode Flutter KeyEvent to Kitty Keyboard Protocol escape sequences.
version: 1.0.0
homepage: https://github.com/example/kitty_key_encoder

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

**Step 2: Create directory structure**

Run: `mkdir -p lib/src test`

**Step 3: Create empty library files**

Create all the files listed above with minimal exports.

**Step 4: Commit**

```bash
git add .
git commit -m "chore: scaffold Flutter package structure"
```

---

### Task 2: Implement KittyModifierCodes

**Files:**
- Create: `lib/src/kitty_modifier_codes.dart`
- Test: `test/kitty_encoder_test.dart` (add modifier tests)

**Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test';
import 'package:kitty_key_encoder/kitty_key_encoder.dart';

void main() {
  group('KittyModifierCodes', () {
    test('Shift has correct bit value', () {
      expect(KittyModifierCodes.shift, equals(1));
    });

    test('Alt has correct bit value', () {
      expect(KittyModifierCodes.alt, equals(2));
    });

    test('Ctrl has correct bit value', () {
      expect(KittyModifierCodes.ctrl, equals(4));
    });

    test('Super has correct bit value', () {
      expect(KittyModifierCodes.superKey, equals(8));
    });

    test('calculateModifiers returns base value without +1', () {
      expect(KittyModifierCodes.calculateModifiers(0), equals(0));
    });

    test('calculateModifiers adds 1 for Shift', () {
      expect(KittyModifierCodes.calculateModifiers(KittyModifierCodes.shift), equals(2));
    });

    test('calculateModifiers adds 1 for Ctrl', () {
      expect(KittyModifierCodes.calculateModifiers(KittyModifierCodes.ctrl), equals(5));
    });

    test('calculateModifiers combines Ctrl+Shift', () {
      expect(
        KittyModifierCodes.calculateModifiers(KittyModifierCodes.ctrl | KittyModifierCodes.shift),
        equals(6),
      );
    });

    test('calculateModifiers combines Ctrl+Alt+Shift', () {
      expect(
        KittyModifierCodes.calculateModifiers(
          KittyModifierCodes.ctrl | KittyModifierCodes.alt | KittyModifierCodes.shift,
        ),
        equals(8),
      );
    });
  });
}
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/kitty_encoder_test.dart`
Expected: FAIL - "The getter 'KittyModifierCodes' isn't defined"

**Step 3: Write minimal implementation**

```dart
/// Modifier bit flags per Kitty Keyboard Protocol spec
class KittyModifierCodes {
  static const int shift = 1;
  static const int alt = 2;
  static const int ctrl = 4;
  static const int superKey = 8;
  static const int hyper = 16;
  static const int meta = 32;

  /// Calculate modifier value with +1 offset per Kitty spec
  /// to avoid ambiguity with 0 (no modifiers)
  static int calculateModifiers(int modifierFlags) {
    return modifierFlags + 1;
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/kitty_encoder_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/src/kitty_modifier_codes.dart test/kitty_encoder_test.dart
git commit -m "feat: add KittyModifierCodes with bit flags and calculateModifiers"
```

---

### Task 3: Implement KittyKeyCodes

**Files:**
- Modify: `lib/src/kitty_key_codes.dart`
- Test: `test/kitty_encoder_test.dart` (add key mapping tests)

**Step 1: Write the failing test**

```dart
    group('KittyKeyCodes', () {
      test('F1 has correct code', () {
        expect(KittyKeyCodes.f1, equals(11));
      });

      test('F12 has correct code', () {
        expect(KittyKeyCodes.f12, equals(24));
      });

      test('ArrowUp has correct code', () {
        expect(KittyKeyCodes.arrowUp, equals(30));
      });

      test('ArrowLeft has correct code', () {
        expect(KittyKeyCodes.arrowLeft, equals(33));
      });

      test('Enter has correct code', () {
        expect(KittyKeyCodes.enter, equals(28));
      });

      test('Tab has correct code', () {
        expect(KittyKeyCodes.tab, equals(29));
      });

      test('Escape has correct code', () {
        expect(KittyKeyCodes.escape, equals(53));
      });

      test('getKeyCode returns correct code for LogicalKeyboardKey', () {
        expect(KittyKeyCodes.getKeyCode(LogicalKeyboardKey.f1), equals(11));
        expect(KittyKeyCodes.getKeyCode(LogicalKeyboardKey.enter), equals(28));
        expect(KittyKeyCodes.getKeyCode(LogicalKeyboardKey.tab), equals(29));
      });

      test('getKeyCode returns null for unmapped keys', () {
        expect(KittyKeyCodes.getKeyCode(LogicalKeyboardKey.keyA), isNull);
      });
    });
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/kitty_encoder_test.dart`
Expected: FAIL - "The getter 'KittyKeyCodes' isn't defined"

**Step 3: Write minimal implementation**

```dart
import 'package:flutter/services.dart';

/// Key codes per Kitty Keyboard Protocol spec
class KittyKeyCodes {
  // Function keys
  static const int f1 = 11;
  static const int f2 = 12;
  static const int f3 = 13;
  static const int f4 = 14;
  static const int f5 = 15;
  static const int f6 = 17;
  static const int f7 = 18;
  static const int f8 = 19;
  static const int f9 = 20;
  static const int f10 = 21;
  static const int f11 = 23;
  static const int f12 = 24;

  // Navigation keys
  static const int arrowUp = 30;
  static const int arrowDown = 31;
  static const int arrowRight = 32;
  static const int arrowLeft = 33;
  static const int pageDown = 34;
  static const int pageUp = 35;
  static const int home = 36;
  static const int end = 37;
  static const int insert = 38;

  // Special keys
  static const int enter = 28;
  static const int backspace = 27;
  static const int tab = 29;
  static const int escape = 53;
  static const int space = 44;
  static const int delete = 127;

  // Action keys
  static const int pause = 43;
  static const int printScreen = 45;

  /// Map Flutter LogicalKeyboardKey to Kitty key code
  static int? getKeyCode(LogicalKeyboardKey key) {
    return _keyMap[key];
  }

  static final Map<LogicalKeyboardKey, int> _keyMap = {
    LogicalKeyboardKey.f1: f1,
    LogicalKeyboardKey.f2: f2,
    LogicalKeyboardKey.f3: f3,
    LogicalKeyboardKey.f4: f4,
    LogicalKeyboardKey.f5: f5,
    LogicalKeyboardKey.f6: f6,
    LogicalKeyboardKey.f7: f7,
    LogicalKeyboardKey.f8: f8,
    LogicalKeyboardKey.f9: f9,
    LogicalKeyboardKey.f10: f10,
    LogicalKeyboardKey.f11: f11,
    LogicalKeyboardKey.f12: f12,
    LogicalKeyboardKey.arrowUp: arrowUp,
    LogicalKeyboardKey.arrowDown: arrowDown,
    LogicalKeyboardKey.arrowRight: arrowRight,
    LogicalKeyboardKey.arrowLeft: arrowLeft,
    LogicalKeyboardKey.pageDown: pageDown,
    LogicalKeyboardKey.pageUp: pageUp,
    LogicalKeyboardKey.home: home,
    LogicalKeyboardKey.end: end,
    LogicalKeyboardKey.insert: insert,
    LogicalKeyboardKey.enter: enter,
    LogicalKeyboardKey.backspace: backspace,
    LogicalKeyboardKey.tab: tab,
    LogicalKeyboardKey.escape: escape,
    LogicalKeyboardKey.space: space,
    LogicalKeyboardKey.delete: delete,
    LogicalKeyboardKey.pause: pause,
    LogicalKeyboardKey.printScreen: printScreen,
  };
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/kitty_encoder_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/src/kitty_key_codes.dart test/kitty_encoder_test.dart
git commit -m "feat: add KittyKeyCodes with key mappings"
```

---

### Task 4: Implement KittyEncoderFlags

**Files:**
- Modify: `lib/src/kitty_flags.dart`
- Test: `test/kitty_encoder_test.dart` (add flags tests)

**Step 1: Write the failing test**

```dart
    group('KittyEncoderFlags', () {
      test('default flags are all false', () {
        const flags = KittyEncoderFlags();
        expect(flags.reportEvent, isFalse);
        expect(flags.reportAlternateKeys, isFalse);
        expect(flags.reportAllKeysAsEscape, isFalse);
      });

      test('toCSIValue returns 0 for default flags', () {
        const flags = KittyEncoderFlags();
        expect(flags.toCSIValue(), equals(0));
      });

      test('toCSIValue returns 1 for reportEvent', () {
        const flags = KittyEncoderFlags(reportEvent: true);
        expect(flags.toCSIValue(), equals(1));
      });

      test('toCSIValue returns 2 for reportAlternateKeys', () {
        const flags = KittyEncoderFlags(reportAlternateKeys: true);
        expect(flags.toCSIValue(), equals(2));
      });

      test('toCSIValue returns 4 for reportAllKeysAsEscape', () {
        const flags = KittyEncoderFlags(reportAllKeysAsEscape: true);
        expect(flags.toCSIValue(), equals(4));
      });

      test('toCSIValue combines flags correctly', () {
        const flags = KittyEncoderFlags(
          reportEvent: true,
          reportAlternateKeys: true,
        );
        expect(flags.toCSIValue(), equals(3)); // 1 + 2
      });

      test('isExtendedMode returns true when any flag is set', () {
        const flags = KittyEncoderFlags(reportEvent: true);
        expect(flags.isExtendedMode, isTrue);
      });

      test('isExtendedMode returns false for default', () {
        const flags = KittyEncoderFlags();
        expect(flags.isExtendedMode, isFalse);
      });
    });
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/kitty_encoder_test.dart`
Expected: FAIL - "The getter 'KittyEncoderFlags' isn't defined"

**Step 3: Write minimal implementation**

```dart
/// Progressive enhancement flags for Kitty Keyboard Protocol
class KittyEncoderFlags {
  final bool reportEvent;
  final bool reportAlternateKeys;
  final bool reportAllKeysAsEscape;

  const KittyEncoderFlags({
    this.reportEvent = false,
    this.reportAlternateKeys = false,
    this.reportAllKeysAsEscape = false,
  });

  /// Convert flags to CSI > value
  int toCSIValue() {
    int value = 0;
    if (reportEvent) value |= 1;
    if (reportAlternateKeys) value |= 2;
    if (reportAllKeysAsEscape) value |= 4;
    return value;
  }

  /// Check if extended mode is active
  bool get isExtendedMode => toCSIValue() != 0;
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/kitty_encoder_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/src/kitty_flags.dart test/kitty_encoder_test.dart
git commit -m "feat: add KittyEncoderFlags with progressive enhancement support"
```

---

### Task 5: Implement KittyEncoder Main Class

**Files:**
- Modify: `lib/src/kitty_encoder.dart`
- Test: `test/kitty_encoder_test.dart` (add encoder tests for key combinations)

**Step 1: Write the failing test**

```dart
    group('KittyEncoder', () {
      test('encode simple key produces correct sequence', () {
        const encoder = KittyEncoder();
        final event = KeyEvent(
          logicalKey: LogicalKeyboardKey.enter,
          modifiers: {},
        );
        final result = encoder.encode(event);
        expect(result, equals('\x1b[28;1u'));
      });

      test('encode Ctrl+Enter produces correct sequence', () {
        const encoder = KittyEncoder();
        final event = KeyEvent(
          logicalKey: LogicalKeyboardKey.enter,
          modifiers: {KeyModifier.control},
        );
        final result = encoder.encode(event);
        expect(result, equals('\x1b[13;5u'));
      });

      test('encode Shift+Tab produces correct sequence', () {
        const encoder = KittyEncoder();
        final event = KeyEvent(
          logicalKey: LogicalKeyboardKey.tab,
          modifiers: {KeyModifier.shift},
        );
        final result = encoder.encode(event);
        expect(result, equals('\x1b[9;2u'));
      });

      test('encode F1 produces correct sequence', () {
        const encoder = KittyEncoder();
        final event = KeyEvent(
          logicalKey: LogicalKeyboardKey.f1,
          modifiers: {},
        );
        final result = encoder.encode(event);
        expect(result, equals('\x1b[11;1u'));
      });

      test('encode with extended mode uses CSI > format', () {
        const encoder = KittyEncoder(
          flags: KittyEncoderFlags(reportEvent: true),
        );
        final event = KeyEvent(
          logicalKey: LogicalKeyboardKey.enter,
          modifiers: {},
        );
        final result = encoder.encode(event);
        expect(result, startsWith('\x1b[>'));
      });
    });
```

**Step 2: Run test to verify it fails**

Run: `flutter test test/kitty_encoder_test.dart`
Expected: FAIL - "The getter 'KittyEncoder' isn't defined"

**Step 3: Write minimal implementation**

```dart
import 'package:flutter/services.dart';
import 'kitty_key_codes.dart';
import 'kitty_modifier_codes.dart';
import 'kitty_flags.dart';

class KittyEncoder {
  final KittyEncoderFlags flags;

  const KittyEncoder({this.flags = const KittyEncoderFlags()});

  bool get isExtendedMode => flags.isExtendedMode;

  String encode(KeyEvent event) {
    final keyCode = KittyKeyCodes.getKeyCode(event.logicalKey);
    if (keyCode == null) {
      return '';
    }

    final modifierFlags = _extractModifiers(event);
    final modifiers = KittyModifierCodes.calculateModifiers(modifierFlags);

    if (flags.isExtendedMode) {
      final csiValue = flags.toCSIValue();
      return '\x1b[>$csiValue;$keyCode;${modifiers}u';
    }

    return '\x1b[$keyCode;${modifiers}u';
  }

  int _extractModifiers(KeyEvent event) {
    int flags = 0;

    if (event.modifiers.contains(KeyModifier.shift) ||
        event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      flags |= KittyModifierCodes.shift;
    }

    if (event.modifiers.contains(KeyModifier.alt) ||
        event.logicalKey == LogicalKeyboardKey.altLeft ||
        event.logicalKey == LogicalKeyboardKey.altRight) {
      flags |= KittyModifierCodes.alt;
    }

    if (event.modifiers.contains(KeyModifier.control) ||
        event.logicalKey == LogicalKeyboardKey.controlLeft ||
        event.logicalKey == LogicalKeyboardKey.controlRight) {
      flags |= KittyModifierCodes.ctrl;
    }

    if (event.modifiers.contains(KeyModifier.meta) ||
        event.logicalKey == LogicalKeyboardKey.metaLeft ||
        event.logicalKey == LogicalKeyboardKey.metaRight) {
      flags |= KittyModifierCodes.superKey;
    }

    return flags;
  }

  KittyEncoder withFlags(KittyEncoderFlags newFlags) {
    return KittyEncoder(flags: newFlags);
  }
}
```

**Step 4: Run test to verify it passes**

Run: `flutter test test/kitty_encoder_test.dart`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/src/kitty_encoder.dart test/kitty_encoder_test.dart
git commit -m "feat: add KittyEncoder main class with encoding logic"
```

---

### Task 6: Add Comprehensive Key Mapping Tests

**Files:**
- Test: `test/kitty_encoder_test.dart`

**Step 1: Add test for all functional keys F1-F12**

```dart
      test('encode F2-F12 produce correct sequences', () {
        const encoder = KittyEncoder();
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f2, modifiers: {})), equals('\x1b[12;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f3, modifiers: {})), equals('\x1b[13;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f4, modifiers: {})), equals('\x1b[14;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f5, modifiers: {})), equals('\x1b[15;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f6, modifiers: {})), equals('\x1b[17;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f7, modifiers: {})), equals('\x1b[18;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f8, modifiers: {})), equals('\x1b[19;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f9, modifiers: {})), equals('\x1b[20;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f10, modifiers: {})), equals('\x1b[21;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f11, modifiers: {})), equals('\x1b[23;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.f12, modifiers: {})), equals('\x1b[24;1u'));
      });

      test('encode arrow keys produce correct sequences', () {
        const encoder = KittyEncoder();
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.arrowUp, modifiers: {})), equals('\x1b[30;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.arrowDown, modifiers: {})), equals('\x1b[31;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.arrowRight, modifiers: {})), equals('\x1b[32;1u'));
        expect(encoder.encode(KeyEvent(logicalKey: LogicalKeyboardKey.arrowLeft, modifiers: {})), equals('\x1b[33;1u'));
      });
```

**Step 2: Add test for modifier combinations**

```dart
      test('encode Ctrl+Shift+Enter produces correct sequence', () {
        const encoder = KittyEncoder();
        final event = KeyEvent(
          logicalKey: LogicalKeyboardKey.enter,
          modifiers: {KeyModifier.control, KeyModifier.shift},
        );
        final result = encoder.encode(event);
        expect(result, equals('\x1b[13;6u'));
      });

      test('encode Alt+F4 produces correct sequence', () {
        const encoder = KittyEncoder();
        final event = KeyEvent(
          logicalKey: LogicalKeyboardKey.f4,
          modifiers: {KeyModifier.alt},
        );
        final result = encoder.encode(event);
        expect(result, equals('\x1b[14;3u'));
      });
```

**Step 3: Run tests to verify they pass**

Run: `flutter test test/kitty_encoder_test.dart`
Expected: PASS

**Step 4: Commit**

```bash
git add test/kitty_encoder_test.dart
git commit -m "test: add comprehensive key mapping and modifier tests"
```

---

### Task 7: Finalize and Export

**Files:**
- Modify: `lib/kitty_key_encoder.dart`

**Step 1: Update main export file**

```dart
library kitty_key_encoder;

export 'src/kitty_encoder.dart';
export 'src/kitty_flags.dart';
export 'src/kitty_key_codes.dart';
export 'src/kitty_modifier_codes.dart';
```

**Step 2: Run all tests**

Run: `flutter test`
Expected: All tests PASS

**Step 3: Commit**

```bash
git add lib/kitty_key_encoder.dart
git commit -m "chore: finalize exports and complete package"
```

---

## Summary

This plan creates a complete Flutter package with:
- `KittyModifierCodes` - bit flag constants and calculation
- `KittyKeyCodes` - key code mappings from LogicalKeyboardKey
- `KittyEncoderFlags` - progressive enhancement configuration
- `KittyEncoder` - main encoder class

All tests follow TDD with tests written before implementation.
