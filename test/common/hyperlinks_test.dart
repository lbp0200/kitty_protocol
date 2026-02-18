/// Hyperlinks Protocol Tests
///
/// Tests for Kitty Hyperlinks encoder (OSC 8)
///
/// Reference: doc/kitty/docs/integrations.rst
library kitty_protocol_hyperlinks_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  group('KittyHyperlinks - Basic Operations', () {
    test('link generates correct OSC 8 sequence', () {
      final result = KittyHyperlinks.link(
        url: 'https://example.com',
        text: 'Click here',
      );
      expect(result, contains('\x1b]8;'));
      expect(result, contains('https://example.com'));
      expect(result, contains('Click here'));
      expect(result, contains('\x1b\\'));
    });

    test('link with ESC ST terminator', () {
      final result = KittyHyperlinks.link(
        url: 'https://example.com',
        text: 'Link',
      );
      // Should contain ESC ST (\x1b\)
      expect(result, contains('\x1b\\'));
    });
  });

  group('KittyHyperlinks - Custom ID', () {
    test('linkWithId generates sequence with ID', () {
      final result = KittyHyperlinks.linkWithId(
        id: 'my-link',
        url: 'https://example.com',
        text: 'Link',
      );
      expect(result, contains('\x1b]8;my-link;'));
      expect(result, contains('https://example.com'));
    });
  });

  group('KittyHyperlinks - End Link', () {
    test('end generates correct reset sequence', () {
      final result = KittyHyperlinks.end();
      expect(result, contains('\x1b]8;;'));
      expect(result, contains('\x1b\\'));
    });
  });

  group('KittyHyperlinks - Convenience Methods', () {
    test('linkTo generates URL as text', () {
      final result = KittyHyperlinks.linkTo('https://example.com');
      expect(result, contains('https://example.com'));
    });
  });

  group('KittyHyperlinks - Constants', () {
    test('oscCode is 8', () {
      expect(KittyHyperlinks.oscCode, 8);
    });
  });
}
