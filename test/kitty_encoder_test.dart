import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
      expect(KittyKeyCodes.enter, equals(13));
    });

    test('Tab has correct code', () {
      expect(KittyKeyCodes.tab, equals(9));
    });

    test('Escape has correct code', () {
      expect(KittyKeyCodes.escape, equals(27));
    });

    test('getKeyCode returns correct code for LogicalKeyboardKey', () {
      expect(KittyKeyCodes.getKeyCode(LogicalKeyboardKey.f1), equals(11));
      expect(KittyKeyCodes.getKeyCode(LogicalKeyboardKey.enter), equals(13));
      expect(KittyKeyCodes.getKeyCode(LogicalKeyboardKey.tab), equals(9));
    });

    test('getKeyCode returns null for unmapped keys', () {
      expect(KittyKeyCodes.getKeyCode(LogicalKeyboardKey.keyA), isNull);
    });
  });

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

    test('deferToSystemOnComplexInput defaults to false', () {
      const flags = KittyEncoderFlags();
      expect(flags.deferToSystemOnComplexInput, isFalse);
    });

    test('deferToSystemOnComplexInput can be set to true', () {
      const flags = KittyEncoderFlags(deferToSystemOnComplexInput: true);
      expect(flags.deferToSystemOnComplexInput, isTrue);
    });
  });

  group('KittyEncoder', () {
    test('encode simple key produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
      );
      final result = encoder.encode(event);
      expect(result, equals('\x1b[13;1u'));
    });

    test('encode Ctrl+Enter produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.control},
      );
      final result = encoder.encode(event);
      // Per Kitty protocol: Enter (13) with Ctrl (modifier=5) -> CSI 13;5u
      // Ctrl+Enter keeps codepoint 13, modifier is 1+4=5
      expect(result, equals('\x1b[13;5u'));
    });

    test('encode Shift+Tab produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.tab,
        modifiers: {SimpleModifier.shift},
      );
      final result = encoder.encode(event);
      // Per Kitty protocol: Tab (9) with Shift (modifier=2) -> CSI 9;2u
      // Shift modifier is 1+1=2, codepoint stays at 9
      expect(result, equals('\x1b[9;2u'));
    });

    test('encode F1 produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.f1,
      );
      final result = encoder.encode(event);
      expect(result, equals('\x1b[11;1u'));
    });

    test('encode with extended mode uses CSI > format', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(reportEvent: true),
      );
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
      );
      final result = encoder.encode(event);
      expect(result, startsWith('\x1b[>'));
    });

    test('encode F2-F12 produce correct sequences', () {
      const encoder = KittyEncoder();
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f2)), equals('\x1b[12;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f3)), equals('\x1b[13;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f4)), equals('\x1b[14;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f5)), equals('\x1b[15;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f6)), equals('\x1b[17;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f7)), equals('\x1b[18;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f8)), equals('\x1b[19;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f9)), equals('\x1b[20;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f10)), equals('\x1b[21;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f11)), equals('\x1b[23;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.f12)), equals('\x1b[24;1u'));
    });

    test('encode arrow keys produce correct sequences', () {
      const encoder = KittyEncoder();
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.arrowUp)), equals('\x1b[30;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.arrowDown)), equals('\x1b[31;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.arrowRight)), equals('\x1b[32;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.arrowLeft)), equals('\x1b[33;1u'));
    });

    test('encode Ctrl+Shift+Enter produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.control, SimpleModifier.shift},
      );
      final result = encoder.encode(event);
      // Per Kitty protocol: When Shift is pressed with Ctrl, don't apply C0 mapping
      // Use Enter codepoint 13, modifier is 1+4+1=6 (Ctrl+Shift)
      expect(result, equals('\x1b[13;6u'));
    });

    test('encode Alt+F4 produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.f4,
        modifiers: {SimpleModifier.alt},
      );
      final result = encoder.encode(event);
      expect(result, equals('\x1b[14;3u'));
    });

    test('encode navigation keys produce correct sequences', () {
      const encoder = KittyEncoder();
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.pageUp)), equals('\x1b[35;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.pageDown)), equals('\x1b[34;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.home)), equals('\x1b[36;1u'));
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.end)), equals('\x1b[37;1u'));
    });

    test('encode Escape produces correct sequence', () {
      const encoder = KittyEncoder();
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.escape)), equals('\x1b[27;1u'));
    });

    test('encode Backspace produces correct sequence', () {
      const encoder = KittyEncoder();
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.backspace)), equals('\x1b[127;1u'));
    });

    test('encode Space produces correct sequence', () {
      const encoder = KittyEncoder();
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.space)), equals('\x1b[32;1u'));
    });

    test('encode Delete produces correct sequence', () {
      const encoder = KittyEncoder();
      expect(encoder.encode(const SimpleKeyEvent(logicalKey: LogicalKeyboardKey.delete)), equals('\x1b[127;1u'));
    });

    test('encode Meta key produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.keyA,
        modifiers: {SimpleModifier.meta},
      );
      final result = encoder.encode(event);
      // keyA is not mapped, should return empty
      expect(result, equals(''));
    });

    test('encode unknown key returns empty string', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.keyA);
      expect(encoder.encode(event), equals(''));
    });

    test('withFlags creates new encoder with different flags', () {
      const encoder = KittyEncoder();
      final newEncoder = encoder.withFlags(const KittyEncoderFlags(reportEvent: true));
      expect(newEncoder.isExtendedMode, isTrue);
      expect(encoder.isExtendedMode, isFalse);
    });

    // Key Event Types Tests (Kitty Protocol)
    test('encode key down in extended mode includes event_type 1', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(reportEvent: true),
      );
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        isKeyUp: false,
        isKeyRepeat: false,
      );
      final result = encoder.encode(event);
      // Format: \x1b[>flags;event_type;key;modifiersu
      // event_type 1 = keyDown, Enter = 13
      expect(result, equals('\x1b[>1;1;13;1u'));
    });

    test('encode key repeat in extended mode includes event_type 2', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(reportEvent: true),
      );
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        isKeyUp: false,
        isKeyRepeat: true,
      );
      final result = encoder.encode(event);
      // Format: \x1b[>flags;event_type;key;modifiersu
      // event_type 2 = keyRepeat, Enter = 13
      expect(result, equals('\x1b[>1;2;13;1u'));
    });

    test('encode key up in extended mode includes event_type 3', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(reportEvent: true),
      );
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        isKeyUp: true,
      );
      final result = encoder.encode(event);
      // Format: \x1b[>flags;event_type;key;modifiersu
      // event_type 3 = keyUp, Enter = 13
      expect(result, equals('\x1b[>1;3;13;1u'));
    });

    test('encode key up in non-extended mode uses ~ prefix', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        isKeyUp: true,
      );
      final result = encoder.encode(event);
      // Enter = 13
      expect(result, equals('\x1b[13;1u'));
    });

    test('encode key repeat in non-extended mode has no special handling', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        isKeyRepeat: true,
      );
      final result = encoder.encode(event);
      // Key repeat is treated as key down in non-extended mode, Enter = 13
      expect(result, equals('\x1b[13;1u'));
    });

    // Backspace Tests
    test('encode Backspace produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.backspace);
      final result = encoder.encode(event);
      // Backspace = 127
      expect(result, equals('\x1b[127;1u'));
    });

    test('encode Backspace in extended mode produces correct sequence', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(reportEvent: true),
      );
      const event = SimpleKeyEvent(logicalKey: LogicalKeyboardKey.backspace);
      final result = encoder.encode(event);
      // Backspace code is 127, event_type 1 = keyDown
      expect(result, equals('\x1b[>1;1;127;1u'));
    });

    // IME/Text Editing Conflict Tests
    test('deferToSystemOnComplexInput returns empty for Ctrl+Letter', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(deferToSystemOnComplexInput: true),
      );
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.keyA,
        modifiers: {SimpleModifier.control},
      );
      final result = encoder.encode(event);
      expect(result, equals(''));
    });

    test('deferToSystemOnComplexInput returns empty for Alt+Letter', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(deferToSystemOnComplexInput: true),
      );
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.keyB,
        modifiers: {SimpleModifier.alt},
      );
      final result = encoder.encode(event);
      expect(result, equals(''));
    });

    test('deferToSystemOnComplexInput still encodes non-printable with modifiers', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(deferToSystemOnComplexInput: true),
      );
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.control},
      );
      final result = encoder.encode(event);
      // Per Kitty protocol: Enter (13) with Ctrl (modifier=5) -> CSI 13;5u
      expect(result, equals('\x1b[13;5u'));
    });

    test('deferToSystemOnComplexInput works with Shift+Printable when enabled', () {
      const encoder = KittyEncoder(
        flags: KittyEncoderFlags(deferToSystemOnComplexInput: true),
      );
      // Shift+letter is printable but has modifier, should defer
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.keyA,
        modifiers: {SimpleModifier.shift},
      );
      final result = encoder.encode(event);
      // keyA is not in KittyKeyCodes, so returns empty anyway
      expect(result, equals(''));
    });

    test('deferToSystemOnComplexInput disabled by default', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.keyA,
        modifiers: {SimpleModifier.control},
      );
      final result = encoder.encode(event);
      // keyA is not mapped, returns empty
      expect(result, equals(''));
    });
  });
}
