# OneDash 可控能力补全回执（第十三批：远程数据库、批量检查、MFA、证书下载）

## 本批新增

- 数据库：新增远程实例面板，支持列出、编辑、测试连接、加载数据库、
  删除，调用 `searchRemoteDatabases`、`updateRemoteDatabase`、
  `checkRemoteConnection`、`loadFromRemote`、`loadPgFromRemote`、
  `deleteRemoteDatabase`。
- 文件：多选模式新增“检查是否存在”，调用 `batchCheckFilesExists`。
- 面板设置：新增双因素认证绑定（`loadMFA`、`bindMFA`）与通行密钥管理
  （`deletePasskey`）。
- 网站证书：SSL 与 CA 支持下载 ZIP，调用 `downloadSsl`、`downloadCa`。

## 可达性守卫

- 12 个方法移出 allowlist，当前 `unwired = 0`，allowlist 47 条。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget/test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

全部能力尚未接完，本批不构建 APK。
