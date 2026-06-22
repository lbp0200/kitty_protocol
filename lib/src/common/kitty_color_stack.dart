/// Kitty Color Stack - Color push/pop for Kitty Protocol
///
/// Reference: docs/kitty/docs/color-stack.rst
/// Color stack operations
enum KittyColorStackOperation {
  /// Push current colors onto stack
  push(30001),
  /// Pop colors from stack
  pop(30101);

  final int oscCode;
  const KittyColorStackOperation(this.oscCode);
}

/// Color stack encoder
///
/// Per protocol lines 14-21:
///
/// Push colors:
///   `<ESC>]30001<ESC>`
/// Pop colors:
///   `<ESC>]30101<ESC>`
class KittyColorStack {
  KittyColorStack._();

  /// Push current colors onto stack
  ///
/// Per protocol line 16:
///   `<ESC>]30001<ESC>`
  static String push() {
    return '\x1b]${KittyColorStackOperation.push.oscCode}\x1b\\';
  }

  /// Pop colors from stack
  ///
/// Per protocol line 17:
///   `<ESC>]30101<ESC>`
  static String pop() {
    return '\x1b]${KittyColorStackOperation.pop.oscCode}\x1b\\';
  }

  /// Push and later pop (for use in try-finally)
  static String pushScope() => push();
  static String popScope() => pop();
}
