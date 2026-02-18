/// Text Sizing Protocol Tests
///
/// Tests for Kitty Text Sizing encoder
///
/// Reference: doc/kitty/docs/text-sizing-protocol.rst
library kitty_protocol_text_sizing_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  const encoder = KittyTextSizingEncoder();

  group('KittyTextSizingEncoder - Scale Encoding', () {
    test('encodeDoubleSize generates correct sequence', () {
      final result = encoder.encodeDoubleSize('Test');
      expect(result, contains('\x1b]_text_size_code;'));
      expect(result, contains('s=2'));
      expect(result, contains('Test'));
      expect(result, contains('\x07'));
    });

    test('encodeTripleSize generates correct sequence', () {
      final result = encoder.encodeTripleSize('Test');
      expect(result, contains('s=3'));
    });

    test('encodeHalfSize generates correct sequence', () {
      final result = encoder.encodeHalfSize('Test');
      expect(result, contains('n=1'));
      expect(result, contains('d=2'));
    });

    test('encodeSuperscript generates correct sequence', () {
      final result = encoder.encodeSuperscript('Test');
      expect(result, contains('n=1'));
      expect(result, contains('d=2'));
      expect(result, contains('v=1')); // bottom alignment
    });

    test('encodeSubscript generates correct sequence', () {
      final result = encoder.encodeSubscript('Test');
      expect(result, contains('n=1'));
      expect(result, contains('d=2'));
      expect(result, contains('v=0')); // top alignment
    });
  });

  group('KittyTextSizingEncoder - General Encoding', () {
    test('encode with scale parameter', () {
      final result = encoder.encode(text: 'Test', scale: 4);
      expect(result, contains('s=4'));
    });

    test('encode with width parameter', () {
      final result = encoder.encode(text: 'Test', width: 5);
      expect(result, contains('w=5'));
    });

    test('encode with numerator and denominator', () {
      final result = encoder.encode(text: 'Test', numerator: 3, denominator: 4);
      expect(result, contains('n=3'));
      expect(result, contains('d=4'));
    });

    test('encode with vertical alignment', () {
      final result = encoder.encode(
        text: 'Test',
        verticalAlignment: KittyVerticalAlignment.centered,
      );
      expect(result, contains('v=2'));
    });

    test('encode with horizontal alignment', () {
      final result = encoder.encode(
        text: 'Test',
        horizontalAlignment: KittyHorizontalAlignment.right,
      );
      expect(result, contains('h=1'));
    });

    test('encode with BEL terminator', () {
      final result = encoder.encode(text: 'Test', useBelTerminator: true);
      expect(result, contains('\x07'));
    });

    test('encode with ESC ST terminator', () {
      final result = encoder.encode(text: 'Test', useBelTerminator: false);
      expect(result, contains('\x1b\\'));
    });
  });

  group('KittyTextSizingEncoder - Width Helpers', () {
    test('encodeWithWidth generates correct sequence', () {
      final result = encoder.encodeWithWidth('Test', 10);
      expect(result, contains('w=10'));
    });

    test('chunkByWidth splits text correctly', () {
      final chunks = encoder.chunkByWidth('hello world test', 5);
      expect(chunks.length, greaterThan(1));
    });
  });

  group('KittyTextSizingEncoder - Constants', () {
    test('textSizeCode is correct', () {
      expect(KittyTextSizingEncoder.textSizeCode, '_text_size_code');
    });

    test('maxTextLength is defined', () {
      expect(KittyTextSizingEncoder.maxTextLength, 4096);
    });
  });

  group('KittyTextScale - Scale Values', () {
    test('scale constants are correct', () {
      expect(KittyTextScale.scale1, 1);
      expect(KittyTextScale.scale2, 2);
      expect(KittyTextScale.scale3, 3);
      expect(KittyTextScale.scale4, 4);
      expect(KittyTextScale.scale5, 5);
      expect(KittyTextScale.scale6, 6);
      expect(KittyTextScale.scale7, 7);
    });
  });

  group('KittyVerticalAlignment - Enum Values', () {
    test('alignment values are correct', () {
      expect(KittyVerticalAlignment.top.value, 0);
      expect(KittyVerticalAlignment.bottom.value, 1);
      expect(KittyVerticalAlignment.centered.value, 2);
    });
  });

  group('KittyHorizontalAlignment - Enum Values', () {
    test('alignment values are correct', () {
      expect(KittyHorizontalAlignment.left.value, 0);
      expect(KittyHorizontalAlignment.right.value, 1);
      expect(KittyHorizontalAlignment.centered.value, 2);
    });
  });
}
