/// Kitty Notification Encoder - Desktop notifications for Kitty Protocol
///
/// Reference: doc/kitty/docs/desktop-notifications.rst
library kitty_protocol_notification_encoder;

import 'dart:convert';

/// Notification payload types
enum KittyNotificationPayload {
  /// Set notification title
  title('title'),
  /// Set notification body
  body('body'),
  /// Close notification
  close('close'),
  /// Query support
  query('?'),
  /// Check if notification is alive
  alive('alive'),
  /// Icon data
  icon('icon'),
  /// Buttons
  buttons('buttons');

  final String value;
  const KittyNotificationPayload(this.value);
}

/// Notification action types
enum KittyNotificationAction {
  /// Report back when activated
  report('report'),
  /// Focus window when activated
  focus('focus');

  final String value;
  const KittyNotificationAction(this.value);
}

/// Notification urgency levels
enum KittyNotificationUrgency {
  /// Low urgency
  low(0),
  /// Normal urgency
  normal(1),
  /// Critical urgency
  critical(2);

  final int value;
  const KittyNotificationUrgency(this.value);
}

/// When to honor notification requests
enum KittyNotificationOccasion {
  /// Always show notification
  always('always'),
  /// Show when window is unfocused
  unfocused('unfocused'),
  /// Show when window is unfocused and invisible
  invisible('invisible');

  final String value;
  const KittyNotificationOccasion(this.value);
}

/// Standard notification sounds
class KittyNotificationSounds {
  static const String system = 'system';
  static const String silent = 'silent';
  static const String error = 'error';
  static const String warning = 'warning';
  static const String info = 'info';
  static const String question = 'question';
}

/// Standard icon names
class KittyNotificationIcons {
  static const String error = 'error';
  static const String warning = 'warn';
  static const String info = 'info';
  static const String question = 'question';
  static const String help = 'help';
  static const String fileManager = 'file-manager';
  static const String systemMonitor = 'system-monitor';
  static const String textEditor = 'text-editor';
}

/// Notification Encoder for Kitty Protocol
///
/// Implements OSC 99 for desktop notifications.
///
/// Format:
///   <OSC>99;metadata;payload<ST>
///
/// Example:
///   printf '\x1b]99;i=1:d=0;Hello world\x1b\\'
class KittyNotificationEncoder {
  /// OSC code for notifications
  static const int oscCode = 99;

  /// Maximum payload size before encoding
  static const int maxPayloadSize = 2048;

  const KittyNotificationEncoder();

  /// Build OSC 99 sequence
  String _buildSequence({
    required String metadata,
    String? payload,
  }) {
    if (payload != null && payload.isNotEmpty) {
      return '\x1b]$oscCode;$metadata;$payload\x1b\\';
    }
    return '\x1b]$oscCode;$metadata\x1b\\';
  }

  /// Encode metadata key-value pairs
  String _encodeMetadata(Map<String, String> params) {
    final pairs = <String>[];
    params.forEach((key, value) {
      if (value.isNotEmpty) {
        pairs.add('$key=$value');
      }
    });
    return pairs.join(':');
  }

  /// Encode string as base64
  String _encodeBase64(String input) {
    return base64Encode(utf8.encode(input));
  }

  /// Send a simple notification
  ///
  /// Per protocol line 31:
  ///   printf '\x1b]99;;Hello world\x1b\\'
  String sendSimple(String message) {
    return _buildSequence(metadata: '', payload: message);
  }

