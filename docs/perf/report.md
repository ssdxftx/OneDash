# OneDash Performance Report

Baseline target device: Pixel 6 / Snapdragon 778G, 120 Hz (per spec 9.1).

| Metric | Budget | Measured | Status |
|---|---|---|---|
| Cold start to first frame | <= 600 ms | not measured | pending real device |
| Cold start to interactive | <= 1.5 s | not measured | pending real device |
| Warm start | <= 300 ms | not measured | pending real device |
| Page transition | <= 8 ms/frame | not measured | pending real device |
| List scroll jank | < 1% | not measured | pending real device |
| Scroll P90 frame time | <= 12 ms | not measured | pending real device |
| Resident memory (PSS) | <= 220 MB | not measured | pending real device |
| Memory growth (10 min) | < 30 MB | not measured | pending real device |
| APK size (arm64) | <= 26 MB | 23.4 MB (MiSans Regular/Medium/Semibold subsets) | pass |
| First-screen requests | <= 3 | not measured | pending real device |
| Dashboard polling CPU | < 3% | not measured | pending real device |

## Static guarantees implemented

- Dashboard polling is visibility- and lifecycle-gated (`VisibilityDetector` + `AppLifecycleState`).
- Metric history uses a fixed 120-point ring buffer.
- Charts are isolated with `RepaintBoundary` and custom painters with `shouldRepaint`.
- File and container lists use fixed `itemExtent` / lazy builders.
- `ListView(shrinkWrap: true)` is not used for data lists.
- Image cache is capped at 120 entries / 80 MB in `main.dart`.

## How to measure

```bash
flutter run --profile
flutter drive --profile --target=test_driver/perf_test.dart
adb shell dumpsys gfxinfo dev.onedash.app framestats
adb shell top -n 1 | grep onedash
```
