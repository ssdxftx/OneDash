# OneDash 可控能力补全回执（第十一批：通知配置、备份容器、快照、文件辅助）

## 本批新增

- 告警通知方式：通知方式页从占位改为真实配置列表，支持新增、编辑、测试、
  删除，调用 `getAlertConfig`、`updateAlertConfig`、`testAlertConfig`、
  `deleteAlertConfig`。
- 备份：新增容器备份页签，容器备份支持恢复（`recoverContainer`）；
  新增备份大小统计，调用 `recordSizes`。
- 快照：新增恢复、回滚、JSON 导入，调用 `recoverSnapshot`、
  `rollbackSnapshot`、`importSnapshot`。
- 网站模板：编辑前通过 `getTemplate` 拉取完整模板。
- 文件：文件管理器新增“网站根目录”入口（`getWebsiteRootDir`）；
  权限面板新增用户/用户组选择（`getUserGroups`）；分享详情重新拉取
  `getFileShareDetail`。
- 面板设置：新增 API 接口开关（`updateApiConfig`）。

## 可达性守卫

- 18 个方法移出 allowlist，当前 `unwired = 0`，allowlist 66 条。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

全部能力尚未接完，按约定本批不构建 APK。