  /// Send notification with title and body
  ///
  /// Per protocol lines 33-36:
  ///   printf '\x1b]99;i=1:d=0;Hello world\x1b\\'
  ///   printf '\x1b]99;i=1:p=body;This is cool\x1b\\'
  String send({
    String? id,
    String? title,
    String? body,
    bool isDone = true,
    bool encoded = false,
    String? applicationName,
    String? iconName,
    String? notificationType,
    KittyNotificationUrgency? urgency,
    KittyNotificationOccasion? occasion,
    int? expireTimeout,
    bool requestCloseEvent = false,
    String? actions,
    String? sound,
    String? sessionId,
  }) {
    // Build metadata
    final metadata = _encodeMetadata({
      if (id != null) 'i': id,
      if (sessionId != null) 'i': sessionId,
      'd': isDone ? '1' : '0',
      if (encoded) 'e': '1',
      if (applicationName != null) 'f': applicationName,
      if (iconName != null) 'n': iconName,
      if (notificationType != null) 't': notificationType,
      if (urgency != null) 'u': urgency.value.toString(),
      if (occasion != null) 'o': occasion.value,
      if (expireTimeout != null) 'w': expireTimeout.toString(),
      if (requestCloseEvent) 'c': '1',
      if (actions != null) 'a': actions,
      if (sound != null) 's': sound,
    });

    // Determine payload type and content
    String? payload;
    if (title != null) {
      payload = encoded ? _encodeBase64(title) : title;
      return _buildSequence(metadata: '$metadata:p=${KittyNotificationPayload.title.value}', payload: payload);
    } else if (body != null) {
      payload = encoded ? _encodeBase64(body) : body;
      return _buildSequence(metadata: '$metadata:p=${KittyNotificationPayload.body.value}', payload: payload);
    }

    // If no title/body, just send the metadata
    return _buildSequence(metadata: metadata);
  }

  /// Close a notification
  ///
  /// Per protocol lines 192-198:
  ///   <OSC> i=<notification id> : p=close ; <terminator>
  String close(String? notificationId) {
    return _buildSequence(
      metadata: _encodeMetadata({
        if (notificationId != null) 'i': notificationId,
        'p': KittyNotificationPayload.close.value,
      }),
    );
  }

  /// Query for support
  ///
  /// Per protocol lines 376-384:
  ///   <OSC> 99 ; i=<id> : p=? ; <terminator>
  String querySupport({String? sessionId}) {
    return _buildSequence(
      metadata: _encodeMetadata({
        if (sessionId != null) 'i': sessionId,
        'p': KittyNotificationPayload.query.value,
      }),
    );
  }

  /// Query alive notifications
  ///
  /// Per protocol lines 163-172:
  ///   <OSC> 99 ; i=myid : p=alive ; <terminator>
  String queryAlive({String? sessionId}) {
    return _buildSequence(
      metadata: _encodeMetadata({
        if (sessionId != null) 'i': sessionId,
        'p': KittyNotificationPayload.alive.value,
      }),
    );
  }

  /// Build actions string
  static String buildActions({
    bool report = false,
    bool focus = true,
  }) {
    final actions = <String>[];
    if (report) actions.add(KittyNotificationAction.report.value);
    if (focus) actions.add(KittyNotificationAction.focus.value);
    return actions.join(',');
  }

  /// Convenience: Build notification with common options
  String notify({
    required String title,
    String? body,
    String? id,
    bool requestCloseEvent = false,
  }) {
    // Send title first
    var result = send(
      id: id,
      title: title,
      isDone: body == null,
    );

    // Then body if present
    if (body != null) {
      result += send(
        id: id,
        body: body,
        isDone: true,
        requestCloseEvent: requestCloseEvent,
      );
    }

    return result;
  }
}

/// OSC 777 Notification Encoder
///
/// Per changelog.rst line 2251:
/// Some terminals (like urxvt) use OSC 777 for notifications
///
/// Format: <OSC>777;<command>;<args><ST>
class KittyNotification777 {
  KittyNotification777._();

  /// OSC 777 code
  static const int oscCode = 777;

  /// Notification subcommands
  static String notify({
    String? title,
    required String body,
    bool encode = false,
  }) {
    final cmd = StringBuffer('notify');
    if (title != null) {
      cmd.write(';${encode ? _encodeArg(title) : title}');
      cmd.write(';${encode ? _encodeArg(body) : body}');
    } else {
      cmd.write(';$body');
    }
    return '\x1b]$oscCode;${cmd.toString()}\x1b\\';
  }

  /// Close notification
  static String close(int notificationId) {
    return '\x1b]$oscCode;close;$notificationId\x1b\\';
  }

  /// List active notifications
  static String list() {
    return '\x1b]$oscCode;list\x1b\\';
  }

  /// Check notification support
  static String supported() {
    return '\x1b]$oscCode;?\x1b\\';
  }

  static String _encodeArg(String arg) {
    // Simple encoding - in practice would use base64
    return Uri.encodeComponent(arg);
  }
}
