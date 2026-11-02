# OneDash 可控能力补全回执（第十批：网站 PHP/SSL/重写、日志、备忘录、SSH 密钥）

## 本批新增

- 网站基础设置：新增“切换 PHP 版本”，可选择静态站点或任一 PHP 运行时，
  调用 `switchPhpVersion`。
- SSL 证书：新增“编辑证书”（备注与自动续签）和“检查 DNS”，分别调用
  `updateSsl`、`resolveSsl`。
- 伪静态：新增“保存为自定义模板”，调用 `manageCustomRewrite`。
- 日志：新增清理操作/登录日志与导出 SSH 日志，调用 `cleanLogs`、
  `exportSshLogs`；导出返回服务端路径并提示。
- 面板设置：新增面板备忘录编辑，调用 `saveMemo`。
- 主机 SSH：密钥卡片新增编辑动作，调用 `editSshCert`（底层 `editCert`）。

## 可达性守卫

- registry 中 8 个方法移出 allowlist，当前 `unwired = 0`，allowlist 80 条。
- `host_api.dart:editCert` 仍登记为包装器豁免：界面通过 `editSshCert`
  调用，方法名不同。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

全部能力尚未接完，按用户要求本批不构建 APK。上一版 APK 保持不变。
