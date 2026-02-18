/// Clipboard Protocol Tests
///
/// Tests for Kitty Clipboard encoder (OSC 52 and OSC 5522)
///
/// Reference: doc/kitty/docs/clipboard.rst
library kitty_protocol_clipboard_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  const encoder = KittyClipboardEncoder();

  group('KittyClipboardEncoder - OSC 52 Basic', () {
    test('osc52Read generates correct sequence', () {
      final result = encoder.osc52Read();
      expect(result, contains('\x1b]52;'));
      expect(result, contains('\x1b\\'));
    });

    test('osc52Read with clipboard location', () {
      final result = encoder.osc52Read(location: KittyClipboardLocation.clipboard);
      expect(result, contains('\x1b]52;'));
    });

    test('osc52Write generates correct sequence', () {
      final result = encoder.osc52Write('test data');
      expect(result, contains('\x1b]52;'));
      expect(result, contains('\x07'));
    });

    test('osc52Write encodes base64 correctly', () {
      // "hello" in base64 is "aGVsbG8="
      final result = encoder.osc52Write('hello');
      expect(result, contains('aGVsbG8='));
    });
  });

  group('KittyClipboardEncoder - OSC 5522 Extended', () {
    test('startRead generates correct sequence', () {
      final result = encoder.startRead(mimeTypes: ['text/plain']);
      expect(result, contains('\x1b]5522;'));
      expect(result, contains('type=read'));
      expect(result, contains('\x1b\\'));
    });

    test('startRead with multiple mime types', () {
      final result = encoder.startRead(
        mimeTypes: ['text/plain', 'text/html'],
      );
      expect(result, contains('type=read'));
    });

    test('startRead with session id', () {
      final result = encoder.startRead(
        mimeTypes: ['text/plain'],
        sessionId: 'session123',
      );
      expect(result, contains('id='));
    });

    test('queryAvailableTypes generates correct sequence', () {
      final result = encoder.queryAvailableTypes();
      expect(result, contains('\x1b]5522;'));
      expect(result, contains('type=read'));
      expect(result, contains('Lg==')); // "." base64 encoded
    });

    test('startWrite generates correct sequence', () {
      final result = encoder.startWrite();
      expect(result, contains('\x1b]5522;'));
      expect(result, contains('type=write'));
    });

    test('sendDataChunk generates correct sequence', () {
      final result = encoder.sendDataChunk(
        mimeType: 'text/plain',
        data: [104, 101, 108, 108, 111], // "hello"
      );
      expect(result, contains('\x1b]5522;'));
      expect(result, contains('type=wdata'));
      expect(result, contains('mime='));
    });

    test('endWrite generates correct sequence', () {
      final result = encoder.endWrite();
      expect(result, contains('\x1b]5522;'));
      expect(result, contains('type=wdata'));
    });

    test('writeAlias generates correct sequence', () {
      final result = encoder.writeAlias(
        targetMimeType: 'text/plain',
        aliases: ['text/html'],
      );
      expect(result, contains('\x1b]5522;'));
      expect(result, contains('type=walias'));
    });
  });

  group('KittyClipboardEncoder - Utility Methods', () {
    test('chunkData splits data correctly', () {
      final data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      final chunks = encoder.chunkData(data, chunkSize: 3);
      expect(chunks.length, 4);
      expect(chunks[0], [1, 2, 3]);
      expect(chunks[3], [10]);
    });

    test('writeTextInChunks generates complete sequence', () {
      final sequences = encoder.writeTextInChunks(text: 'hello world');
      expect(sequences.length, greaterThan(2)); // start + data + end
      expect(sequences.first, contains('type=write'));
      expect(sequences.last, contains('type=wdata'));
    });

    test('parseResponse parses correctly', () {
      const response = '\x1b]5522;status=OK\x1b\\';
      final parsed = encoder.parseResponse(response);
      expect(parsed['status'], 'OK');
    });

    test('isSuccessResponse identifies success', () {
      expect(encoder.isSuccessResponse({'status': 'OK'}), true);
      expect(encoder.isSuccessResponse({'status': 'DONE'}), true);
      expect(encoder.isSuccessResponse({'status': 'DATA'}), true);
      expect(encoder.isSuccessResponse({'status': 'ERROR'}), false);
    });
  });

  group('KittyClipboardEncoder - MIME Types', () {
    test('provides standard MIME types', () {
      expect(KittyClipboardMimeTypes.plainText, 'text/plain');
      expect(KittyClipboardMimeTypes.textUtf8, 'text/plain;charset=utf-8');
      expect(KittyClipboardMimeTypes.html, 'text/html');
      expect(KittyClipboardMimeTypes.imagePng, 'image/png');
    });
  });

  group('KittyClipboardEncoder - Enums', () {
    test('KittyClipboardLocation has correct values', () {
      expect(KittyClipboardLocation.clipboard.value, '');
      expect(KittyClipboardLocation.primary.value, 'primary');
    });

    test('KittyClipboardAction has correct values', () {
      expect(KittyClipboardAction.read.value, 'read');
      expect(KittyClipboardAction.write.value, 'write');
      expect(KittyClipboardAction.writeData.value, 'wdata');
      expect(KittyClipboardAction.writeAlias.value, 'walias');
    });

    test('KittyClipboardStatus has correct values', () {
      expect(KittyClipboardStatus.ok.value, 'OK');
      expect(KittyClipboardStatus.data.value, 'DATA');
      expect(KittyClipboardStatus.done.value, 'DONE');
      expect(KittyClipboardStatus.permissionDenied.value, 'EPERM');
    });
  });
}
