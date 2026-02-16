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
}
