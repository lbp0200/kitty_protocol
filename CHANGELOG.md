## 1.3.1

- Test: Add 138 tests across all modules (581 total), line coverage 77.8% → 97.9%
- Test: Add comprehensive C0 control code mapping tests (all 18 mappings)
- Test: Cover all remote control methods (35+ previously untested)
- Test: Cover graphics query/placement/transmitAndDisplay methods
- Test: Cover error paths (invalid hex/OKLCH/LAB parsing)
- Test: Cover edge cases (empty text, metadata-only, invalid formats)
- Chore: Add analysis_options.yaml with Flutter lint configuration
- Chore: Fix .gitignore to exclude docs/kitty/ directory
- Fix: Remove unnecessary braces in string interpolation
- Fix: Rename local variable with leading underscore in graphics encoder

## 1.3.0

- Feat: Add zlib compression support for graphics protocol (encodeRgba/encodeRgb with compress: true)
- Fix: Clipboard osc52Read primary selection now returns 'p' instead of 'c'
- Fix: Notifications 'id' parameter no longer silently overwritten by 'sessionId'
- Fix: Keyboard \_isPrintableKey now uses keyLabel for reliable cross-platform detection
- Fix: Graphics deleteInRegion now includes endX/endY in output
- Fix: Remove dead code (keyboard unreachable branch, graphics freeData params)
- Test: Add 27 tests for KittyEncoderBase/KittyProtocolConstants
- Test: Add tests for graphics enums, placeholders, Base64 edge cases, chunking edge cases
- Test: Add tests for deleteByZIndex, deleteAtPosition, querySupport
- Test: Add keyboard extended mode without reportEvent coverage

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
