# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`kitty_protocol` is a comprehensive Dart/Flutter package that implements the **Kitty Terminal Protocols** family. It provides encoders for all Kitty Protocol escape sequences (CSI, OSC, APC, DCS) for terminal emulator development.

**Package Name**: `kitty_protocol`
**Reference**: https://sw.kovidgoyal.net/kitty/

### Protocol Documentation

All protocol implementations are based on the official Kitty documentation:

- **Local Docs**: `docs/kitty/docs/`
- **Keyboard Protocol**: `doc/kitty/docs/keyboard-protocol.rst`
- **Graphics Protocol**: `doc/kitty/docs/graphics-protocol.rst`
- **Text Sizing Protocol**: `doc/kitty/docs/text-sizing-protocol.rst`
- **File Transfer Protocol**: `doc/kitty/docs/file-transfer-protocol.rst`
- **Shell Integration**: `doc/kitty/docs/shell-integration.rst`
- **Remote Control Protocol**: `doc/kitty/docs/rc_protocol.rst`
- **Wide Gamut Colors**: `doc/kitty/docs/wide-gamut-colors.rst`
- **Misc Protocol**: `doc/kitty/docs/misc-protocol.rst`

## Commands

```bash
# Get dependencies
flutter pub get

# Analyze code (must pass with 0 issues)
flutter analyze

# Run tests
flutter test
```

## Architecture

The package consists of **19 core modules**:

### Protocol Modules

| Module | File | Description |
|--------|------|-------------|
| Keyboard | `lib/src/keyboard/` | CSI keyboard encoding |
| Graphics | `lib/src/graphics/` | APC image transmission |
| Text Sizing | `lib/src/text_sizing/` | OSC text scaling |
| File Transfer | `lib/src/file_transfer/` | OSC 5113 file transfer |
| Clipboard | `lib/src/clipboard/` | OSC 52/5522 clipboard |
| Notifications | `lib/src/notifications/` | OSC 99/777 notifications |
| Remote Control | `lib/src/remote_control/` | DCS JSON commands |

### Common Modules

| Module | File | Description |
|--------|------|-------------|
| Hyperlinks | `lib/src/common/kitty_hyperlinks.dart` | OSC 8 hyperlinks |
| Color Stack | `lib/src/common/kitty_color_stack.dart` | OSC 30001/30101 |
| Pointer Shapes | `lib/src/common/kitty_pointer_shapes.dart` | OSC 22 |
| Styled Underlines | `lib/src/common/kitty_underline.dart` | CSI 4:3 + SGR 58/59 |
| Shell Integration | `lib/src/common/kitty_shell_integration.dart` | OSC 133 marks |
| Wide Gamut Colors | `lib/src/common/kitty_wide_gamut_colors.dart` | OKLCH/LAB SGR |
| Misc Protocol | `lib/src/common/kitty_misc_protocol.dart` | SGR 221/222/1004/2004, DECSC/DECRC |

### Key Design Decisions

1. **Encoder-only Architecture**: Pure encoding library, no decoding
2. **Unicode Codepoints**: Uses Unicode codepoints (Enter=13, Tab=9), NOT USB HID codes
3. **Modifier Offset**: Uses bit flags (Shift=1, Alt=2, Ctrl=4) with +1 offset per Kitty spec
4. **Escape Sequence Format**:
   - Standard: `\x1b[key;mods]u`
   - Extended: `\x1b[>flags;key;mods]u`

### Kitty Protocol Key Points

- Modifier values use +1 offset: Shift=2, Ctrl=5, etc.
- Functional keys: F1=11, F2=12, ... F12=24
- Navigation: Up=30, Down=31, Right=32, Left=33
- C0 control codes for Ctrl+letter: Ctrl+a=1, Ctrl+b=2, ..., Ctrl+z=26

## Critical Implementation Details

### Base64 Encoding
- All binary data must be Base64 encoded per RFC 4648
- The `KittyGraphicsEncoder.encodeBase64()` is fully implemented

