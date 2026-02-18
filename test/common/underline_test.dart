/// Styled Underlines Protocol Tests
///
/// Tests for Kitty Underline encoder
///
/// Reference: doc/kitty/docs/underlines.rst
library kitty_protocol_underline_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  group('KittyUnderline - Basic Styles', () {
    test('none generates correct sequence', () {
      final result = KittyUnderline.none.buildString();
      expect(result, contains('\x1b[24m'));
    });

    test('straight generates correct sequence', () {
      final result = KittyUnderline.straight.buildString();
      expect(result, contains('\x1b[4:1m'));
    });

    test('double_ generates correct sequence', () {
      final result = KittyUnderline.double_.buildString();
      expect(result, contains('\x1b[4:2m'));
    });

    test('curly generates correct sequence', () {
      final result = KittyUnderline.curly.buildString();
      expect(result, contains('\x1b[4:3m'));
    });

    test('dotted generates correct sequence', () {
      final result = KittyUnderline.dotted.buildString();
      expect(result, contains('\x1b[4:4m'));
    });

    test('dashed generates correct sequence', () {
      final result = KittyUnderline.dashed.buildString();
      expect(result, contains('\x1b[4:5m'));
    });
  });

  group('KittyUnderline - Factory Constructor', () {
    test('style factory creates correct style', () {
      final underline = KittyUnderline.style(KittyUnderlineStyle.curly);
      final result = underline.buildString();
      expect(result, contains('\x1b[4:3m'));
    });
  });

  group('KittyUnderline - Color', () {
    test('withColor adds true color', () {
      final underline = KittyUnderline.straight.withColor(255, 0, 0);
      final result = underline.buildString();
      expect(result, contains('\x1b[58:2:255:0:0m'));
    });

    test('withColor256 adds 256 color', () {
      final underline = KittyUnderline.straight.withColor256(196);
      final result = underline.buildString();
      expect(result, contains('\x1b[58:5:196m'));
    });

    test('resetColor adds reset sequence', () {
      final underline = KittyUnderline.straight.resetColor();
      final result = underline.buildString();
      expect(result, contains('\x1b[59m'));
    });
  });

  group('KittyUnderline - Build Methods', () {
    test('build returns list of sequences', () {
      final underline = KittyUnderline.curly.withColor(0, 255, 0);
      final result = underline.build();
      expect(result, isA<List<String>>());
      expect(result.length, 2);
    });

    test('buildString returns concatenated string', () {
      final underline = KittyUnderline.curly;
      final result = underline.buildString();
      expect(result, isA<String>());
      expect(result, contains('\x1b[4:3m'));
    });
  });

  group('KittyUnderline - Predefined Colors', () {
    test('redCurly has correct color', () {
      final result = KittyUnderlines.redCurly.buildString();
      expect(result, contains('\x1b[4:3m'));
      expect(result, contains('\x1b[58:2:255:0:0m'));
    });

    test('yellowCurly has correct color', () {
      final result = KittyUnderlines.yellowCurly.buildString();
      expect(result, contains('\x1b[58:2:255:255:0m'));
    });

    test('greenCurly has correct color', () {
      final result = KittyUnderlines.greenCurly.buildString();
      expect(result, contains('\x1b[58:2:0:255:0m'));
    });

    test('blueCurly has correct color', () {
      final result = KittyUnderlines.blueCurly.buildString();
      expect(result, contains('\x1b[58:2:0:0:255m'));
    });
  });

  group('KittyUnderline - Shortcut Accessors', () {
    test('KittyUnderlines constants match KittyUnderline', () {
      expect(KittyUnderlines.none.buildString(), KittyUnderline.none.buildString());
      expect(KittyUnderlines.straight.buildString(), KittyUnderline.straight.buildString());
      expect(KittyUnderlines.double_.buildString(), KittyUnderline.double_.buildString());
    });
  });

  group('KittyUnderlineStyle - Enum Values', () {
    test('style values are correct', () {
      expect(KittyUnderlineStyle.none.value, 0);
      expect(KittyUnderlineStyle.straight.value, 1);
      expect(KittyUnderlineStyle.double_.value, 2);
      expect(KittyUnderlineStyle.curly.value, 3);
      expect(KittyUnderlineStyle.dotted.value, 4);
      expect(KittyUnderlineStyle.dashed.value, 5);
    });
  });

  group('KittyUnderlineColorMode - Enum Values', () {
    test('color mode values are correct', () {
      expect(KittyUnderlineColorMode.color256.value, 5);
      expect(KittyUnderlineColorMode.trueColor.value, 2);
    });
  });
}
