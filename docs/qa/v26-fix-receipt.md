# OneDash 可控能力补全回执（第十九批：服务器文件恢复、源文件编辑、运行时新增）

## 本批新增

- 备份：新增“从服务器文件恢复”，先 `uploadForRecover` 再 `recoverByUpload`。
- 网站反代：代理卡片新增源文件编辑，读取 `content` 后调用
  `updateWebsiteProxyFile`。
- 网站重定向：重定向行新增源文件编辑，调用 `saveWebsiteRedirectFile`。
- 运行时：新增创建表单，填写名称、类型、镜像、应用详情 ID、资源、版本、
  代码目录、端口、备注和参数 JSON，调用 `createRuntime`。

## 可达性守卫

- 4 个方法移出 allowlist。
- 当前 `unwired = 0`，allowlist 27 条，全部是包装器命名差异，
  “真实缺口”区已清空。
- 382 个写方法已全部可达。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

已构建 APK（全部真实缺口清零后）：

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,256,270 字节
- SHA-256：`8049da158567221b4ef464e1e27cd8311f9c4fcfed879f384ce91d833d83d623`
- 预览地址返回 HTTP 200