### DCS JSON Escaping
- Remote Control JSON must escape ESC character (`\x1b`) to prevent DCS truncation
- Uses `_escapeString()` method which handles `\`, `"`, `\n`, `\r`, `\t`, `\x1b`

### Chunking (m=1 flag)
- Use `m=1` for all chunks except the last
- Last chunk should NOT have `m=1` flag

### Color Space Notes
- Wide Gamut (OKLCH/LAB) encoding is the encoder's responsibility
- Gamut mapping (out-of-g gamut handling) is terminal's responsibility, not encoder's

## Testing

> **TDD is mandatory for this project.** Follow the Red-Green-Refactor cycle.

### Test-Driven Development (TDD)

**The Iron Law:** NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST

For every new feature, bug fix, or behavior change:
1. **RED**: Write a failing test first
2. **Verify RED**: Run the test and confirm it fails for the right reason
3. **GREEN**: Write minimal code to pass the test
4. **Verify GREEN**: Confirm the test passes and all tests pass
5. **REFACTOR**: Clean up if needed while keeping tests green

### Running Tests

Run all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/keyboard/kitty_encoder_test.dart
```

Generate coverage report:
```bash
flutter test --coverage
```

### TDD Verification Checklist

Before marking work complete:
- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and errors covered

**Cannot check all boxes?** You skipped TDD. Start over.

### Common TDD Rationalizations (Don't Do This)

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Tests after achieve same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "Already manually tested" | Ad-hoc ≠ systematic. No record, can't re-run. |
| "Deleting work is wasteful" | Sunk cost fallacy. Keeping unverified code is technical debt. |
| "Keep as reference, adapt existing code" | That's testing after. Delete means delete. |

## Publishing

This project uses automated publishing via GitHub Actions with OIDC authentication.

### Release Process

When the human partner requests a release:

1. **Check local status** - Ensure all changes are committed
2. **Bump version** - Increment version in `pubspec.yaml` (follow semver)
3. **Update CHANGELOG** - Add new version entry at the top
4. **Commit** - Create commit with version bump
5. **Create tag** - `git tag v<version>`
6. **Push** - Push commit and tag: `git push && git push origin v<version>`

### CI/CD Workflow

- **Tests & Analysis** runs on every push and PR
- **Publish to pub.dev** runs automatically when a `v*` tag is pushed
- Uses `dart-lang/setup-dart` reusable workflow for OIDC-based publishing

### Version Bump Guidelines

| Type | Example | When |
|------|---------|------|
| Patch | 1.2.3 → 1.2.4 | Bug fixes |
| Minor | 1.2.3 → 1.3.0 | New features (backward compatible) |
| Major | 1.2.3 → 2.0.0 | Breaking changes |

## Protocol Coverage (100%)

| # | Protocol | Status |
|---|----------|--------|
| 1 | Keyboard Protocol | ✅ 100% |
| 2 | Graphics Protocol | ✅ 100% |
| 3 | Text Sizing | ✅ 100% |
| 4 | File Transfer | ✅ 100% |
| 5 | Clipboard (OSC 52) | ✅ 100% |
| 6 | Clipboard (OSC 5522) | ✅ 100% |
| 7 | Notifications (OSC 99) | ✅ 100% |
| 8 | Notifications (OSC 777) | ✅ 100% |
| 9 | Remote Control | ✅ 100% |
| 10 | Color Stack | ✅ 100% |
| 11 | Pointer Shapes | ✅ 100% |
| 12 | Styled Underlines | ✅ 100% |
| 13 | Hyperlinks | ✅ 100% |
| 14 | Shell Integration | ✅ 100% |
| 15 | Wide Gamut Colors | ✅ 100% |
| 16 | Misc Protocol | ✅ 100% |
| 17 | Mouse Tracking | ✅ 100% |
| 18 | Bracketed Paste | ✅ 100% |
| 19 | DEC Modes | ✅ 100% |
