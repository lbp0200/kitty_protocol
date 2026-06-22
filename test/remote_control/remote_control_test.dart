/// Remote Control Protocol Tests
///
/// Tests for Kitty Remote Control encoder (DCS JSON)
///
/// Reference: docs/kitty/docs/rc_protocol.rst
library;
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

    test('getWindowInfo with null windowId omits payload', () {
      final result = encoder.getWindowInfo();
      expect(result, isNot(contains('"window_id"')));
    });
  });

  group('KittyRemoteControlEncoder - Text Operations', () {
    test('sendText generates correct sequence', () {
      final result = encoder.sendText('hello');
      expect(result, contains('"cmd":"send_text"'));
      expect(result, contains('"text":"hello"'));
    });

    test('sendText with windowId', () {
      final result = encoder.sendText('hello', windowId: 1);
      expect(result, contains('"window_id":1'));
    });

    test('sendText with noResponse explicitly', () {
      final result = encoder.sendText('test', noResponse: false);
      expect(result, isNot(contains('"no_response"')));
    });

    test('input generates correct sequence', () {
      final result = encoder.input('你好');
      expect(result, contains('"cmd":"input"'));
      expect(result, contains('"text":"你好"'));
    });

    test('input with windowId', () {
      final result = encoder.input('text', windowId: 2);
      expect(result, contains('"window_id":2'));
    });

    test('clearScreen generates correct sequence', () {
      final result = encoder.clearScreen();
      expect(result, contains('"cmd":"clear_screen"'));
    });

    test('clearScreen with windowId', () {
      final result = encoder.clearScreen(windowId: 1);
      expect(result, contains('"window_id":1'));
    });

    test('scroll generates correct sequence', () {
      final result = encoder.scroll(10);
      expect(result, contains('"cmd":"scroll"'));
      expect(result, contains('"lines":10'));
    });

    test('scroll with windowId', () {
      final result = encoder.scroll(-5, windowId: 1);
      expect(result, contains('"lines":-5'));
      expect(result, contains('"window_id":1'));
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

    test('getConfig generates correct sequence', () {
      final result = encoder.getConfig();
      expect(result, contains('"cmd":"get_config"'));
    });

    test('getTerminfo generates correct sequence', () {
      final result = encoder.getTerminfo();
      expect(result, contains('"cmd":"get_terminal_attribute"'));
    });

    test('getTerminfo with name', () {
      final result = encoder.getTerminfo(name: 'cursor_shape');
      expect(result, contains('"attr":"cursor_shape"'));
    });

    test('getEnvironment generates correct sequence', () {
      final result = encoder.getEnvironment();
      expect(result, contains('"cmd":"get_environment"'));
    });

    test('getOs generates correct sequence', () {
      final result = encoder.getOs();
      expect(result, contains('"cmd":"get_os"'));
    });

    test('getAvailableLayouts generates correct sequence', () {
      final result = encoder.getAvailableLayouts();
      expect(result, contains('"cmd":"get_available_layouts"'));
    });

    test('getMouseButtons generates correct sequence', () {
      final result = encoder.getMouseButtons();
      expect(result, contains('"cmd":"get_pointer"'));
    });

    test('getKeyboardLeds generates correct sequence', () {
      final result = encoder.getKeyboardLeds();
      expect(result, contains('"cmd":"get_keyboard_leds"'));
    });
  });

  group('KittyRemoteControlEncoder - Advanced Window', () {
    test('setWindowSize generates correct sequence', () {
      final result = encoder.setWindowSize(width: 80, height: 24);
      expect(result, contains('"cmd":"set_window_size"'));
      expect(result, contains('"width":80'));
      expect(result, contains('"height":24'));
    });

    test('setWindowSize with windowId', () {
      final result = encoder.setWindowSize(width: 100, height: 40, windowId: 1);
      expect(result, contains('"window_id":1'));
    });

    test('setWindowPadding generates correct sequence', () {
      final result = encoder.setWindowPadding(left: 5, top: 5, right: 5, bottom: 5);
      expect(result, contains('"cmd":"set_window_padding"'));
      expect(result, contains('"left":5'));
    });

    test('setWindowPadding with partial', () {
      final result = encoder.setWindowPadding(left: 10);
      expect(result, contains('"left":10'));
      expect(result, isNot(contains('"top"')));
    });

    test('moveWindow generates correct sequence', () {
      final result = encoder.moveWindow(10, 20);
      expect(result, contains('"cmd":"move_window"'));
      expect(result, contains('"x":10'));
      expect(result, contains('"y":20'));
    });

    test('moveWindow with windowId', () {
      final result = encoder.moveWindow(0, 0, windowId: 1);
      expect(result, contains('"window_id":1'));
    });

    test('setWindowLogo generates correct sequence', () {
      final result = encoder.setWindowLogo('/path/to/logo.png');
      expect(result, contains('"cmd":"set_window_logo"'));
      expect(result, contains('"path":"/path/to/logo.png"'));
    });

    test('setWindowBackgroundOpacity generates correct sequence', () {
      final result = encoder.setWindowBackgroundOpacity(0.8);
      expect(result, contains('"cmd":"set_window_background_opacity"'));
      expect(result, contains('"opacity":0.8'));
    });
  });

  group('KittyRemoteControlEncoder - Tab Operations', () {
    test('detachTab generates correct sequence', () {
      final result = encoder.detachTab(1);
      expect(result, contains('"cmd":"detach_tab"'));
      expect(result, contains('"tab_id":1'));
    });

    test('moveTab generates correct sequence', () {
      final result = encoder.moveTab(1, 2);
      expect(result, contains('"cmd":"move_tab"'));
      expect(result, contains('"tab_id":1'));
      expect(result, contains('"to":2'));
    });

    test('previousTab generates correct sequence', () {
      final result = encoder.previousTab();
      expect(result, contains('"cmd":"previous_tab"'));
    });

    test('previousTab with tabId', () {
      final result = encoder.previousTab(tabId: 2);
      expect(result, contains('"tab_id":2'));
    });

    test('nextTab generates correct sequence', () {
      final result = encoder.nextTab();
      expect(result, contains('"cmd":"next_tab"'));
    });

    test('nextTab with tabId', () {
      final result = encoder.nextTab(tabId: 3);
      expect(result, contains('"tab_id":3'));
    });
  });

  group('KittyRemoteControlEncoder - OS Window Operations', () {
    test('newOsWindow generates correct sequence', () {
      final result = encoder.newOsWindow();
      expect(result, contains('"cmd":"new_os_window"'));
    });

    test('newOsWindow with all options', () {
      final result = encoder.newOsWindow(
        title: 'My Window',
        cwd: '/home',
        layout: 'stack',
        keepForeground: true,
      );
      expect(result, contains('"title":"My Window"'));
      expect(result, contains('"cwd":"/home"'));
      expect(result, contains('"layout":"stack"'));
      expect(result, contains('"keepForeground":true'));
    });

    test('closeOsWindow generates correct sequence', () {
      final result = encoder.closeOsWindow(1);
      expect(result, contains('"cmd":"close_os_window"'));
      expect(result, contains('"os_window_id":1'));
    });

    test('listOsWindows generates correct sequence', () {
      final result = encoder.listOsWindows();
      expect(result, contains('"cmd":"ls_os_windows"'));
    });

    test('focusOsWindow generates correct sequence', () {
      final result = encoder.focusOsWindow(2);
      expect(result, contains('"cmd":"focus_os_window"'));
      expect(result, contains('"os_window_id":2'));
    });
  });

  group('KittyRemoteControlEncoder - Advanced Operations', () {
    test('writeToClipboard generates correct sequence', () {
      final result = encoder.writeToClipboard('clip text');
      expect(result, contains('"cmd":"set_clipboard"'));
      expect(result, contains('"text":"clip text"'));
    });

    test('getImage generates correct sequence', () {
      final result = encoder.getImage();
      expect(result, contains('"cmd":"get_image"'));
    });

    test('getImage with imageId', () {
      final result = encoder.getImage(imageId: 1);
      expect(result, contains('"id":1'));
    });

    test('getImage with windowId', () {
      final result = encoder.getImage(windowId: 2);
      expect(result, contains('"window_id":2'));
    });

    test('reloadConfig generates correct sequence', () {
      final result = encoder.reloadConfig();
      expect(result, contains('"cmd":"reload_config"'));
    });

    test('showNotification generates correct sequence', () {
      final result = encoder.showNotification(message: 'Hello');
      expect(result, contains('"cmd":"show_notification"'));
      expect(result, contains('"message":"Hello"'));
    });

    test('showNotification with title', () {
      final result = encoder.showNotification(message: 'Body', title: 'Title');
      expect(result, contains('"title":"Title"'));
    });

    test('removeWatermark generates correct sequence', () {
      final result = encoder.removeWatermark();
      expect(result, contains('"cmd":"remove_watermark"'));
    });

    test('setColor generates correct sequence', () {
      final result = encoder.setColor(colorNumber: 1, color: '#ff0000');
      expect(result, contains('"cmd":"set_colors"'));
      expect(result, contains('"1":"#ff0000"'));
    });

    test('signalProcess generates correct sequence', () {
      final result = encoder.signalProcess(pid: 1234, signal: 'TERM');
      expect(result, contains('"cmd":"signal_child"'));
      expect(result, contains('"pid":1234'));
      expect(result, contains('"signal":"TERM"'));
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

  group('KittyRemoteControlEncoder - Extra Options', () {
    test('buildCommand with kittyWindowId', () {
      final result = encoder.buildCommand(
        command: 'ls',
        kittyWindowId: 'win1',
      );
      expect(result, contains('"kitty_window_id":"win1"'));
    });

    test('setWindowTitle with windowId', () {
      final result = encoder.setWindowTitle('Title', windowId: 2);
      expect(result, contains('"window_id":2'));
    });

    test('newTab with title and cwd', () {
      final result = encoder.newTab(title: 'My Tab', cwd: '/home');
      expect(result, contains('"title":"My Tab"'));
      expect(result, contains('"cwd":"/home"'));
    });

    test('setTabTitle with tabId', () {
      final result = encoder.setTabTitle('New Title', tabId: 3);
      expect(result, contains('"tab_id":3'));
    });

    test('getCwd with windowId uses payload', () {
      final result = encoder.getCwd(windowId: 1);
      expect(result, contains('"window_id":1'));
    });

    test('getPid with windowId uses payload', () {
      final result = encoder.getPid(windowId: 2);
      expect(result, contains('"window_id":2'));
    });

    test('setLayout with windowId', () {
      final result = encoder.setLayout('stack', windowId: 1);
      expect(result, contains('"window_id":1'));
    });

    test('resizeWindow with windowId', () {
      final result = encoder.resizeWindow(80, 24, windowId: 1);
      expect(result, contains('"window_id":1'));
    });

    test('setWindowPadding with windowId', () {
      final result = encoder.setWindowPadding(left: 5, windowId: 1);
      expect(result, contains('"window_id":1'));
    });

    test('setWindowLogo with windowId', () {
      final result = encoder.setWindowLogo('/logo.png', windowId: 1);
      expect(result, contains('"window_id":1'));
    });

    test('setWindowBackgroundOpacity with windowId', () {
      final result = encoder.setWindowBackgroundOpacity(0.5, windowId: 2);
      expect(result, contains('"window_id":2'));
    });
  });
}
