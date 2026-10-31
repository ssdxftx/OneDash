# P1 repair report

Baseline: `9456bb0`
Scope: P1-01 through P1-05, plus the P2 batch requested in the same task book.

## Verification

```
flutter analyze --fatal-infos   -> 0 issues
flutter test                    -> 58 tests pass
grep "AppToast.error" | "$error" -> 0
```

Localization: 562 keys at baseline, 580 keys after adding P1/P2 copy. Generated
localization code is checked in and `flutter gen-l10n` exits 0.

## Task results

| ID | Result | Evidence |
|---|---|---|
| P1-01 | Done | `error_toast.dart`; all raw toast and inline error paths replaced; `error_toast_test.dart`; `error_leak_guard_test.dart` |
| P1-02 | Done | default group has lock, no delete action, guarded `_delete`; widget test |
| P1-03 | Done | notification and panel password rows show `网页版配置`, no chevron or toast |
| P1-04 | Done | metric value and unit share a scaled rich text; narrow-width tests |
| P1-05 | Done | ring center is clamped and bounded to the inner circle; 2x tests |
| P2-01 | Done | tonalSpot scheme; graphite seed neutralized; pairwise palette test |
| P2-02 | Done | alert type/channel/log status labels; formatter unit tests |
| P2-03 | Done | dashed placeholder under three samples; upload rate in caption |
| P2-04 | Done | alert logs show localized delivery channel |
| P2-05 | Done | toolbox renamed to device information, read-only footer, actions group |
| P2-06 | Done | installed app detail labels localized |
| P2-07 | Done | port helper reduced to `9999` |
| P2-08 | Done | filter chips fade at both edges, right padding s24 |
| P2-09 | Done | process and supervisor use distinct icons |
| P2-10 | Done | save button says Save and open; connecting toast |

## Deviations

See `docs/agent-notes.md`.
