/// Multiple Cursors Protocol Tests
///
/// Tests for the Kitty Multiple Cursors Protocol encoder.
///
/// Reference: docs/kitty/docs/multiple-cursors-protocol.rst
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  group('KittyMultiCursorShape - Enum Values', () {
    test('none has value 0', () {
      expect(KittyMultiCursorShape.none.value, 0);
    });

    test('block has value 1', () {
      expect(KittyMultiCursorShape.block.value, 1);
    });

    test('beam has value 2', () {
      expect(KittyMultiCursorShape.beam.value, 2);
    });

    test('underline has value 3', () {
      expect(KittyMultiCursorShape.underline.value, 3);
    });

    test('followMain has value 29', () {
      expect(KittyMultiCursorShape.followMain.value, 29);
    });

    test('textColor has value 30', () {
      expect(KittyMultiCursorShape.textColor.value, 30);
    });

    test('cursorColor has value 40', () {
      expect(KittyMultiCursorShape.cursorColor.value, 40);
    });

    test('query has value 100', () {
      expect(KittyMultiCursorShape.query.value, 100);
    });
  });

  group('KittyCursorCoordType - Enum Values', () {
    test('mainCursor has value 0', () {
      expect(KittyCursorCoordType.mainCursor.value, 0);
    });

    test('points has value 2', () {
      expect(KittyCursorCoordType.points.value, 2);
    });

    test('rectangle has value 4', () {
      expect(KittyCursorCoordType.rectangle.value, 4);
    });
  });

  group('KittyCursorColorSpace - Enum Values', () {
    test('unset has value 0', () {
      expect(KittyCursorColorSpace.unset.value, 0);
    });

    test('special has value 1', () {
      expect(KittyCursorColorSpace.special.value, 1);
    });

    test('srgb has value 2', () {
      expect(KittyCursorColorSpace.srgb.value, 2);
    });

    test('indexed has value 5', () {
      expect(KittyCursorColorSpace.indexed.value, 5);
    });
  });

  group('KittyMultiCursor - Show Cursors', () {
    test('show at specific point', () {
      final result = KittyMultiCursor.show(
        shape: KittyMultiCursorShape.block,
        coordType: KittyCursorCoordType.points,
        coordinates: [4, 5],
      );
      expect(result, '\x1b[>1;2:4:5 q');
    });

    test('show at multiple points', () {
      final result = KittyMultiCursor.show(
        shape: KittyMultiCursorShape.block,
        coordType: KittyCursorCoordType.points,
        coordinates: [4, 5, 7, 10],
      );
      expect(result, '\x1b[>1;2:4:5;2:7:10 q');
    });

    test('show with followMain shape', () {
      final result = KittyMultiCursor.show(
        shape: KittyMultiCursorShape.followMain,
        coordType: KittyCursorCoordType.points,
        coordinates: [4, 5],
      );
      expect(result, '\x1b[>29;2:4:5 q');
    });

    test('show in rectangle', () {
      final result = KittyMultiCursor.show(
        shape: KittyMultiCursorShape.beam,
        coordType: KittyCursorCoordType.rectangle,
        coordinates: [5, 6, 7, 8],
      );
      expect(result, '\x1b[>2;4:5:6:7:8 q');
    });

    test('show with mixed coordinate types', () {
      final result = KittyMultiCursor.show(
        shape: KittyMultiCursorShape.underline,
        coordType: KittyCursorCoordType.points,
        coordinates: [7, 1],
        extraCoordTypes: {
          KittyCursorCoordType.rectangle: [5, 6, 7, 8],
        },
      );
      expect(result, '\x1b[>3;2:7:1;4:5:6:7:8 q');
    });

    test('show at main cursor position', () {
      final result = KittyMultiCursor.show(
        shape: KittyMultiCursorShape.block,
        coordType: KittyCursorCoordType.mainCursor,
      );
      expect(result, '\x1b[>1;0 q');
    });
  });

  group('KittyMultiCursor - Clear Cursors', () {
    test('clear all cursors', () {
      final result = KittyMultiCursor.clear();
      expect(result, '\x1b[>0;4 q');
    });

    test('clear at specific points', () {
      final result = KittyMultiCursor.clear(
        coordType: KittyCursorCoordType.points,
        coordinates: [10, 20],
      );
      expect(result, '\x1b[>0;2:10:20 q');
    });

    test('clear in rectangle', () {
      final result = KittyMultiCursor.clear(
        coordType: KittyCursorCoordType.rectangle,
        coordinates: [1, 1, 10, 10],
      );
      expect(result, '\x1b[>0;4:1:1:10:10 q');
    });
  });

  group('KittyMultiCursor - Query', () {
    test('query support generates correct sequence', () {
      final result = KittyMultiCursor.querySupport();
      expect(result, '\x1b[> q');
    });

    test('query cursors generates correct sequence', () {
      final result = KittyMultiCursor.queryCursors();
      expect(result, '\x1b[>100 q');
    });

    test('query colors generates correct sequence', () {
      final result = KittyMultiCursor.queryColors();
      expect(result, '\x1b[>101 q');
    });
  });

  group('KittyMultiCursor - Set Color', () {
    test('set cursor color with sRGB', () {
      final result = KittyMultiCursor.setCursorColor(
        colorSpace: KittyCursorColorSpace.srgb,
        parameters: [255, 0, 0],
      );
      expect(result, '\x1b[>40;2:255:0:0 q');
    });

    test('set text color with sRGB', () {
      final result = KittyMultiCursor.setTextColor(
        colorSpace: KittyCursorColorSpace.srgb,
        parameters: [0, 255, 0],
      );
      expect(result, '\x1b[>30;2:0:255:0 q');
    });

    test('set cursor color unset', () {
      final result = KittyMultiCursor.setCursorColor(
        colorSpace: KittyCursorColorSpace.unset,
      );
      expect(result, '\x1b[>40;0 q');
    });

    test('set text color with indexed', () {
      final result = KittyMultiCursor.setTextColor(
        colorSpace: KittyCursorColorSpace.indexed,
        parameters: [196],
      );
      expect(result, '\x1b[>30;5:196 q');
    });

    test('set cursor color special', () {
      final result = KittyMultiCursor.setCursorColor(
        colorSpace: KittyCursorColorSpace.special,
      );
      expect(result, '\x1b[>40;1 q');
    });
  });
}
