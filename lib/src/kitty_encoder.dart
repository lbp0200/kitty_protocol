import 'package:flutter/services.dart';
import 'kitty_key_codes.dart';
import 'kitty_modifier_codes.dart';
import 'kitty_flags.dart';

/// Simple key event class to represent keyboard events
class SimpleKeyEvent {
  final LogicalKeyboardKey logicalKey;
  final Set<SimpleModifier> modifiers;

  const SimpleKeyEvent({
    required this.logicalKey,
    this.modifiers = const {},
  });
}

/// Simple modifier enum for key events
enum SimpleModifier {
  shift,
  control,
  alt,
  meta,
}

/// Kitty Encoder - converts Flutter KeyEvent to Kitty escape sequences
class KittyEncoder {
  final KittyEncoderFlags flags;

  const KittyEncoder({this.flags = const KittyEncoderFlags()});

  bool get isExtendedMode => flags.isExtendedMode;

  String encode(SimpleKeyEvent event) {
    final keyCode = KittyKeyCodes.getKeyCode(event.logicalKey);
    if (keyCode == null) {
      return '';
    }

    final modifierFlags = _extractModifiers(event);
    final modifiers = KittyModifierCodes.calculateModifiers(modifierFlags);

    // Apply modifier-specific key code offset per Kitty protocol
    int effectiveKeyCode = keyCode;
    if (modifierFlags & KittyModifierCodes.ctrl != 0) {
      effectiveKeyCode -= 15; // Ctrl offsets key code by -15
    } else if (modifierFlags & KittyModifierCodes.shift != 0) {
      effectiveKeyCode -= 20; // Shift offsets key code by -20
    } else if (modifierFlags & KittyModifierCodes.alt != 0) {
      effectiveKeyCode -= 10; // Alt offsets key code by -10
    }

    if (flags.isExtendedMode) {
      final csiValue = flags.toCSIValue();
      return '\x1b[>$csiValue;$effectiveKeyCode;${modifiers}u';
    }

    return '\x1b[$effectiveKeyCode;${modifiers}u';
  }

  int _extractModifiers(SimpleKeyEvent event) {
    int flags = 0;

    if (event.modifiers.contains(SimpleModifier.shift) ||
        event.logicalKey == LogicalKeyboardKey.shiftLeft ||
        event.logicalKey == LogicalKeyboardKey.shiftRight) {
      flags |= KittyModifierCodes.shift;
    }

    if (event.modifiers.contains(SimpleModifier.alt) ||
        event.logicalKey == LogicalKeyboardKey.altLeft ||
        event.logicalKey == LogicalKeyboardKey.altRight) {
      flags |= KittyModifierCodes.alt;
    }

    if (event.modifiers.contains(SimpleModifier.control) ||
        event.logicalKey == LogicalKeyboardKey.controlLeft ||
        event.logicalKey == LogicalKeyboardKey.controlRight) {
      flags |= KittyModifierCodes.ctrl;
    }

    if (event.modifiers.contains(SimpleModifier.meta) ||
        event.logicalKey == LogicalKeyboardKey.metaLeft ||
        event.logicalKey == LogicalKeyboardKey.metaRight) {
      flags |= KittyModifierCodes.superKey;
    }

    return flags;
  }

  KittyEncoder withFlags(KittyEncoderFlags newFlags) {
    return KittyEncoder(flags: newFlags);
  }
}
