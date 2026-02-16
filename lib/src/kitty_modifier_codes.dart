/// Modifier bit flags per Kitty Keyboard Protocol spec
class KittyModifierCodes {
  static const int shift = 1;
  static const int alt = 2;
  static const int ctrl = 4;
  static const int superKey = 8;
  static const int hyper = 16;
  static const int meta = 32;

  /// Calculate modifier value with +1 offset per Kitty spec
  /// to avoid ambiguity with 0 (no modifiers)
  static int calculateModifiers(int modifierFlags) {
    return modifierFlags + 1;
  }
}
