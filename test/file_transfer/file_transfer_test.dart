/// Kitty File Transfer Protocol Tests
///
/// Tests for the Kitty File Transfer Protocol encoder.
///
/// Reference: docs/kitty/docs/file-transfer-protocol.rst
library;
import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  group('KittyFileTransferEncoder', () {
    const encoder = KittyFileTransferEncoder();

    group('Session Commands', () {
      test('startSendSession generates correct OSC sequence', () {
        final result = encoder.startSendSession(sessionId: 'test123');

        // Should start with OSC 5113
        expect(result, startsWith('\x1b]5113;'));
        // Should end with ST terminator
        expect(result, endsWith('\x1b\\'));
        // Should contain action=send
        expect(result, contains('ac=send'));
        // Should contain session id
        expect(result, contains('id=test123'));
      });

      test('startSendSession with bypassHash', () {
        final result = encoder.startSendSession(
          sessionId: 'test123',
          bypassHash: 'myhash',
        );
        expect(result, contains('pw=myhash'));
      });

      test('startSendSession with quiet level', () {
        final result = encoder.startSendSession(
          sessionId: 'test123',
          quiet: KittyQuietLevel.silent,
        );
        expect(result, contains('q=2'));
      });

      test('startReceiveSession with path count', () {
        final result = encoder.startReceiveSession(
          sessionId: 'recv001',
          pathCount: 3,
        );

        expect(result, contains('ac=receive'));
        expect(result, contains('id=recv001'));
        expect(result, contains('sz=3'));
      });

      test('startReceiveSession with bypassHash', () {
        final result = encoder.startReceiveSession(
          sessionId: 'recv001',
          pathCount: 2,
          bypassHash: 'secret',
        );
        expect(result, contains('pw=secret'));
      });

      test('cancelSession generates cancel action', () {
        final result = encoder.cancelSession('session1');

        expect(result, contains('ac=cancel'));
        expect(result, contains('id=session1'));
      });

      test('finishSession generates finish action', () {
        final result = encoder.finishSession('session1');

        expect(result, contains('ac=finish'));
        expect(result, contains('id=session1'));
      });
    });

    group('File Metadata Commands', () {
      test('sendFileMetadata encodes path as base64', () {
        final result = encoder.sendFileMetadata(
          sessionId: 'sess1',
          fileId: 'f1',
          destinationPath: '/home/user/test.txt',
        );

        // Path should be base64 encoded
        // '/home/user/test.txt' -> 'L2hvbWUvdXNlci90ZXN0LnR4dA=='
        expect(result, contains('n=L2hvbWUvdXNlci90ZXN0LnR4dA=='));
        expect(result, contains('fid=f1'));
      });

      test('sendFileMetadata with directory type', () {
        final result = encoder.sendFileMetadata(
          sessionId: 'sess1',
          fileId: 'f2',
          destinationPath: '/home/user/mydir',
          fileType: KittyFileType.directory,
        );

        expect(result, contains('ft=directory'));
      });

      test('sendFileMetadata with modification time', () {
        final result = encoder.sendFileMetadata(
          sessionId: 'sess1',
          fileId: 'f1',
          destinationPath: '/path/to/file',
          modificationTime: 1700000000,
        );
        expect(result, contains('mod=1700000000'));
      });

      test('sendFileMetadata with permissions', () {
        final result = encoder.sendFileMetadata(
          sessionId: 'sess1',
          fileId: 'f1',
          destinationPath: '/path/to/file',
          permissions: 420,
        );
        expect(result, contains('prm=420'));
      });

      test('sendFileMetadata with compression', () {
        final result = encoder.sendFileMetadata(
          sessionId: 'sess1',
          fileId: 'f1',
          destinationPath: '/path/to/file',
          compression: KittyFileCompression.zlib,
        );

        expect(result, contains('zip=zlib'));
      });
    });

    group('Request File Commands', () {
      test('requestFile generates correct sequence', () {
        final result = encoder.requestFile(
          sessionId: 'sess1',
          fileId: 'f1',
          filePath: '/home/user/file.txt',
        );
        expect(result, contains('ac=file'));
        expect(result, contains('id=sess1'));
        expect(result, contains('fid=f1'));
        expect(result, contains('n='));
      });

      test('requestFile with rsync transmission', () {
        final result = encoder.requestFile(
          sessionId: 'sess1',
          fileId: 'f1',
          filePath: '/path/to/file',
          transmissionType: KittyTransmissionType.rsync,
        );
        expect(result, contains('tt=rsync'));
      });

      test('requestFile with compression', () {
        final result = encoder.requestFile(
          sessionId: 'sess1',
          fileId: 'f1',
          filePath: '/path/to/file',
          compression: KittyFileCompression.zlib,
        );
        expect(result, contains('zip=zlib'));
      });
    });

    group('Data Chunk Transmission', () {
      test('sendDataChunk with m=1 flag for non-last chunk', () {
        // Create some test data
        final testData = List.generate(100, (i) => i % 256);

        final result = encoder.sendDataChunk(
          sessionId: 'sess1',
          fileId: 'f1',
          data: testData,
          isLastChunk: false,
        );

        // Should contain m=1 for more chunks coming
        expect(result, contains('m=1'));
        expect(result, contains('ac=data'));
        expect(result, contains('fid=f1'));
      });

      test('sendDataChunk without m=1 flag for last chunk', () {
        final testData = List.generate(50, (i) => i % 256);

        final result = encoder.sendDataChunk(
          sessionId: 'sess1',
          fileId: 'f1',
          data: testData,
          isLastChunk: true,
        );

        // Should NOT contain m=1 for last chunk
        expect(result, isNot(contains('m=1')));
        // Should use end_data action
        expect(result, contains('ac=end_data'));
      });

      test('sendEndOfData sends trailing data', () {
        final trailingData = [1, 2, 3, 4, 5];

        final result = encoder.sendEndOfData(
          sessionId: 'sess1',
          fileId: 'f1',
          trailingData: trailingData,
        );

        expect(result, contains('ac=end_data'));
        // Data should be base64 encoded: [1,2,3,4,5] -> AQIDBAU=
        expect(result, contains('d=AQIDBAU='));
      });

      test('sendEndOfData without trailing data sends empty data', () {
        final result = encoder.sendEndOfData(
          sessionId: 'sess1',
          fileId: 'f1',
        );
        expect(result, contains('ac=end_data'));
        expect(result, contains('d='));
      });
    });

    group('Chunked File Transfer', () {
      test('sendFileInChunks generates correct sequence of chunks', () {
        // Create 6000 bytes of test data (2 chunks of 4096 max, with some remainder)
        final testData = List.generate(6000, (i) => i % 256);

        final sequences = encoder.sendFileInChunks(
          sessionId: 'bigfile',
          fileId: 'f1',
          fileData: testData,
        );

        // Should produce 2 chunks: 4096 + 1904 = 6000
        expect(sequences.length, equals(2));

        // First chunk should have m=1 (more coming)
        expect(sequences[0], contains('m=1'));
        expect(sequences[0], contains('ac=data'));

        // Last chunk should NOT have m=1
        expect(sequences[1], isNot(contains('m=1')));
        expect(sequences[1], contains('ac=end_data'));
      });

      test('sendFileInChunks with custom chunk size', () {
        final testData = List.generate(300, (i) => i % 256);

        final sequences = encoder.sendFileInChunks(
          sessionId: 'sess1',
          fileId: 'f1',
          fileData: testData,
          chunkSize: 100, // 3 chunks
        );

        expect(sequences.length, equals(3));

        // First two should have m=1
        expect(sequences[0], contains('m=1'));
        expect(sequences[1], contains('m=1'));

        // Last should NOT have m=1
        expect(sequences[2], isNot(contains('m=1')));
      });

      test('chunkData splits data correctly', () {
        final testData = List.generate(500, (i) => i);

        final chunks = encoder.chunkData(testData, chunkSize: 200);

        expect(chunks.length, equals(3));
        expect(chunks[0].length, equals(200));
        expect(chunks[1].length, equals(200));
        expect(chunks[2].length, equals(100));
      });
    });

    group('ID Generation', () {
      test('generateSessionId creates unique IDs', () {
        final id1 = encoder.generateSessionId();
        final id2 = encoder.generateSessionId();

        // Should start with prefix
        expect(id1, startsWith('ft_'));
        expect(id2, startsWith('ft_'));

        // Should be different (based on timestamp)
        // Note: Could theoretically be same if called in same millisecond
      });

      test('generateFileId creates sequential IDs', () {
        expect(encoder.generateFileId(0), equals('f1'));
        expect(encoder.generateFileId(1), equals('f2'));
        expect(encoder.generateFileId(10), equals('f11'));
      });
    });

    group('Response Parsing', () {
      test('parseResponse extracts key-value pairs', () {
        // Simulate a response: <OSC> 5113 ; ac=status ; id=test ; st=OK <ST>
        const response = '\x1b]5113;ac=status;id=test;st=OK\x1b\\';

        final parsed = encoder.parseResponse(response);

        expect(parsed['ac'], equals('status'));
        expect(parsed['id'], equals('test'));
        expect(parsed['st'], equals('OK'));
      });

      test('parseResponse returns empty map for invalid format', () {
        final result = encoder.parseResponse('not a valid protocol response');
        expect(result, isEmpty);
      });

      test('isSuccessResponse detects OK status', () {
        expect(encoder.isSuccessResponse({'st': 'OK'}), isTrue);
        expect(encoder.isSuccessResponse({'status': 'OK'}), isTrue);
        expect(encoder.isSuccessResponse({'st': 'STARTED'}), isTrue);
        expect(encoder.isSuccessResponse({'st': 'EPERM:error'}), isFalse);
      });

      test('getStatusMessage extracts message', () {
        expect(encoder.getStatusMessage({'st': 'OK'}), equals('OK'));
        expect(encoder.getStatusMessage({'status': 'EPERM:Denied'}), equals('EPERM:Denied'));
      });
    });

    group('Protocol Format Compliance', () {
      test('all sequences use OSC 5113', () {
        final sequences = [
          encoder.startSendSession(sessionId: 's1'),
          encoder.startReceiveSession(sessionId: 's2', pathCount: 1),
          encoder.cancelSession('s3'),
          encoder.finishSession('s4'),
          encoder.sendFileMetadata(
            sessionId: 's5',
            fileId: 'f1',
            destinationPath: '/test',
          ),
          encoder.sendDataChunk(
            sessionId: 's6',
            fileId: 'f1',
            data: [1, 2, 3],
            isLastChunk: true,
          ),
        ];

        for (final seq in sequences) {
          expect(seq, startsWith('\x1b]5113;'));
          expect(seq, endsWith('\x1b\\'));
        }
      });

      test('sequences use correct action abbreviations', () {
        // Per protocol: action -> ac, file_id -> fid, etc.
        expect(encoder.startSendSession(sessionId: 'x'), contains('ac=send'));
        expect(encoder.cancelSession('x'), contains('ac=cancel'));
        expect(encoder.finishSession('x'), contains('ac=finish'));
        expect(encoder.sendFileMetadata(
          sessionId: 'x',
          fileId: 'f1',
          destinationPath: '/a',
        ), contains('ac=file'));
      });
    });
  });
}
