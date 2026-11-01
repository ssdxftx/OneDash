# D batch acceptance log

Panel: `https://1panel.06162636.xyz` (1Panel v2.4.2)

## Read-only API probes

- `POST /api/v2/websites/search` -> 200, 12 websites.
- `GET /api/v2/websites/39/lbs` -> 200, `data: null`.
- `GET /api/v2/websites/38/lbs` -> 200, `data: null`.
- `POST /api/v2/websites/templates/search` -> 200, `total: 0`, `items: null`.
- `POST /api/v2/websites/templates/outputs/search` -> 200, `total: 0`,
  `items: null`.
- `POST /api/v2/files/ai-search` with path `/tmp` and query `onedash` -> 200,
  `mode: "grep"`, empty hits, `contentScannedFiles: 4`, `duration: "2ms"`.

The client maps null payloads to empty lists.

## Not exercised on this panel

- Load-balancing create, update and delete: these change the OpenResty config
  of an existing site, so they were not run against the shared panel.
- Template create, ZIP upload, output generation and delete: these create files
  on the shared panel, so only the list endpoints were exercised.
- AI mode summary: the lab panel has file AI disabled, so only the grep fallback
  was exercised. AI mode uses the same response schema and panel-side account.

## Checks

```
flutter analyze --fatal-infos   -> 0 issues
flutter test test/unit test/widget test/app_smoke_test.dart
tool/check_error_leaks.sh       -> exit 0
flutter gen-l10n                -> exit 0
```
