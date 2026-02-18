/// Kitty Graphics Protocol Tests
///
/// Tests for the Kitty Graphics Protocol encoder.
///
/// Reference: doc/kitty/docs/graphics-protocol.rst
library kitty_protocol_graphics_test;

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

    test('delete all images', () {
      final result = encoder.deleteAll();
      expect(result, contains('a=d'));
    });

    test('delete specific image', () {
      final result = encoder.deleteImage(5);
      expect(result, contains('a=d'));
      expect(result, contains('i=5'));
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
        frameData: [],
        compress: true,
      );
      expect(result, contains('o=z'));
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
}
