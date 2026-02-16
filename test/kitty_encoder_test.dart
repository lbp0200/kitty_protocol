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

  group('KittyEncoder', () {
    test('encode simple key produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
      );
      final result = encoder.encode(event);
      expect(result, equals('\x1b[28;1u'));
    });

    test('encode Ctrl+Enter produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.enter,
        modifiers: {SimpleModifier.control},
      );
      final result = encoder.encode(event);
      expect(result, equals('\x1b[13;5u'));
    });

    test('encode Shift+Tab produces correct sequence', () {
      const encoder = KittyEncoder();
      const event = SimpleKeyEvent(
        logicalKey: LogicalKeyboardKey.tab,
        modifiers: {SimpleModifier.shift},
      );
      final result = encoder.encode(event);
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
  });
}
