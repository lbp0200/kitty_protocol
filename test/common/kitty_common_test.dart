import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

class _TestEncoder extends KittyEncoderBase {}

void main() {
  group('KittyProtocolConstants', () {
    test('esc is 0x1b', () {
      expect(KittyProtocolConstants.esc, equals(0x1b));
    });

    test('bel is 0x07', () {
      expect(KittyProtocolConstants.bel, equals(0x07));
    });

    test('csi is ESC [', () {
      expect(KittyProtocolConstants.csi, equals('\x1b['));
    });

    test('csiPrivate is ESC [>', () {
      expect(KittyProtocolConstants.csiPrivate, equals('\x1b[>'));
    });

    test('apc is ESC _G', () {
      expect(KittyProtocolConstants.apc, equals('\x1b_G'));
    });

    test('apcEnd is ESC \\', () {
      expect(KittyProtocolConstants.apcEnd, equals('\x1b\\'));
    });

    test('osc is ESC ]', () {
      expect(KittyProtocolConstants.osc, equals('\x1b]'));
    });

    test('st is ESC \\', () {
      expect(KittyProtocolConstants.st, equals('\x1b\\'));
    });

    test('chunkSize is 4096', () {
      expect(KittyProtocolConstants.chunkSize, equals(4096));
    });

    test('maxChunkSize is 4096', () {
      expect(KittyProtocolConstants.maxChunkSize, equals(4096));
    });

    test('maxTextLength is 4096', () {
      expect(KittyProtocolConstants.maxTextLength, equals(4096));
    });
  });

  group('KittyEncoderBase', () {
    late _TestEncoder encoder;

    setUp(() {
      encoder = _TestEncoder();
    });

    test('buildSequence produces correct APC format', () {
      final result = encoder.buildSequence('a=T,f=32', 'base64data');
      expect(result, equals('\x1b_Ga=T,f=32;base64data\x1b\\'));
    });

    test('buildSequence with empty control data', () {
      final result = encoder.buildSequence('', 'payload');
      expect(result, equals('\x1b_G;payload\x1b\\'));
    });

    test('buildSequence with empty payload', () {
      final result = encoder.buildSequence('a=d', '');
      expect(result, equals('\x1b_Ga=d;\x1b\\'));
    });

    test('buildKeyValue returns empty string for null value', () {
      expect(encoder.buildKeyValue('key', null), equals(''));
    });

    test('buildKeyValue returns empty string for zero value', () {
      expect(encoder.buildKeyValue('key', 0), equals(''));
    });

    test('buildKeyValue returns empty string for false value', () {
      expect(encoder.buildKeyValue('key', false), equals(''));
    });

    test('buildKeyValue returns key=value for string', () {
      expect(encoder.buildKeyValue('f', '32'), equals('f=32'));
    });

    test('buildKeyValue returns key=value for positive int', () {
      expect(encoder.buildKeyValue('s', 100), equals('s=100'));
    });

    test('buildKeyValue returns key=value for true', () {
      expect(encoder.buildKeyValue('o', true), equals('o=true'));
    });

    test('buildControlData joins multiple pairs with comma', () {
      final result = encoder.buildControlData({'f': 32, 's': 10, 'v': 20});
      expect(result, equals('f=32,s=10,v=20'));
    });

    test('buildControlData filters null values', () {
      final result = encoder.buildControlData({'f': 32, 'i': null, 'a': null});
      expect(result, equals('f=32'));
    });

    test('buildControlData filters zero values', () {
      final result = encoder.buildControlData({'a': 'T', 'm': 0});
      expect(result, equals('a=T'));
    });

    test('buildControlData filters false values', () {
      final result = encoder.buildControlData({'a': 'T', 'o': false});
      expect(result, equals('a=T'));
    });

    test('buildControlData handles mixed filtering', () {
      final result = encoder.buildControlData({
        'f': 32,
        's': 100,
        'i': null,
        'a': 't',
        'm': 0,
        'o': false,
        'v': 200,
      });
      expect(result, equals('f=32,s=100,a=t,v=200'));
    });

    test('buildControlData returns empty string for empty map', () {
      expect(encoder.buildControlData({}), equals(''));
    });

    test('buildControlData returns empty string when all filtered out', () {
      expect(encoder.buildControlData({'a': null, 'b': 0, 'c': false}), equals(''));
    });
  });
}
