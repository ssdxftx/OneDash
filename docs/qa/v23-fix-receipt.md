# OneDash 可控能力补全回执（第十六批：SSH 配置文件与连接测试）

## 本批新增

- 主机 SSH：新增配置文件名选择、读取、编辑与保存，调用 `loadSshFile`、
  `updateSshFile`；保存前展示断连风险提示。
- 主机 SSH：新增连接测试，填写地址/端口/用户名/密码后调用
  `testHostConnection`。

## 可达性守卫

- 3 个方法移出 allowlist，当前 `unwired = 0`，allowlist 36 条。
- 同时把已由包装器覆盖的方法归入顶部“包装器豁免”区，避免与真实缺口混淆。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

全部能力尚未接完，本批不构建 APK。
