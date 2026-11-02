# OneDash 可控能力补全回执（第十二批：数据库状态、证书账号编辑、Docker 用量）

## 本批新增

- 数据库详情：新增“运行状态”，调用 `getStatus` 展示指标键值。
- 文件：新建文件/目录前调用 `checkFileExists`，已存在时提示并中止。
- PHP 运行时：扩展页新增“扩展预设”，调用 `searchPhpExtensions`。
- 网站证书账号：ACME 与 DNS 账号新增编辑，调用 `updateAcmeAccount`、
  `updateDnsAccount`。
- 镜像：新增“使用此镜像的容器”，调用 `getContainersByImage`。
- Docker 设置：新增磁盘用量面板，调用 `getItemStats`。

## 可达性守卫

- 7 个方法移出 allowlist，当前 `unwired = 0`，allowlist 59 条。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

全部能力尚未接完，本批不构建 APK。
