/// Kitty Graphics Protocol Tests
///
/// Tests for the Kitty Graphics Protocol encoder.
///
/// Reference: doc/kitty/docs/graphics-protocol.rst
library kitty_protocol_graphics_test;

import 'dart:convert' show base64;
import 'dart:io' show zlib;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  group('KittyGraphicsEncoder', () {
    const encoder = KittyGraphicsEncoder();

    // ============ Basic Tests ============

    test('encode PNG produces correct sequence', () {
      // PNG format: f=100
      final result = encoder.encodePng([0x89, 0x50, 0x4E], imageId: 1);
      expect(result, contains('f=100'));
      expect(result, contains('i=1'));
    });

    test('encode RGBA produces correct sequence', () {
      final result = encoder.encodeRgba(
        width: 10,
        height: 20,
        rgbaData: [],
        imageId: 1,
      );
      expect(result, contains('f=32'));
      expect(result, contains('s=10'));
      expect(result, contains('v=20'));
      expect(result, contains('i=1'));
    });

    test('encode RGBA with compression includes o=z', () {
      final result = encoder.encodeRgba(
        width: 10,
        height: 20,
        rgbaData: [0, 0, 0, 0],
        compress: true,
      );
      expect(result, contains('o=z'));
    });

    test('encode RGBA with compression round-trips correctly', () {
      final original = List.generate(1000, (_) => 128);
      final seq = encoder.encodeRgba(
        width: 10,
        height: 100,
        rgbaData: original,
        compress: true,
      );
      final semicolon = seq.indexOf(';');
      final terminator = seq.indexOf('\x1b\\');
      final payload = seq.substring(semicolon + 1, terminator);
      final decoded = base64.decode(payload);
      final decompressed = zlib.decode(decoded);
      expect(decompressed, equals(original));
    });

    test('encode RGBA with compression reduces payload size', () {
      final data = List.generate(10000, (_) => 255);
      final uncompressed = encoder.encodeRgba(width: 100, height: 100, rgbaData: data);
      final compressed = encoder.encodeRgba(width: 100, height: 100, rgbaData: data, compress: true);
      expect(compressed.length, lessThan(uncompressed.length));
    });

    test('encode RGB with compression includes o=z', () {
      final result = encoder.encodeRgb(
        width: 10,
        height: 20,
        rgbData: [0, 0, 0],
        compress: true,
      );
      expect(result, contains('o=z'));
    });

    test('encode RGB with compression round-trips correctly', () {
      final original = List.generate(999, (_) => 64); // Multiple of 3 for RGB
      final seq = encoder.encodeRgb(
        width: 10,
        height: 100,
        rgbData: original,
        compress: true,
      );
      final semicolon = seq.indexOf(';');
      final terminator = seq.indexOf('\x1b\\');
      final payload = seq.substring(semicolon + 1, terminator);
      final decoded = base64.decode(payload);
      final decompressed = zlib.decode(decoded);
      expect(decompressed, equals(original));
    });

    test('encode RGB with compression reduces payload size', () {
      final data = List.generate(9999, (_) => 255);
      final uncompressed = encoder.encodeRgb(width: 100, height: 100, rgbData: data);
      final compressed = encoder.encodeRgb(width: 100, height: 100, rgbData: data, compress: true);
      expect(compressed.length, lessThan(uncompressed.length));
    });

    test('encode RGB with imageId', () {
      final result = encoder.encodeRgb(width: 10, height: 10, rgbData: [0, 0, 0], imageId: 5);
      expect(result, contains('i=5'));
    });

    test('delete all images', () {
      final result = encoder.deleteAll();
      expect(result, contains('a=d'));
    });

    test('delete specific image', () {
      final result = encoder.deleteImage(5);
      expect(result, contains('a=d'));
      expect(result, contains('i=5'));
    });

    test('delete by z-index includes z value', () {
      final result = encoder.deleteByZIndex(-1);
      expect(result, contains('a=d'));
      expect(result, contains('d=Z'));
      expect(result, contains('z=-1'));
    });

    test('delete at position includes coordinates', () {
      final result = encoder.deleteAtPosition(10, 20);
      expect(result, contains('a=d'));
      expect(result, contains('d=p'));
      expect(result, contains('x=10'));
      expect(result, contains('y=20'));
    });

    test('query support generates correct sequence', () {
      final result = encoder.querySupport();
      expect(result, contains('a=q'));
      expect(result, contains('f=24'));
    });

    // ============ Query Commands ============

    test('queryImage generates correct sequence', () {
      final result = encoder.queryImage(42);
      expect(result, contains('a=q'));
      expect(result, contains('d=i'));
      expect(result, contains('i=42'));
    });

    test('queryImageByNumber generates correct sequence', () {
      final result = encoder.queryImageByNumber(7);
      expect(result, contains('a=q'));
      expect(result, contains('d=I'));
      expect(result, contains('I=7'));
    });

    test('queryPlacement generates correct sequence', () {
      final result = encoder.queryPlacement(3);
      expect(result, contains('a=q'));
      expect(result, contains('d=p'));
      expect(result, contains('p=3'));
    });

    test('queryAtCursor generates correct sequence', () {
      final result = encoder.queryAtCursor();
      expect(result, contains('a=q'));
      expect(result, contains('d=c'));
    });

    test('queryAllImages generates correct sequence', () {
      final result = encoder.queryAllImages();
      expect(result, contains('a=q'));
      expect(result, contains('d=a'));
    });

    // ============ Placement ============

    test('placeImage generates correct sequence', () {
      final result = encoder.placeImage(imageId: 1);
      expect(result, contains('a=p'));
      expect(result, contains('i=1'));
      // C=0 is omitted because buildControlData filters zero values
      expect(result, isNot(contains('C=')));
    });

    test('placeImage with all options', () {
      final result = encoder.placeImage(
        imageId: 1,
        placementId: 5,
        columns: 20,
        rows: 10,
        xOffset: 2,
        yOffset: 3,
        zIndex: 48,
        cursorMovement: KittyCursorMovement.noMove,
      );
      expect(result, contains('p=5'));
      expect(result, contains('c=20'));
      expect(result, contains('r=10'));
      expect(result, contains('X=2'));
      expect(result, contains('Y=3'));
      expect(result, contains('z=48'));
      expect(result, contains('C=1'));
    });

    // ============ Transmit and Display ============

    test('transmitAndDisplay generates correct sequence', () {
      final result = encoder.transmitAndDisplay(imageId: 1);
      expect(result, contains('a=T'));
      expect(result, contains('i=1'));
    });

    test('transmitAndDisplay with all options', () {
      final result = encoder.transmitAndDisplay(
        imageId: 1,
        columns: 40,
        rows: 20,
        xOffset: 5,
        yOffset: 10,
        zIndex: 99,
      );
      expect(result, contains('c=40'));
      expect(result, contains('r=20'));
      expect(result, contains('X=5'));
      expect(result, contains('Y=10'));
      expect(result, contains('z=99'));
    });

    // ============ Delete with placement ============

    test('deleteImage with placementId', () {
      final result = encoder.deleteImage(1, placementId: 3);
      expect(result, contains('a=d'));
      expect(result, contains('i=1'));
      expect(result, contains('p=3'));
    });

    // ============ Composition with coordinates ============

    test('compositionCreate with source/dest coordinates', () {
      final result = encoder.compositionCreate(
        sourceImageId: 1,
        destImageId: 2,
        sourceColumns: 10,
        sourceRows: 20,
        destColumns: 5,
        destRows: 10,
        sourceX: 2,
        sourceY: 3,
        destX: 1,
        destY: 0, // Zero value is filtered by buildControlData
      );
      expect(result, contains('X=2'));
      expect(result, contains('Y=3'));
      expect(result, contains('x=1'));
      // y=0 is omitted because buildControlData filters zero values
      expect(result, isNot(contains('y=')));
    });

    // ============ Virtual Placement with options ============

    test('virtualPlacement with all options', () {
      final result = encoder.virtualPlacement(
        imageId: 1,
        columns: 5,
        rows: 3,
        xOffset: 1,
        yOffset: 2,
        zIndex: -1,
      );
      expect(result, contains('U=1'));
      expect(result, contains('i=1'));
      expect(result, contains('c=5'));
      expect(result, contains('r=3'));
      expect(result, contains('X=1'));
      expect(result, contains('Y=2'));
      expect(result, contains('z=-1'));
    });

    // ============ Relative Placement with options ============

    test('relativePlacement with parent placement and offsets', () {
      final result = encoder.relativePlacement(
        imageId: 1,
        placementId: 2,
        parentImageId: 3,
        parentPlacementId: 4,
        xOffset: 10,
        yOffset: 20,
      );
      expect(result, contains('a=p'));
      expect(result, contains('i=1'));
      expect(result, contains('p=2'));
      expect(result, contains('P=3'));
      expect(result, contains('Q=4'));
      expect(result, contains('X=10'));
      expect(result, contains('Y=20'));
    });

    // ============ Animation Tests ============

    test('transmit frame produces correct sequence', () {
      final result = encoder.transmitFrame(
        imageId: 1,
        frameNumber: 3,
        frameData: [0, 1, 2, 3],
      );
      expect(result, contains('a=f'));
      expect(result, contains('i=1'));
      expect(result, contains('I=3'));
    });

    test('transmit frame with compression', () {
      final result = encoder.transmitFrame(
        imageId: 1,
        frameNumber: 1,
        frameData: [0, 1, 2, 3],
        compress: true,
      );
      expect(result, contains('o=z'));
    });

    test('transmit frame compression round-trips correctly', () {
      final original = List.generate(500, (_) => 42);
      final seq = encoder.transmitFrame(
        imageId: 1,
        frameNumber: 1,
        frameData: original,
        compress: true,
      );
      final semicolon = seq.indexOf(';');
      final terminator = seq.indexOf('\x1b\\');
      final payload = seq.substring(semicolon + 1, terminator);
      final decoded = base64.decode(payload);
      final decompressed = zlib.decode(decoded);
      expect(decompressed, equals(original));
    });

    test('transmit frame with more chunks flag', () {
      final result = encoder.transmitFrame(
        imageId: 1,
        frameNumber: 1,
        frameData: [],
        moreChunks: true,
      );
      expect(result, contains('m=1'));
    });

    test('transmit PNG frame produces correct sequence', () {
      final result = encoder.transmitPngFrame(
        imageId: 1,
        frameNumber: 5,
        pngData: [0x89, 0x50],
      );
      expect(result, contains('a=f'));
      expect(result, contains('f=100'));
      expect(result, contains('I=5'));
    });

    test('transmit PNG frame with more chunks flag', () {
      final result = encoder.transmitPngFrame(
        imageId: 1,
        frameNumber: 1,
        pngData: [],
        moreChunks: true,
      );
      expect(result, contains('m=1'));
    });

    test('animation create produces correct sequence', () {
      final result = encoder.animationCreate(
        imageId: 1,
        frameCount: 10,
        intervalMs: 100,
      );
      expect(result, contains('a=a'));
      expect(result, contains('i=1'));
      expect(result, contains('c=10'));
      expect(result, contains('I=100'));
    });

    test('animation play produces correct sequence', () {
      final result = encoder.animationPlay(
        imageId: 1,
        fromFrame: 0,
        toFrame: 9,
        zIndex: 48,
      );
      expect(result, contains('a=a'));
      expect(result, contains('i=1'));
      expect(result, contains('r=0-9'));
      expect(result, contains('z=48'));
    });

    test('animation pause produces correct sequence', () {
      final result = encoder.animationPause(imageId: 1);
      expect(result, contains('a=a'));
      expect(result, contains('i=1'));
    });

    test('animation clear produces correct sequence', () {
      final result = encoder.animationClear(imageId: 1);
      expect(result, contains('a=a'));
      expect(result, contains('i=1'));
    });

    // ============ Composition Tests ============

    test('composition create produces correct sequence', () {
      final result = encoder.compositionCreate(
        sourceImageId: 1,
        destImageId: 2,
        sourceColumns: 10,
        sourceRows: 20,
        destColumns: 5,
        destRows: 10,
      );
      expect(result, contains('a=c'));
      expect(result, contains('i=1'));
      expect(result, contains('I=2'));
      expect(result, contains('c=10'));
      expect(result, contains('r=20'));
      expect(result, contains('w=5'));
      expect(result, contains('h=10'));
    });

    // ============ Advanced Positioning Tests ============

    test('virtual placement produces correct sequence', () {
      final result = encoder.virtualPlacement(
        imageId: 1,
        columns: 5,
        rows: 3,
      );
      expect(result, contains('a=p'));
      expect(result, contains('U=1'));
      expect(result, contains('c=5'));
      expect(result, contains('r=3'));
    });

    test('relative placement produces correct sequence', () {
      final result = encoder.relativePlacement(
        imageId: 1,
        placementId: 2,
        parentImageId: 3,
      );
      expect(result, contains('a=p'));
      expect(result, contains('i=1'));
      expect(result, contains('p=2'));
      expect(result, contains('P=3'));
    });

    // ============ Delete Region Tests ============

    test('deleteInRegion includes end coordinates', () {
      final result = encoder.deleteInRegion(3, 4, 10, 20);
      expect(result, contains('a=d'));
      expect(result, contains('d=r'));
      expect(result, contains('x=3'));
      expect(result, contains('y=4'));
      expect(result, contains('X=10'));
      expect(result, contains('Y=20'));
    });

    // ============ Chunking Tests ============

    test('chunk data divides into correct number of chunks', () {
      // Create data larger than chunk size
      final data = List.generate(10000, (i) => i % 256);
      final chunks = encoder.chunkData(data);
      // Should be at least 2 chunks (10000 / 4096 ≈ 2.4)
      expect(chunks.length, greaterThan(1));
    });

    test('chunk data respects max chunk size', () {
      final data = List.generate(100, (i) => i % 256);
      final chunks = encoder.chunkData(data);
      // Each chunk should be at most maxChunkSize
      for (final chunk in chunks) {
        expect(chunk.length, lessThanOrEqualTo(KittyGraphicsEncoder.maxChunkSize));
      }
    });
  });

  group('KittyGraphicsAction enum', () {
    test('has all required action values', () {
      expect(KittyGraphicsAction.transmitAndDisplay.value, equals('T'));
      expect(KittyGraphicsAction.transmit.value, equals('t'));
      expect(KittyGraphicsAction.display.value, equals('p'));
      expect(KittyGraphicsAction.delete.value, equals('d'));
      expect(KittyGraphicsAction.query.value, equals('q'));
      expect(KittyGraphicsAction.frame.value, equals('f'));
      expect(KittyGraphicsAction.animation.value, equals('a'));
      expect(KittyGraphicsAction.composition.value, equals('c'));
    });
  });

  group('KittyAnimationLoop enum', () {
    test('has correct values', () {
      expect(KittyAnimationLoop.loop.value, equals(0));
      expect(KittyAnimationLoop.once.value, equals(1));
      expect(KittyAnimationLoop.bounce.value, equals(2));
    });
  });

  group('KittyGraphicsFormat enum', () {
    test('has correct values', () {
      expect(KittyGraphicsFormat.rgba.value, equals(32));
      expect(KittyGraphicsFormat.rgb.value, equals(24));
      expect(KittyGraphicsFormat.png.value, equals(100));
    });
  });

  group('KittyGraphicsCompression enum', () {
    test('has correct values', () {
      expect(KittyGraphicsCompression.none.value, equals(''));
      expect(KittyGraphicsCompression.deflate.value, equals('z'));
    });
  });

  group('KittyGraphicsTransmission enum', () {
    test('has correct values', () {
      expect(KittyGraphicsTransmission.direct.value, equals('d'));
      expect(KittyGraphicsTransmission.file.value, equals('f'));
      expect(KittyGraphicsTransmission.temporaryFile.value, equals('t'));
      expect(KittyGraphicsTransmission.sharedMemory.value, equals('s'));
    });
  });

  group('KittyCursorMovement enum', () {
    test('has correct values', () {
      expect(KittyCursorMovement.autoMove.value, equals(0));
      expect(KittyCursorMovement.noMove.value, equals(1));
    });
  });

  group('KittyGraphicsLayer enum', () {
    test('has correct values', () {
      expect(KittyGraphicsLayer.belowText.value, equals(-1));
      expect(KittyGraphicsLayer.defaultLayer.value, equals(0));
      expect(KittyGraphicsLayer.aboveText.value, equals(1));
    });
  });

  group('KittyAnimationAction enum', () {
    test('has correct values', () {
      expect(KittyAnimationAction.create.value, equals('c'));
      expect(KittyAnimationAction.play.value, equals('p'));
      expect(KittyAnimationAction.pause.value, equals('P'));
      expect(KittyAnimationAction.clear.value, equals('C'));
    });
  });

  group('KittyGraphicsPlaceholders', () {
    test('getPlaceholder with 1x1 returns zero-width space', () {
      expect(KittyGraphicsPlaceholders.getPlaceholder(widthInCells: 1), equals('\u200B'));
    });

    test('getPlaceholder with multi-cell returns block characters with newlines', () {
      final result = KittyGraphicsPlaceholders.getPlaceholder(widthInCells: 3, heightInCells: 2);
      expect(result, equals('\u2591\u2591\u2591\n\u2591\u2591\u2591\n'));
    });

    test('transparent returns zero-width space', () {
      expect(KittyGraphicsPlaceholders.transparent, equals('\u200B'));
    });

    test('singleCell returns full block character', () {
      expect(KittyGraphicsPlaceholders.singleCell, equals('\u2588'));
    });
  });

  group('KittyGraphicsEncoder - Base64 Edge Cases', () {
    const encoder = KittyGraphicsEncoder();

    test('encodeBase64 with empty data returns empty string', () {
      expect(encoder.encodeBase64([]), equals(''));
    });

    test('encodeBase64 with 1-byte data adds proper padding', () {
      // Single byte 0x41 = 'A' -> standard base64 'QQ=='
      final result = encoder.encodeBase64([0x41]);
      expect(result, equals('QQ=='));
    });

    test('encodeBase64 with 2-byte data adds proper padding', () {
      // Two bytes 0x41, 0x42 = 'AB' -> standard base64 'QUI='
      final result = encoder.encodeBase64([0x41, 0x42]);
      expect(result, equals('QUI='));
    });

    test('encodeBase64 matches standard library output', () {
      final data = List.generate(256, (i) => i);
      final result = encoder.encodeBase64(data);
      final expected = base64.encode(data);
      expect(result, equals(expected));
    });
  });

  group('KittyGraphicsEncoder - Chunking Edge Cases', () {
    const encoder = KittyGraphicsEncoder();

    test('chunkData with empty data returns empty list', () {
      final chunks = encoder.chunkData([]);
      expect(chunks, isEmpty);
    });
  });
}
