## 1.2.3

- Ci: Use dart-lang/setup-dart reusable workflow for OIDC publishing

## 1.2.2

- Fix: Use `flutter pub publish` instead of `flutter publish` in CI/CD
- Fix: Add OIDC permissions for secure publishing to pub.dev
- Fix: Use sed instead of cut for version extraction robustness
- Feat: Add test coverage reporting in CI (`--coverage`)
- Feat: Add publish dry-run check before publishing
- Feat: Add TDD requirements and verification checklist to CLAUDE.md
- Chore: Use built-in cache instead of manual actions/cache

## 1.1.0

- Fix: Use Unicode codepoints per Kitty Keyboard Protocol spec
  - Enter=13 (was 28), Tab=9 (was 29), Escape=27 (was 53), Backspace=127 (was 27), Space=32 (was 44)
- Fix: Remove incorrect offset subtraction logic that produced negative numbers
- Fix: Add C0 control code mapping for Ctrl+letter combinations (Ctrl+a->1, Ctrl+b->2, etc.)
- Fix: Proper modifier encoding: 1 + bit_flags (Shift=1, Alt=2, Ctrl=4)
- Fix: When Shift is pressed with Ctrl, don't apply C0 mapping (use base codepoint)
- Docs: Add protocol documentation comments referencing official spec
- Test: Add comprehensive protocol compliance test suite

## 1.0.0

- Initial release
- Full key mapping: F1-F12, arrow keys, navigation keys
- Modifier support: Shift, Alt, Ctrl, Meta with proper bit flag handling
- Progressive enhancement: Support for Kitty protocol's extended modes (CSI > n u)
- IME handling: Optional deferral for complex input scenarios
- Key release events: Optional reporting of key release events
- Key repeat support: Full event type reporting (keyDown, keyRepeat, keyUp)
