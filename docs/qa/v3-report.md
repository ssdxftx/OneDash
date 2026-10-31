# v3 acceptance follow-up

Baseline: `8427c75`
Input: OneDash acceptance report v3.

## Verification

```
flutter analyze --fatal-infos    -> 0 issues
flutter test                     -> 58 tests pass
tool/check_error_leaks.sh        -> exit 0
```

## Fixes

| Item | Result |
|---|---|
| 8 remaining raw error sites | Toast calls use `showErrorToast`; six inline error paths store `describeError` text |
| Multi-line grep false positive | `tool/check_error_leaks.sh` checks three-line windows, field assignments and direct text; also enforced by a Dart test and CI |
| Graphite theme | Restored seed `#5B6B62`, routed through `DynamicSchemeVariant.neutral`; low-saturation assertion |
| AreaChart placeholder | Large network chart shows the collecting label below three samples and omits the grid |
| Unlabeled sparkline divider | Sparkline without a placeholder now renders nothing |
| Network caption | Two-line caption keeps upload rate and total traffic at 1.5x |
| Repeated web-only tags | Removed per-row tags from notification methods; top explanation remains |
| Filter fade | Edge stops widened to 0.08 / 0.92 |

## Remaining

Real-device checklist items 13-20 still require hardware. The health card at
240dp and the optional vertical host/port form are visual polish items not in
the v3 blocking list.
