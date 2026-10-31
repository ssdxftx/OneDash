# OneDash

OneDash is a single-panel, zero-backend Android client for [1Panel](https://github.com/1Panel-dev/1Panel), built with Flutter and a Material 3 design language.

> This project is based on the data layer of **Mono-Dash** (GPL-3.0). The whole project is released under **GPL-3.0**. The visual language references **Kazumi** (GPL-3.0); no Kazumi source code is copied.

## Status

| Milestone | Scope | Status |
|---|---|---|
| M0 | Project baseline, license, analysis, CI | done |
| M1 | Design tokens, theme, 22 components, 5-tab shell, router | done |
| M2 | Panel connection, server management, diagnosis | done |
| M3 | Overview: health score, metrics, polling, area chart | done |
| M4 | Files: browse, breadcrumb, upload, download, image preview, compress/extract, rename, delete, editor | done |
| M5 | Containers, logs, terminal, compose, per-container terminal | done |
| M6 | Websites: list, detail, domain add/delete, site dir edit, Nginx config edit, SSL binding, reverse proxy list/toggle/delete, create wizard | done |
| M7 | App store (dynamic install + installed lifecycle), databases, cronjobs, firewall (port + IP), logs, process, backups (download/delete/restore), runtimes, panel/app settings | done (read + core actions) |
| M8 | Performance profiling on real device | pending (needs hardware) |

## Requirements

- Flutter stable with Dart `^3.11.1`
- Android SDK 35, JDK 17
- Android `minSdk` 26, `targetSdk` 35
- Package id: `dev.onedash.app`

## Commands

```bash
# dependencies and generated localization
flutter pub get
flutter gen-l10n

# quality
flutter analyze --fatal-infos
dart format lib test
flutter test

# run
flutter run --profile

# release apk (arm64-v8a)
flutter build apk --release --split-per-abi --target-platform android-arm64

# regenerate the MiSans subset after adding new UI strings
python3 scripts/subset_font.py
```

## Architecture

```
lib/
  core/        network, storage, theme, router, localization, utils
  data/        api, dto, repository implementations (copied from Mono-Dash)
  domain/      entities and repository interfaces
  presentation/
    shell/     5-tab server shell
    common/    design-system components, states, charts
    features/  servers, dashboard, websites, files, containers, more, ...
```

Dependency direction: `presentation -> domain <- data`; `core` may be used by all layers.

## Security

- API keys are stored with `flutter_secure_storage` (Android Keystore).
- Requests are signed with `MD5("1panel" + apiKey + unixSeconds)`.
- No telemetry, no account, no cloud sync. All data stays on the device.
- Destructive operations require confirmation; deleting a resource requires typing its name.

## APK size

The full MiSans families are about 8 MB per weight. `scripts/subset_font.py`
generates Regular, Medium and Semibold subsets from the characters used in
`lib/` and the ARB files, keeping the arm64 release APK under the 26 MB budget.
Missing glyphs in dynamic panel data fall back to the Android system font.

## License

GPL-3.0. See `LICENSE` and `NOTICE`.
