# OneDash 可控能力补全回执（第十八批：网站选项、面板 HTTPS、Supervisor 进程文件）

## 本批新增

- 新建网站：新增“从现有网站复制”，读取 `getWebsiteOptions` 后填充域名与别名。
- 面板设置：新增面板 HTTPS 配置，支持 Enable/Disable/Mux 与粘贴证书/私钥、
  选择现有证书、自签，调用 `updateSSL`，并提示可能中断当前会话。
- Supervisor：进程动作新增编辑配置、查看 stdout/错误日志，调用
  `operateSupervisorProcessFile`。

## 可达性守卫

- 2 个方法移出 allowlist，1 个方法归入包装器豁免；当前 `unwired = 0`，
  allowlist 32 条。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

全部能力尚未接完，本批不构建 APK。
