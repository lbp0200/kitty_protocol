/// Kitty Shell Integration Marks - OSC 133 for shell prompt marking
///
/// Reference: doc/kitty/docs/shell-integration.rst
///
/// This module provides escape sequences for marking shell prompts,
/// allowing terminals to track command boundaries for features like:
/// - Jump to previous/next prompt
/// - Click to move cursor to prompt
/// - Browse command output
library kitty_protocol_shell_integration;

/// Shell integration exit status
///
/// Per shell-integration.rst line 446:
///   <OSC>133;D;exit status as base 10 integer<ST>
enum KittyShellExitStatus {
  /// Command succeeded (exit code 0)
  success(0),

  /// Command failed (non-zero exit code)
  failed(1),

  /// Command was interrupted
  interrupted(130),

  /// Command not found
  notFound(127);

  final int value;
  const KittyShellExitStatus(this.value);
}

/// Shell Integration Marks encoder
///
/// Per shell-integration.rst lines 420-451:
///
/// <OSC>133;A<ST> - Primary prompt (PS1)
/// <OSC>133;A;k=s<ST> - Secondary prompt (PS2)
/// <OSC>133;C<ST> - Command start
/// <OSC>133;D;exit_status<ST> - Command end
class KittyShellIntegration {
  KittyShellIntegration._();

  /// OSC code
  static const int oscCode = 133;

  /// Create OSC sequence with proper terminator
  static String _osc(String params) {
    return '\x1b]$oscCode;$params\x1b\\';
  }

  // ============ Prompt Marks ============

  /// Mark primary prompt start (PS1)
  ///
  /// Per shell-integration.rst line 428:
  ///   <OSC>133;A<ST>
  static String markPromptStart({
    bool redraw = false,
    bool specialKey = false,
    bool clickEvents = false,
    bool clickEventsRelative = false,
  }) {
    final params = StringBuffer('A');
    if (redraw) params.write(';redraw=0');
    if (specialKey) params.write(';special_key=1');
    if (clickEvents) params.write(';click_events=1');
    if (clickEventsRelative) params.write(';click_events=2');
    return _osc(params.toString());
  }

  /// Mark secondary prompt start (PS2)
  ///
  /// Per shell-integration.rst line 434:
  ///   <OSC>133;A;k=s<ST>
  static String markSecondaryPromptStart() {
    return _osc('A;k=s');
  }

  // ============ Command Marks ============

  /// Mark command execution start
  ///
  /// Per shell-integration.rst line 440:
  ///   <OSC>133;C<ST>
  static String markCommandStart({String? commandLine}) {
    if (commandLine != null) {
      // Encode command line as per line 491
      final encoded = Uri.encodeComponent(commandLine);
      return _osc('C;cmdline=$encoded');
    }
    return _osc('C');
  }

  /// Mark command execution start with URL-encoded command line
  ///
  /// Per shell-integration.rst line 493:
  ///   <OSC>133;C;cmdline_url=cmdline as UTF-8 URL %-escaped<ST>
  static String markCommandStartUrlEncoded(String commandLine) {
    final encoded = Uri.encodeComponent(commandLine);
    return _osc('C;cmdline_url=$encoded');
  }

  /// Mark command execution end
  ///
  /// Per shell-integration.rst line 446:
  ///   <OSC>133;D;exit status as base 10 integer<ST>
  static String markCommandEnd({int? exitStatus}) {
    if (exitStatus != null) {
      return _osc('D;$exitStatus');
    }
    return _osc('D');
  }

  /// Mark command end with explicit exit status
  static String markCommandEndWithStatus(KittyShellExitStatus status) {
    return markCommandEnd(exitStatus: status.value);
  }

  // ============ Convenience Methods ============

  /// Quick method for marking a successful command
  static String commandSuccess() {
    return markCommandEnd(exitStatus: 0);
  }

  /// Quick method for marking a failed command
  static String commandFailed({int? exitCode}) {
    return markCommandEnd(exitStatus: exitCode ?? 1);
  }

  /// Quick method for marking the primary prompt
  static String promptPrimary() {
    return markPromptStart();
  }

  /// Quick method for marking the secondary prompt
  static String promptSecondary() {
    return markSecondaryPromptStart();
  }
}
