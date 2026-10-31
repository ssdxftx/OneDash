# v4 acceptance follow-up

Baseline: `8172a56`
Input: OneDash pending-items report v4.

## Fixes

| Item | Result |
|---|---|
| R1 network card overflow | Removed the duplicate network sparkline; the two-line caption now fits 136dp at 1.0x and the scaled grid at 1.5x |
| R1 coverage | Added 240dp / 390dp and 1.0x / 1.5x tests asserting no overflow |
| R2 empty sparkline gap | CPU and memory only pass a sparkline after three samples; empty charts no longer reserve 28dp |
| R3 graphite | Kept `neutral`; recorded as a deliberate low-saturation trade-off |

## Verification

```
flutter analyze --fatal-infos    -> 0 issues
flutter test                     -> 62 tests pass
tool/check_error_leaks.sh        -> exit 0
```

Release APK rebuilt after the layout change. Real-device checklist items 13-20
remain the only unexecuted acceptance work.
