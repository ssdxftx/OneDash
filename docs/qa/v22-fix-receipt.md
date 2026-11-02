# OneDash 可控能力补全回执（第十五批：编排模板、daemon 键值、运行环境编辑）

## 本批新增

- 编排：新增模板面板，支持查看、删除、JSON 批量导入，调用
  `deleteTemplates`、`batchImportTemplates`。
- Docker 设置：新增 daemon 键值编辑，调用 `updateDaemonByKey`。
- 运行时：动作面板新增编辑，拉取详情后回写名称/端口/备注及原有参数，
  调用 `getRuntime`、`updateRuntime`。

## 可达性守卫

- 4 个方法移出 allowlist，当前 `unwired = 0`，allowlist 39 条。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

全部能力尚未接完，本批不构建 APK。
