/// Color Stack Protocol Tests
///
/// Tests for Kitty Color Stack encoder (OSC 30001/30101)
///
/// Reference: doc/kitty/docs/color-stack.rst
library kitty_protocol_color_stack_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  group('KittyColorStack - Basic Operations', () {
    test('push generates correct OSC 30001 sequence', () {
      final result = KittyColorStack.push();
      expect(result, contains('\x1b]30001'));
      expect(result, contains('\x1b\\'));
    });

    test('pop generates correct OSC 30101 sequence', () {
      final result = KittyColorStack.pop();
      expect(result, contains('\x1b]30101'));
      expect(result, contains('\x1b\\'));
    });

    test('pushScope is alias for push', () {
      expect(KittyColorStack.pushScope(), KittyColorStack.push());
    });

    test('popScope is alias for pop', () {
      expect(KittyColorStack.popScope(), KittyColorStack.pop());
    });
  });

  group('KittyColorStack - OSC Codes', () {
    test('KittyColorStackOperation.push has correct OSC code', () {
      expect(KittyColorStackOperation.push.oscCode, 30001);
    });

    test('KittyColorStackOperation.pop has correct OSC code', () {
      expect(KittyColorStackOperation.pop.oscCode, 30101);
    });
  });

  group('KittyColorStack - Push/Pop Pair', () {
    test('push and pop can be used as pair', () {
      final pushSeq = KittyColorStack.push();
      final popSeq = KittyColorStack.pop();

      // Push should use OSC 30001
      expect(pushSeq, contains('30001'));
      // Pop should use OSC 30101
      expect(popSeq, contains('30101'));
    });
  });
}
