/// Wide Gamut Colors Protocol Tests
///
/// Tests for Kitty Wide Gamut Colors encoder (OKLCH, LAB)
///
/// Reference: doc/kitty/docs/wide-gamut-colors.rst
library kitty_protocol_wide_gamut_colors_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  group('KittyWideGamutColor - sRGB Colors', () {
    test('rgb8 generates correct format', () {
      final result = KittyWideGamutColor.rgb8(255, 0, 0);
      expect(result, '2;255;0;0');
    });

    test('fromHex parses 6-digit hex', () {
      final result = KittyWideGamutColor.fromHex('#ff0000');
      expect(result, '2;255;0;0');
    });

    test('fromHex parses 3-digit hex', () {
      final result = KittyWideGamutColor.fromHex('#f00');
      expect(result, '2;255;0;0');
    });

    test('fromHex parses 8-digit hex', () {
      final result = KittyWideGamutColor.fromHex('#ff0000ff');
      expect(result, '2;255;0;0');
    });
  });

  group('KittyWideGamutColor - OKLCH Colors', () {
    test('oklch generates correct format', () {
      final result = KittyWideGamutColor.oklch(0.9, 0.05, 140);
      expect(result, contains('4;'));
      expect(result, contains('0.900'));
      expect(result, contains('0.050'));
      expect(result, contains('140.0'));
    });

    test('oklch clamps lightness', () {
      final result = KittyWideGamutColor.oklch(1.5, 0.05, 140);
      // Should clamp to 1.0
      expect(result, contains('1.000'));
    });

    test('oklch clamps chroma', () {
      final result = KittyWideGamutColor.oklch(0.9, 0.5, 140);
      // Should clamp to 0.4
      expect(result, contains('0.400'));
    });

    test('oklch wraps hue', () {
      final result = KittyWideGamutColor.oklch(0.9, 0.05, 400);
      // Should wrap 400 to 40
      expect(result, contains('40.0'));
    });

    test('parseOklch parses string format', () {
      final result = KittyWideGamutColor.parseOklch('oklch(0.9 0.05 140)');
      expect(result, contains('4;'));
    });
  });

  group('KittyWideGamutColor - LAB Colors', () {
    test('lab generates correct format', () {
      final result = KittyWideGamutColor.lab(20, 5, -10);
      expect(result, contains('5;'));
      expect(result, contains('20.0'));
      expect(result, contains('5.0'));
      expect(result, contains('-10.0'));
    });

    test('lab clamps lightness', () {
      final result = KittyWideGamutColor.lab(150, 5, -10);
      // Should clamp to 100
      expect(result, contains('100.0'));
    });

    test('parseLab parses string format', () {
      final result = KittyWideGamutColor.parseLab('lab(20 5 -10)');
      expect(result, contains('5;'));
    });
  });

  group('KittyWideGamutColor - SGR Sequence Builder', () {
    test('foreground builds correct sequence', () {
      final result = KittyWideGamutColor.foreground('2;255;0;0');
      expect(result, '38;2;255;0;0');
    });

    test('background builds correct sequence', () {
      final result = KittyWideGamutColor.background('2;255;0;0');
      expect(result, '48;2;255;0;0');
    });
  });

  group('KittySgrWideGamut - SGR Helpers', () {
    test('foreground creates SGR sequence', () {
      final result = KittySgrWideGamut.foreground('4;0.9;0.05;140');
      expect(result, contains('\x1b['));
      expect(result, contains('38;4;'));
    });

    test('background creates SGR sequence', () {
      final result = KittySgrWideGamut.background('4;0.9;0.05;140');
      expect(result, contains('\x1b['));
      expect(result, contains('48;4;'));
    });

    test('foregroundOklch creates OKLCH foreground', () {
      final result = KittySgrWideGamut.foregroundOklch(0.9, 0.05, 140);
      expect(result, contains('\x1b[38;4;'));
    });

    test('backgroundOklch creates OKLCH background', () {
      final result = KittySgrWideGamut.backgroundOklch(0.9, 0.05, 140);
      expect(result, contains('\x1b[48;4;'));
    });

    test('foregroundLab creates LAB foreground', () {
      final result = KittySgrWideGamut.foregroundLab(20, 5, -10);
      expect(result, contains('\x1b[38;5;'));
    });

    test('backgroundLab creates LAB background', () {
      final result = KittySgrWideGamut.backgroundLab(20, 5, -10);
      expect(result, contains('\x1b[48;5;'));
    });

    test('reset creates reset sequence', () {
      final result = KittySgrWideGamut.reset();
      expect(result, '\x1b[0m');
    });
  });

  group('KittyColorSpace - Enum Values', () {
    test('enum values are defined', () {
      expect(KittyColorSpace.srgb, isNotNull);
      expect(KittyColorSpace.oklch, isNotNull);
      expect(KittyColorSpace.lab, isNotNull);
    });
  });
}
