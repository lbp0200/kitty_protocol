/// Pointer Shapes Protocol Tests
///
/// Tests for Kitty Pointer Shapes encoder (OSC 22)
///
/// Reference: doc/kitty/docs/pointer-shapes.rst
library kitty_protocol_pointer_shapes_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  group('KittyPointerShapes - Set Operations', () {
    test('set generates correct sequence', () {
      final result = KittyPointerShapes.set(KittyPointerShape.pointer);
      expect(result, contains('\x1b]22;'));
      expect(result, contains('pointer'));
      expect(result, contains('\x1b\\'));
    });

    test('reset generates correct sequence', () {
      final result = KittyPointerShapes.reset();
      expect(result, contains('\x1b]22;'));
      expect(result, contains('\x1b\\'));
    });
  });

  group('KittyPointerShapes - Stack Operations', () {
    test('push generates correct sequence', () {
      final result = KittyPointerShapes.push([KittyPointerShape.wait]);
      expect(result, contains('\x1b]22;'));
      expect(result, contains('>wait'));
    });

    test('pushShape generates correct sequence', () {
      final result = KittyPointerShapes.pushShape(KittyPointerShape.pointer);
      expect(result, contains('>pointer'));
    });

    test('pop generates correct sequence', () {
      final result = KittyPointerShapes.pop();
      expect(result, contains('\x1b]22;'));
      expect(result, contains('<'));
    });
  });

  group('KittyPointerShapes - Query Operations', () {
    test('queryCurrent generates correct sequence', () {
      final result = KittyPointerShapes.queryCurrent();
      expect(result, contains('?__current__'));
    });

    test('queryDefault generates correct sequence', () {
      final result = KittyPointerShapes.queryDefault();
      expect(result, contains('?__default__'));
    });

    test('queryGrabbed generates correct sequence', () {
      final result = KittyPointerShapes.queryGrabbed();
      expect(result, contains('?__grabbed__'));
    });

    test('querySupport generates correct sequence', () {
      final result = KittyPointerShapes.querySupport([
        KittyPointerShape.pointer,
        KittyPointerShape.crosshair,
      ]);
      expect(result, contains('?pointer'));
      expect(result, contains('crosshair'));
    });
  });

  group('KittyPointerShapes - Convenience Getters', () {
    test('link getter returns pointer shape', () {
      final result = KittyPointerShapes.link;
      expect(result, contains('pointer'));
    });

    test('text getter returns text shape', () {
      final result = KittyPointerShapes.text;
      expect(result, contains('text'));
    });

    test('crosshair getter returns crosshair shape', () {
      final result = KittyPointerShapes.crosshair;
      expect(result, contains('crosshair'));
    });

    test('wait getter returns wait shape', () {
      final result = KittyPointerShapes.wait;
      expect(result, contains('wait'));
    });

    test('grab getter returns grab shape', () {
      final result = KittyPointerShapes.grab;
      expect(result, contains('grab'));
    });

    test('grabbing getter returns grabbing shape', () {
      final result = KittyPointerShapes.grabbing;
      expect(result, contains('grabbing'));
    });

    test('notAllowed getter returns not-allowed shape', () {
      final result = KittyPointerShapes.notAllowed;
      expect(result, contains('not-allowed'));
    });

    test('move getter returns move shape', () {
      final result = KittyPointerShapes.move;
      expect(result, contains('move'));
    });

    test('copy getter returns copy shape', () {
      final result = KittyPointerShapes.copy;
      expect(result, contains('copy'));
    });
  });

  group('KittyPointerShapes - Push/Pop Helpers', () {
    test('pushWait generates correct sequence', () {
      final result = KittyPointerShapes.pushWait();
      expect(result, contains('>wait'));
    });

    test('pushPointer generates correct sequence', () {
      final result = KittyPointerShapes.pushPointer();
      expect(result, contains('>pointer'));
    });

    test('popCursor generates correct sequence', () {
      final result = KittyPointerShapes.popCursor();
      expect(result, contains('<'));
    });
  });

  group('KittyPointerShapes - Constants', () {
    test('oscCode is correct', () {
      expect(KittyPointerShapes.oscCode, 22);
    });
  });

  group('KittyPointerShape - Enum Values', () {
    test('shape values are correct', () {
      expect(KittyPointerShape.pointer.value, 'pointer');
      expect(KittyPointerShape.text.value, 'text');
      expect(KittyPointerShape.crosshair.value, 'crosshair');
      expect(KittyPointerShape.default_.value, 'default');
      expect(KittyPointerShape.wait.value, 'wait');
    });
  });

  group('KittyPointerCommand - Enum Values', () {
    test('command values are correct', () {
      expect(KittyPointerCommand.set.value, '=');
      expect(KittyPointerCommand.push.value, '>');
      expect(KittyPointerCommand.pop.value, '<');
      expect(KittyPointerCommand.query.value, '?');
    });
  });

  group('KittyPointerQueryNames - Query Names', () {
    test('query name constants are correct', () {
      expect(KittyPointerQueryNames.current, '__current__');
      expect(KittyPointerQueryNames.default_, '__default__');
      expect(KittyPointerQueryNames.grabbed, '__grabbed__');
    });
  });
}
