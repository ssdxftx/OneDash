# OneDash 可控能力补全回执（第二十批：收尾缺口与批量选择）

## 本批新增

- 数据库：PG / Mongo 删除改为调用专用接口 `deletePgDatabase`、
  `deleteMongoDatabase`；Redis 新建时通过 `getInstalledAppPort` 读取实际端口。
- 应用商店：安装前调用 `checkAppInstalled`，已安装时提示去已安装列表操作。
- 容器：镜像页、网络页支持多选与批量删除；容器列表支持多选批量删除。
- 网站：列表支持多选批量删除。
- 主机：SSH 密钥列表支持多选批量删除。
- 文件：沿用已有批量选择能力。

## 可达性守卫

- `unwired = 0`，allowlist 23 条，全部为改名包装或内部辅助调用。
- 真实缺口区保持为空。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,322,082 字节
- SHA-256：`65678765aaf40f05de00ec1ed2ef4a2fb2e8019a7d32aa1c66adf2ab58d9ce58`
- 预览地址返回 HTTP 200
