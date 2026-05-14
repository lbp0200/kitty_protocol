/// Remote Control Protocol Tests
///
/// Tests for Kitty Remote Control encoder (DCS JSON)
///
/// Reference: doc/kitty/docs/rc_protocol.rst
library kitty_protocol_remote_control_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  const encoder = KittyRemoteControlEncoder();

  group('KittyRemoteControlEncoder - Basic Commands', () {
    test('listWindows generates correct DCS sequence', () {
      final result = encoder.listWindows();
      expect(result, contains('\x1bP@kitty-cmd'));
      expect(result, contains('"cmd":"ls"'));
      expect(result, contains('\x1b\\'));
    });

    test('getWindowInfo generates correct sequence', () {
      final result = encoder.getWindowInfo();
      expect(result, contains('"cmd":"get_window_info"'));
    });

    test('getWindowInfo with windowId includes payload', () {
      final result = encoder.getWindowInfo(windowId: 5);
      expect(result, contains('"window_id":5'));
    });
  });

  group('KittyRemoteControlEncoder - Window Management', () {
    test('closeWindow generates correct sequence', () {
      final result = encoder.closeWindow(1);
      expect(result, contains('"cmd":"close_window"'));
      expect(result, contains('"window_id":1'));
    });

    test('setWindowTitle generates correct sequence', () {
      final result = encoder.setWindowTitle('Test Window');
      expect(result, contains('"cmd":"set_window_title"'));
      expect(result, contains('"title":"Test Window"'));
    });

    test('resizeWindow generates correct sequence', () {
      final result = encoder.resizeWindow(80, 24);
      expect(result, contains('"cmd":"resize_window"'));
      expect(result, contains('"width":80'));
      expect(result, contains('"height":24'));
    });
  });

  group('KittyRemoteControlEncoder - Tab Management', () {
    test('newTab generates correct sequence', () {
      final result = encoder.newTab();
      expect(result, contains('"cmd":"new_tab"'));
    });

    test('closeTab generates correct sequence', () {
      final result = encoder.closeTab(1);
      expect(result, contains('"cmd":"close_tab"'));
      expect(result, contains('"tab_id":1'));
    });

    test('focusTab generates correct sequence', () {
      final result = encoder.focusTab(2);
      expect(result, contains('"cmd":"focus_tab"'));
    });

    test('setTabTitle generates correct sequence', () {
      final result = encoder.setTabTitle('New Title');
      expect(result, contains('"cmd":"set_tab_title"'));
      expect(result, contains('"title":"New Title"'));
    });
  });

  group('KittyRemoteControlEncoder - System Queries', () {
    test('getVersion generates correct sequence', () {
      final result = encoder.getVersion();
      expect(result, contains('"cmd":"version"'));
    });

    test('getCwd generates correct sequence', () {
      final result = encoder.getCwd();
      expect(result, contains('"cmd":"get_cwd"'));
    });

    test('getPid generates correct sequence', () {
      final result = encoder.getPid();
      expect(result, contains('"cmd":"get_pid"'));
    });

    test('getPlatformInfo generates correct sequence', () {
      final result = encoder.getPlatformInfo();
      expect(result, contains('"cmd":"get_platform_info"'));
    });

    test('getFontInfo generates correct sequence', () {
      final result = encoder.getFontInfo();
      expect(result, contains('"cmd":"get_font_info"'));
    });
  });

  group('KittyRemoteControlEncoder - Colors', () {
    test('getColors generates correct sequence', () {
      final result = encoder.getColors();
      expect(result, contains('"cmd":"get_colors"'));
    });

    test('setColors generates correct sequence', () {
      final result = encoder.setColors(colors: {'foreground': '#ff0000'});
      expect(result, contains('"cmd":"set_colors"'));
    });

    test('resetColors generates reset all sequence', () {
      final result = encoder.resetColors();
      expect(result, contains('"cmd":"set_colors"'));
      expect(result, contains('"all":"default"'));
    });
  });

  group('KittyRemoteControlEncoder - Layout', () {
    test('getLayout generates correct sequence', () {
      final result = encoder.getLayout();
      expect(result, contains('"cmd":"get_layout"'));
    });

    test('setLayout generates correct sequence', () {
      final result = encoder.setLayout('stack');
      expect(result, contains('"cmd":"set_layout"'));
      expect(result, contains('"name":"stack"'));
    });
  });

  group('KittyRemoteControlEncoder - Clipboard', () {
    test('getClipboard generates correct sequence', () {
      final result = encoder.getClipboard();
      expect(result, contains('"cmd":"get_clipboard"'));
    });

    test('setClipboard generates correct sequence', () {
      final result = encoder.setClipboard('test text');
      expect(result, contains('"cmd":"set_clipboard"'));
      expect(result, contains('"text":"test text"'));
    });
  });

  group('KittyRemoteControlEncoder - JSON Escaping', () {
    test('escapes backslash correctly', () {
      final result = encoder.sendText('path\\to\\file');
      expect(result, contains('path\\\\to\\\\file'));
    });

    test('escapes quotes correctly', () {
      final result = encoder.sendText('say "hello"');
      expect(result, contains('say \\"hello\\"'));
    });

    test('escapes newlines correctly', () {
      final result = encoder.sendText('line1\nline2');
      expect(result, contains('line1\\nline2'));
    });

    test('escapes ESC character correctly', () {
      final result = encoder.sendText('test\x1bvalue');
      expect(result, contains('test\\x1bvalue'));
    });
  });

  group('KittyRemoteControlEncoder - Version', () {
    test('includes default version in command', () {
      final result = encoder.listWindows();
      expect(result, contains('"version":[0,14,2]'));
    });

    test('can use custom version', () {
      final result = encoder.buildCommand(
        command: 'test',
        version: [0, 20, 0],
      );
      expect(result, contains('"version":[0,20,0]'));
    });
  });

  group('KittyRemoteControlEncoder - noResponse flag', () {
    test('includes no_response when true', () {
      final result = encoder.closeWindow(1, noResponse: true);
      expect(result, contains('"no_response":true'));
    });

    test('omits no_response when false', () {
      final result = encoder.closeWindow(1, noResponse: false);
      expect(result, isNot(contains('"no_response"')));
    });
  });
}
