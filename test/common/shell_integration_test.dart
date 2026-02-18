/// Shell Integration Protocol Tests
///
/// Tests for Kitty Shell Integration encoder (OSC 133)
///
/// Reference: doc/kitty/docs/shell-integration.rst
library kitty_protocol_shell_integration_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  group('KittyShellIntegration - Prompt Marks', () {
    test('markPromptStart generates correct OSC 133 sequence', () {
      final result = KittyShellIntegration.markPromptStart();
      expect(result, contains('\x1b]133;'));
      expect(result, contains('A'));
      expect(result, contains('\x1b\\'));
    });

    test('markPromptStart with redraw option', () {
      final result = KittyShellIntegration.markPromptStart(redraw: true);
      expect(result, contains('redraw=0'));
    });

    test('markPromptStart with specialKey option', () {
      final result = KittyShellIntegration.markPromptStart(specialKey: true);
      expect(result, contains('special_key=1'));
    });

    test('markPromptStart with clickEvents option', () {
      final result = KittyShellIntegration.markPromptStart(clickEvents: true);
      expect(result, contains('click_events=1'));
    });

    test('markPromptStart with clickEventsRelative option', () {
      final result = KittyShellIntegration.markPromptStart(clickEventsRelative: true);
      expect(result, contains('click_events=2'));
    });

    test('markSecondaryPromptStart generates correct sequence', () {
      final result = KittyShellIntegration.markSecondaryPromptStart();
      expect(result, contains('A;k=s'));
    });
  });

  group('KittyShellIntegration - Command Marks', () {
    test('markCommandStart generates correct sequence', () {
      final result = KittyShellIntegration.markCommandStart();
      expect(result, contains('C'));
    });

    test('markCommandStart with commandLine', () {
      final result = KittyShellIntegration.markCommandStart(commandLine: 'ls -la');
      expect(result, contains('C'));
      expect(result, contains('cmdline='));
    });

    test('markCommandStartUrlEncoded generates URL-encoded sequence', () {
      final result = KittyShellIntegration.markCommandStartUrlEncoded('ls -la');
      expect(result, contains('cmdline_url='));
    });

    test('markCommandEnd generates correct sequence', () {
      final result = KittyShellIntegration.markCommandEnd();
      expect(result, contains('D'));
    });

    test('markCommandEnd with exitStatus', () {
      final result = KittyShellIntegration.markCommandEnd(exitStatus: 0);
      expect(result, contains('D;0'));
    });

    test('markCommandEndWithStatus generates sequence with status', () {
      final result = KittyShellIntegration.markCommandEndWithStatus(KittyShellExitStatus.success);
      expect(result, contains('D;0'));
    });
  });

  group('KittyShellIntegration - Convenience Methods', () {
    test('commandSuccess generates sequence with exit 0', () {
      final result = KittyShellIntegration.commandSuccess();
      expect(result, contains('D;0'));
    });

    test('commandFailed generates sequence with exit 1', () {
      final result = KittyShellIntegration.commandFailed();
      expect(result, contains('D;1'));
    });

    test('commandFailed with exitCode', () {
      final result = KittyShellIntegration.commandFailed(exitCode: 127);
      expect(result, contains('D;127'));
    });

    test('promptPrimary is alias for markPromptStart', () {
      final result = KittyShellIntegration.promptPrimary();
      expect(result, contains('A'));
    });

    test('promptSecondary is alias for markSecondaryPromptStart', () {
      final result = KittyShellIntegration.promptSecondary();
      expect(result, contains('A;k=s'));
    });
  });

  group('KittyShellIntegration - Constants', () {
    test('oscCode is 133', () {
      expect(KittyShellIntegration.oscCode, 133);
    });
  });

  group('KittyShellExitStatus - Enum Values', () {
    test('success has value 0', () {
      expect(KittyShellExitStatus.success.value, 0);
    });

    test('failed has value 1', () {
      expect(KittyShellExitStatus.failed.value, 1);
    });

    test('interrupted has value 130', () {
      expect(KittyShellExitStatus.interrupted.value, 130);
    });

    test('notFound has value 127', () {
      expect(KittyShellExitStatus.notFound.value, 127);
    });
  });
}
