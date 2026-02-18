/// Notifications Protocol Tests
///
/// Tests for Kitty Notification encoder (OSC 99 and OSC 777)
///
/// Reference: doc/kitty/docs/desktop-notifications.rst
library kitty_protocol_notification_test;

import 'package:flutter_test/flutter_test.dart';
import 'package:kitty_protocol/kitty_protocol.dart';

void main() {
  const encoder = KittyNotificationEncoder();

  group('KittyNotificationEncoder - OSC 99 Basic', () {
    test('sendSimple generates correct sequence', () {
      final result = encoder.sendSimple('Hello World');
      expect(result, contains('\x1b]99;'));
      expect(result, contains('Hello World'));
      expect(result, contains('\x1b\\'));
    });

    test('send with title generates correct sequence', () {
      final result = encoder.send(title: 'Test Title');
      expect(result, contains('\x1b]99;'));
      expect(result, contains('p=title'));
    });

    test('send with body generates correct sequence', () {
      final result = encoder.send(body: 'Test Body');
      expect(result, contains('p=body'));
    });

    test('send with id generates correct sequence', () {
      final result = encoder.send(title: 'Test', id: 'my-id');
      expect(result, contains('i=my-id'));
    });

    test('send with urgency generates correct sequence', () {
      final result = encoder.send(
        title: 'Test',
        urgency: KittyNotificationUrgency.critical,
      );
      expect(result, contains('u=2'));
    });

    test('send with occasion generates correct sequence', () {
      final result = encoder.send(
        title: 'Test',
        occasion: KittyNotificationOccasion.unfocused,
      );
      expect(result, contains('o=unfocused'));
    });

    test('send with encoded flag generates correct sequence', () {
      final result = encoder.send(
        title: 'Test',
        encoded: true,
      );
      expect(result, contains('e=1'));
    });

    test('send with application name generates correct sequence', () {
      final result = encoder.send(
        title: 'Test',
        applicationName: 'MyApp',
      );
      expect(result, contains('f=MyApp'));
    });

    test('send with icon name generates correct sequence', () {
      final result = encoder.send(
        title: 'Test',
        iconName: 'error',
      );
      expect(result, contains('n=error'));
    });

    test('send with expire timeout generates correct sequence', () {
      final result = encoder.send(
        title: 'Test',
        expireTimeout: 5000,
      );
      expect(result, contains('w=5000'));
    });

    test('send with request close event generates correct sequence', () {
      final result = encoder.send(
        title: 'Test',
        requestCloseEvent: true,
      );
      expect(result, contains('c=1'));
    });
  });

  group('KittyNotificationEncoder - Close/Query', () {
    test('close generates correct sequence', () {
      final result = encoder.close('notification-id');
      expect(result, contains('\x1b]99;'));
      expect(result, contains('p=close'));
    });

    test('querySupport generates correct sequence', () {
      final result = encoder.querySupport();
      expect(result, contains('\x1b]99;'));
      expect(result, contains('p=?'));
    });

    test('querySupport with session id generates correct sequence', () {
      final result = encoder.querySupport(sessionId: 'my-session');
      expect(result, contains('i=my-session'));
    });

    test('queryAlive generates correct sequence', () {
      final result = encoder.queryAlive();
      expect(result, contains('p=alive'));
    });
  });

  group('KittyNotificationEncoder - Convenience Methods', () {
    test('notify with title only generates complete sequence', () {
      final result = encoder.notify(title: 'Test Title');
      expect(result, isNotEmpty);
      // Should contain both the title and isDone marker
      expect(result, contains('p=title'));
    });

    test('notify with title and body generates multiple sequences', () {
      final result = encoder.notify(title: 'Title', body: 'Body');
      // Should contain both title and body
      expect(result, contains('p=title'));
      expect(result, contains('p=body'));
    });
  });

  group('KittyNotificationEncoder - Constants', () {
    test('oscCode is correct', () {
      expect(KittyNotificationEncoder.oscCode, 99);
    });

    test('maxPayloadSize is defined', () {
      expect(KittyNotificationEncoder.maxPayloadSize, 2048);
    });
  });

  group('KittyNotificationEncoder - Enums', () {
    test('KittyNotificationPayload has correct values', () {
      expect(KittyNotificationPayload.title.value, 'title');
      expect(KittyNotificationPayload.body.value, 'body');
      expect(KittyNotificationPayload.close.value, 'close');
      expect(KittyNotificationPayload.query.value, '?');
      expect(KittyNotificationPayload.alive.value, 'alive');
    });

    test('KittyNotificationAction has correct values', () {
      expect(KittyNotificationAction.report.value, 'report');
      expect(KittyNotificationAction.focus.value, 'focus');
    });

    test('KittyNotificationUrgency has correct values', () {
      expect(KittyNotificationUrgency.low.value, 0);
      expect(KittyNotificationUrgency.normal.value, 1);
      expect(KittyNotificationUrgency.critical.value, 2);
    });

    test('KittyNotificationOccasion has correct values', () {
      expect(KittyNotificationOccasion.always.value, 'always');
      expect(KittyNotificationOccasion.unfocused.value, 'unfocused');
      expect(KittyNotificationOccasion.invisible.value, 'invisible');
    });
  });

  group('KittyNotificationEncoder - Static Helpers', () {
    test('buildActions generates correct string', () {
      final result = KittyNotificationEncoder.buildActions(report: true, focus: true);
      expect(result, contains('report'));
      expect(result, contains('focus'));
    });
  });

  group('KittyNotificationEncoder - Sound/Icon Constants', () {
    test('notification sounds are defined', () {
      expect(KittyNotificationSounds.system, 'system');
      expect(KittyNotificationSounds.silent, 'silent');
      expect(KittyNotificationSounds.error, 'error');
      expect(KittyNotificationSounds.warning, 'warning');
    });

    test('notification icons are defined', () {
      expect(KittyNotificationIcons.error, 'error');
      expect(KittyNotificationIcons.warning, 'warn');
      expect(KittyNotificationIcons.info, 'info');
    });
  });

  group('KittyNotification777 - OSC 777', () {
    test('notify generates correct sequence', () {
      final result = KittyNotification777.notify(body: 'Test');
      expect(result, contains('\x1b]777;'));
      expect(result, contains('notify'));
      expect(result, contains('Test'));
    });

    test('notify with title generates correct sequence', () {
      final result = KittyNotification777.notify(title: 'Title', body: 'Body');
      expect(result, contains('notify'));
    });

    test('close generates correct sequence', () {
      final result = KittyNotification777.close(123);
      expect(result, contains('\x1b]777;'));
      expect(result, contains('close'));
      expect(result, contains('123'));
    });

    test('list generates correct sequence', () {
      final result = KittyNotification777.list();
      expect(result, contains('\x1b]777;'));
      expect(result, contains('list'));
    });

    test('supported generates correct sequence', () {
      final result = KittyNotification777.supported();
      expect(result, contains('\x1b]777;'));
      expect(result, contains('?'));
    });
  });
}
