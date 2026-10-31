# OneDash Manual Acceptance Checklist

Run after installing the release APK on a real device (spec 13.4).

| # | Scenario | Result |
|---|---|---|
| 1 | Fresh install -> add panel with wrong key -> see API key error -> correct -> overview | pending |
| 2 | Stay on overview 60 s, background 30 s, return without white flash | pending |
| 3 | Scroll all 5 tabs 3 screens, switch 10 times, state and scroll position preserved | pending |
| 4 | Websites: search -> detail -> SSL -> back, list refreshed | pending |
| 5 | Files: 3 levels -> upload 5 MB -> download -> edit txt -> delete (L2 confirm) | pending |
| 6 | Containers: start/stop -> logs 30 s -> terminal `ls` -> exit | pending |
| 7 | Firewall: add rule -> toggle off/on -> optimistic update and rollback | pending |
| 8 | Settings: dark -> accent -> dynamic color -> text 1.5x, no flash/overflow | pending |
| 9 | Airplane mode: offline banner + snapshot data + writes disabled | pending |
| 10 | TalkBack: add server -> overview is understandable | pending |
| 11 | OLED black theme: cards, sheets, skeleton and terminal remain distinguishable | pending |
| 12 | English locale: website detail, backups, server edit, files and terminal show no Chinese fallback | pending |

Automated checks already passing:

```bash
flutter analyze   # no issues
flutter test      # all tests pass
```
