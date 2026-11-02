# OneDash 可控能力补全回执（第十七批：网站日志查看与描述置顶）

## 本批新增

- 网站日志：访问日志与错误日志支持在应用内查看最新 300 行并刷新，调用
  `readRuntimeLog`（type=website，name=access.log/error.log）。
- 网站设置：基础页签新增“描述与置顶”，调用 `saveDescription` 保存网站描述
  和置顶状态。

## 可达性守卫

- 2 个方法移出 allowlist，当前 `unwired = 0`，allowlist 34 条。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

全部能力尚未接完，本批不构建 APK。
