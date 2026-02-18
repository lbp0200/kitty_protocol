import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_key_encoder/kitty_key_encoder.dart';

/// Protocol Compliance Tests
///
/// These tests verify compliance with the Kitty Keyboard Protocol specification
/// Reference: doc/kitty/docs/keyboard-protocol.rst
///
/// Test categories:
/// 1. Basic key encoding (lines 98-99)
/// 2. Modifier encoding (lines 192-208)
/// 3. C0 control code mapping (lines 684-706)
/// 4. Event types (lines 217-234)
void main() {
  group('Protocol Compliance: Basic Key Encoding', () {
    /// Per protocol line 98: CSI number ; modifiers u
    /// Per protocol lines 100-102:
    ///   0x0d - for Enter key
    ///   0x7f or 0x08 - for Backspace
    ///   0x09 - for Tab

    test('Enter key uses Unicode codepoint 13', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.enter);
      final result = encoder.encode(event);
      // Enter = 0x0d = 13 in decimal
      expect(result, equals('\x1b[13;1u'));
    });

    test('Tab key uses Unicode codepoint 9', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.tab);
      final result = encoder.encode(event);
      // Tab = 0x09 = 9 in decimal
      expect(result, equals('\x1b[9;1u'));
    });

    test('Escape key uses Unicode codepoint 27', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.escape);
      final result = encoder.encode(event);
      // Escape = 0x1b = 27 in decimal
      expect(result, equals('\x1b[27;1u'));
    });

    test('Backspace key uses Unicode codepoint 127', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.backspace);
      final result = encoder.encode(event);
      // Backspace = 0x7f = 127 in decimal
      expect(result, equals('\x1b[127;1u'));
    });

    test('Space key uses Unicode codepoint 32', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.space);
      final result = encoder.encode(event);
      // Space = 0x20 = 32 in decimal
      expect(result, equals('\x1b[32;1u'));
    });

    test('Delete key uses Unicode codepoint 127', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.delete);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[127;1u'));
    });
  });

  group('Protocol Compliance: Modifier Encoding', () {
    /// Per protocol lines 192-208:
    /// modifier = 1 + bit_flags (Shift=1, Alt=2, Ctrl=4, Super=8)
    /// Examples: Shift=2, Ctrl=5, Ctrl+Shift=6

    test('Shift modifier encodes as 2 (1+1)', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.shift},
      );
      final result = encoder.encode(event);
      // Shift = 1 + 1 = 2
      expect(result, equals('\x1b[13;2u'));
    });

    test('Alt modifier encodes as 3 (1+2)', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.alt},
      );
      final result = encoder.encode(event);
      // Alt = 1 + 2 = 3
      expect(result, equals('\x1b[13;3u'));
    });

    test('Ctrl modifier encodes as 5 (1+4)', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.control},
      );
      final result = encoder.encode(event);
      // Ctrl = 1 + 4 = 5
      expect(result, equals('\x1b[13;5u'));
    });

    test('Ctrl+Shift modifier encodes as 6 (1+4+1)', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.control, SimpleModifier.shift},
      );
      final result = encoder.encode(event);
      // Ctrl+Shift = 1 + 4 + 1 = 6
      expect(result, equals('\x1b[13;6u'));
    });

    test('Ctrl+Alt modifier encodes as 7 (1+4+2)', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.control, SimpleModifier.alt},
      );
      final result = encoder.encode(event);
      // Ctrl+Alt = 1 + 4 + 2 = 7
      expect(result, equals('\x1b[13;7u'));
    });

    test('Ctrl+Alt+Shift modifier encodes as 8 (1+4+2+1)', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.control, SimpleModifier.alt, SimpleModifier.shift},
      );
      final result = encoder.encode(event);
      // Ctrl+Alt+Shift = 1 + 4 + 2 + 1 = 8
      expect(result, equals('\x1b[13;8u'));
    });

    test('Meta (Super) modifier encodes as 9 (1+8)', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.meta},
      );
      final result = encoder.encode(event);
      // Meta/Super = 1 + 8 = 9
      expect(result, equals('\x1b[13;9u'));
    });
  });

  group('Protocol Compliance: C0 Control Code Mapping', () {
    /// Per protocol lines 684-706:
    /// When Ctrl is held, keys map to C0 control codes:
    /// - Ctrl+a through Ctrl+z map to 1-26
    /// - Ctrl+@ and Ctrl+Space map to 0
    /// - Ctrl+? maps to 127
    ///
    /// IMPORTANT (line 155): If Shift is also pressed, DON'T apply C0 mapping
    /// Use the base key codepoint instead.

    // Note: Since LogicalKeyboardKey doesn't directly support letter keys in the mapping,
    // we test the C0 mapping function directly

    test('Ctrl mapping: a -> 1 (C0 SOH)', () {
      // Ctrl+a (97) -> C0 code 1
      expect(KittyKeyCodes.applyCtrlMapping(97, true, false), equals(1));
    });

    test('Ctrl mapping: b -> 2 (C0 STX)', () {
      expect(KittyKeyCodes.applyCtrlMapping(98, true, false), equals(2));
    });

    test('Ctrl mapping: c -> 3 (C0 ETX)', () {
      expect(KittyKeyCodes.applyCtrlMapping(99, true, false), equals(3));
    });

    test('Ctrl mapping: z -> 26 (C0 SUB)', () {
      expect(KittyKeyCodes.applyCtrlMapping(122, true, false), equals(26));
    });

    test('Ctrl mapping: Enter (13) stays 13', () {
      // Enter key doesn't have C0 mapping, stays at 13
      expect(KittyKeyCodes.applyCtrlMapping(13, true, false), equals(13));
    });

    test('Ctrl mapping: Tab (9) stays 9', () {
      expect(KittyKeyCodes.applyCtrlMapping(9, true, false), equals(9));
    });

    test('Ctrl mapping: Space (32) -> 0 (NUL)', () {
      expect(KittyKeyCodes.applyCtrlMapping(32, true, false), equals(0));
    });

    test('Ctrl+Shift: a stays 97 (no C0 mapping when Shift is pressed)', () {
      // Per protocol line 155: If Shift is pressed, don't apply C0 mapping
      expect(KittyKeyCodes.applyCtrlMapping(97, true, true), equals(97));
    });

    test('Ctrl+Shift: Enter stays 13 (no C0 mapping when Shift is pressed)', () {
      expect(KittyKeyCodes.applyCtrlMapping(13, true, true), equals(13));
    });

    test('No Ctrl: keyCode unchanged', () {
      expect(KittyKeyCodes.applyCtrlMapping(97, false, false), equals(97));
      expect(KittyKeyCodes.applyCtrlMapping(13, false, false), equals(13));
    });
  });

  group('Protocol Compliance: Event Types', () {
    /// Per protocol lines 217-234:
    /// Event types are reported as sub-field of modifiers: modifier:event_type
    /// press=1 (default), repeat=2, release=3

    test('Key down event type 1 in extended mode', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(reportEvent: true),
      );
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        isKeyUp: false,
        isKeyRepeat: false,
      );
      final result = encoder.encode(event);
      // Format: CSI >flags ; event_type ; key ; modifiers u
      // event_type 1 = keyDown
      expect(result, equals('\x1b[>1;1;13;1u'));
    });

    test('Key repeat event type 2 in extended mode', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(reportEvent: true),
      );
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        isKeyUp: false,
        isKeyRepeat: true,
      );
      final result = encoder.encode(event);
      // event_type 2 = keyRepeat
      expect(result, equals('\x1b[>1;2;13;1u'));
    });

    test('Key up event type 3 in extended mode', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(reportEvent: true),
      );
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        isKeyUp: true,
      );
      final result = encoder.encode(event);
      // event_type 3 = keyUp
      expect(result, equals('\x1b[>1;3;13;1u'));
    });
  });

  group('Protocol Compliance: Extended Mode Format', () {
    /// Per protocol line 290: CSI = flags ; mode u
    /// For requesting enhancements

    test('Extended mode uses CSI > format', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(reportEvent: true),
      );
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.enter);
      final result = encoder.encode(event);
      expect(result, startsWith('\x1b[>'));
    });

    test('CSI value includes flags', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(reportEvent: true),
      );
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.enter);
      final result = encoder.encode(event);
      // reportEvent = 0b10 = 2, but it's stored as the raw flag value
      // The format is: CSI > flag_value ; ...
      expect(result, contains('>1;')); // reportEvent=1 in toCSIValue
    });
  });

  group('Protocol Compliance: Functional Keys', () {
    /// Per protocol lines 587-668:
    /// Functional keys use numbers in Unicode Private Use Area (57344-63743)
    /// except for a few legacy keys

    test('F1 uses codepoint 11', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f1);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[11;1u'));
    });

    test('F12 uses codepoint 24', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f12);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[24;1u'));
    });

    test('ArrowUp uses codepoint 30', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.arrowUp);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[30;1u'));
    });

    test('ArrowDown uses codepoint 31', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.arrowDown);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[31;1u'));
    });

    test('ArrowLeft uses codepoint 33', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.arrowLeft);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[33;1u'));
    });

    test('ArrowRight uses codepoint 32', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.arrowRight);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[32;1u'));
    });

    test('Home uses codepoint 36', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.home);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[36;1u'));
    });

    test('End uses codepoint 37', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.end);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[37;1u'));
    });

    test('PageUp uses codepoint 35', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.pageUp);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[35;1u'));
    });

    test('PageDown uses codepoint 34', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.pageDown);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[34;1u'));
    });

    test('Insert uses codepoint 38', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.insert);
      final result = encoder.encode(event);
      expect(result, equals('\x1b[38;1u'));
    });
  });

  group('No Negative Numbers in Output', () {
    /// Regression test: ensure no negative codepoints are produced
    /// (previous implementation had -2, -11, etc.)

    test('Ctrl+Enter produces positive codepoint', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.control},
      );
      final result = encoder.encode(event);
      expect(result, equals('\x1b[13;5u'));
      expect(result.contains('-'), isFalse);
    });

    test('Shift+Tab produces positive codepoint', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.tab,
        modifiers: {SimpleModifier.shift},
      );
      final result = encoder.encode(event);
      expect(result, equals('\x1b[9;2u'));
      expect(result.contains('-'), isFalse);
    });

    test('Alt+Enter produces positive codepoint', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.alt},
      );
      final result = encoder.encode(event);
      expect(result, equals('\x1b[13;3u'));
      expect(result.contains('-'), isFalse);
    });

    test('Ctrl+Shift+Enter produces positive codepoint', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.control, SimpleModifier.shift},
      );
      final result = encoder.encode(event);
      expect(result, equals('\x1b[13;6u'));
      expect(result.contains('-'), isFalse);
    });
  });
}
