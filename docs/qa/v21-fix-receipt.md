# OneDash 可控能力补全回执（第十四批：商店设置、容器用户、Node 脚本、镜像仓库检索、Supervisor 配置）

## 本批新增

- 应用商店：设置菜单新增商店选项，读取并保存四项卸载/升级/端口策略，
  调用 `getStoreConfig`、`updateStoreConfig`。
- 容器：动作面板新增“容器用户”，调用 `loadContainerUsers`。
- Node 运行时：模块页新增 package.json 脚本查看，调用 `getNodeScripts`。
- 镜像仓库：仓库页新增检索，调用 `searchImageRepos`。
- Supervisor：新增主配置文件读取与保存，调用 `operateSupervisorConfig`。

## 可达性守卫

- 4 个方法移出 allowlist，新增 1 条包装器豁免；当前 `unwired = 0`，
  allowlist 43 条。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

全部能力尚未接完，本批不构建 APK。
