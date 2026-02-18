/// Misc Protocol Tests
///
/// Tests for Kitty Misc Protocol encoder
///
/// Reference: doc/kitty/docs/misc-protocol.rst
library kitty_protocol_misc_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  group('KittySgrCodes - Basic Codes', () {
    test('reset is 0', () {
      expect(KittySgrCodes.reset, 0);
    });

    test('bold is 1', () {
      expect(KittySgrCodes.bold, 1);
    });

    test('faint is 2', () {
      expect(KittySgrCodes.faint, 2);
    });

    test('italic is 3', () {
      expect(KittySgrCodes.italic, 3);
    });

    test('underline is 4', () {
      expect(KittySgrCodes.underline, 4);
    });

    test('blink is 5', () {
      expect(KittySgrCodes.blink, 5);
    });

    test('reverse is 7', () {
      expect(KittySgrCodes.reverse, 7);
    });

    test('hidden is 8', () {
      expect(KittySgrCodes.hidden, 8);
    });

    test('strikethrough is 9', () {
      expect(KittySgrCodes.strikethrough, 9);
    });
  });

  group('KittySgrCodes - Kitty Extensions', () {
    test('resetBold is 221', () {
      expect(KittySgrCodes.resetBold, 221);
    });

    test('resetFaint is 222', () {
      expect(KittySgrCodes.resetFaint, 222);
    });
  });

  group('KittyScreenControl - Screen Operations', () {
    test('moveScreenToScrollback generates correct sequence', () {
      final result = KittyScreenControl.moveScreenToScrollback();
      expect(result, '\x1b[22J');
    });

    test('clearScreen generates correct sequence', () {
      final result = KittyScreenControl.clearScreen();
      expect(result, '\x1b[2J');
    });

    test('clearToEnd generates correct sequence', () {
      final result = KittyScreenControl.clearToEnd();
      expect(result, '\x1b[0J');
    });

    test('clearToStart generates correct sequence', () {
      final result = KittyScreenControl.clearToStart();
      expect(result, '\x1b[1J');
    });
  });

  group('KittyFocusReporting - Focus Events', () {
    test('enable generates correct sequence', () {
      final result = KittyFocusReporting.enable();
      expect(result, contains('1004'));
      expect(result, contains('h'));
    });

    test('disable generates correct sequence', () {
      final result = KittyFocusReporting.disable();
      expect(result, contains('1004'));
      expect(result, contains('l'));
    });

    test('focusIn is correct', () {
      expect(KittyFocusReporting.focusIn, '\x1b[I');
    });

    test('focusOut is correct', () {
      expect(KittyFocusReporting.focusOut, '\x1b[O');
    });
  });

  group('KittyTextStyle - Text Styling', () {
    test('resetBold generates correct sequence', () {
      final result = KittyTextStyle.resetBold;
      expect(result, contains('221'));
    });

    test('resetFaint generates correct sequence', () {
      final result = KittyTextStyle.resetFaint;
      expect(result, contains('222'));
    });

    test('reset generates reset sequence', () {
      expect(KittyTextStyle.reset, '\x1b[0m');
    });

    test('bold generates bold sequence', () {
      expect(KittyTextStyle.bold, '\x1b[1m');
    });

    test('faint generates faint sequence', () {
      expect(KittyTextStyle.faint, '\x1b[2m');
    });

    test('normalIntensity generates both reset codes', () {
      final result = KittyTextStyle.normalIntensity;
      expect(result, contains('221'));
      expect(result, contains('222'));
    });
  });

  group('KittyMouseTracking - Mouse Tracking', () {
    test('enable generates SGR mouse sequence', () {
      final result = KittyMouseTracking.enable();
      expect(result, contains('1006'));
      expect(result, contains('h'));
    });

    test('disable generates disable sequence', () {
      final result = KittyMouseTracking.disable();
      expect(result, contains('1006'));
      expect(result, contains('l'));
    });

    test('enableUrxvt generates URXVT sequence', () {
      final result = KittyMouseTracking.enableUrxvt();
      expect(result, contains('1015'));
      expect(result, contains('h'));
    });

    test('disableUrxvt generates disable sequence', () {
      final result = KittyMouseTracking.disableUrxvt();
      expect(result, contains('1015'));
      expect(result, contains('l'));
    });

    test('enableBasic generates basic mouse sequence', () {
      final result = KittyMouseTracking.enableBasic();
      expect(result, contains('1000'));
      expect(result, contains('h'));
    });

    test('disableBasic generates disable sequence', () {
      final result = KittyMouseTracking.disableBasic();
      expect(result, contains('1000'));
      expect(result, contains('l'));
    });

    test('enableButtonEvents generates button events sequence', () {
      final result = KittyMouseTracking.enableButtonEvents();
      expect(result, contains('1002'));
      expect(result, contains('h'));
    });

    test('enableAllEvents generates all events sequence', () {
      final result = KittyMouseTracking.enableAllEvents();
      expect(result, contains('1003'));
      expect(result, contains('h'));
    });
  });

  group('KittyBracketedPaste - Bracketed Paste', () {
    test('enable generates correct sequence', () {
      final result = KittyBracketedPaste.enable();
      expect(result, contains('2004'));
      expect(result, contains('h'));
    });

    test('disable generates correct sequence', () {
      final result = KittyBracketedPaste.disable();
      expect(result, contains('2004'));
      expect(result, contains('l'));
    });

    test('pasteStart is correct', () {
      expect(KittyBracketedPaste.pasteStart, '\x1b[200~');
    });

    test('pasteEnd is correct', () {
      expect(KittyBracketedPaste.pasteEnd, '\x1b[201~');
    });
  });

  group('KittyDecModes - DEC Private Modes', () {
    test('saveCursor generates DECSC sequence', () {
      expect(KittyDecModes.saveCursor(), '\x1b7');
    });

    test('restoreCursor generates DECRC sequence', () {
      expect(KittyDecModes.restoreCursor(), '\x1b8');
    });

    test('ansiSaveCursor generates CSI s sequence', () {
      expect(KittyDecModes.ansiSaveCursor(), '\x1b[s');
    });

    test('ansiRestoreCursor generates CSI u sequence', () {
      expect(KittyDecModes.ansiRestoreCursor(), '\x1b[u');
    });

    test('hideCursor generates hide sequence', () {
      final result = KittyDecModes.hideCursor();
      expect(result, contains('25'));
      expect(result, contains('l'));
    });

    test('showCursor generates show sequence', () {
      final result = KittyDecModes.showCursor();
      expect(result, contains('25'));
      expect(result, contains('h'));
    });

    test('enableOriginMode generates correct sequence', () {
      final result = KittyDecModes.enableOriginMode();
      expect(result, contains('6'));
      expect(result, contains('h'));
    });

    test('disableOriginMode generates correct sequence', () {
      final result = KittyDecModes.disableOriginMode();
      expect(result, contains('6'));
      expect(result, contains('l'));
    });
  });
}
