# OneDash 可控能力补全回执（第五批：网站收尾、应用同步）

- 依据：`OneDash-可控能力补全任务书` 剩余高价值动作

## 网站

- 域名列表新增 SSL 开关，直接调用 `updateDomainSsl` 绑定/解绑证书。
- 高级设置的“安全”页签新增路径级访问认证：
  - 列表、新增、编辑、删除。
  - 字段覆盖路径、名称、用户名、密码、备注。
- 高级设置新增 OpenResty 页签：
  - 性能参数读取与保存。
  - 主配置文件读取与保存。
- 反向代理、伪静态、重定向、CORS、防盗链、真实 IP 保留。

## 应用商店

- 应用商店右上角新增菜单：
  - 同步远程应用。
  - 同步本地应用。
  - 两项均携带 taskID，通过任务日志轮询并展示最后一行。

## 防回归基线

- 可达性脚本阈值从 123 下调到 101。
- 新增 14 条 allowlist，仅覆盖已经通过不同命名 repository 包装器暴露的接口：
  备份账号、SSH 证书、分组、应用连接信息。
- 未接写操作从 123 降至 101（其中 14 条为已接线但脚本无法识别的方法名映射）。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85 通过
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：101，exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 未覆盖

- 网站 ACME/DNS/CA 账号 CRUD、代理原始文件编辑、PHP 版本切换。
- 应用取消忽略、商店配置。
- 容器镜像仓库、构建/导入/导出/推送镜像、编排模板导入导出。
- 数据库远程数据库编辑/测试、PG/Mongo 专用删除、变量读写。
- 主机 SSH 配置文件、连接测试、终端会话、磁盘挂载/分区、进程终止。
- 运行时创建/编辑、PHP 扩展、Node scripts。
- 面板 SSL、MFA、Passkey、API 接口开关、快照恢复/回滚/导入。
- 无 Android 真机或模拟器，未执行真实点击与真面板写操作验收。

## 构建产物

`flutter build apk --release --target-platform android-arm64 --split-per-abi` 成功，
产物大小 24,989,406 字节，SHA-256
`6247e00ce8bc00c85d4b8d62132ecae93144366cc5f164ba280b8346ece5c1b7`。
预览地址：
`https://8000-5f085df3015621c9.monkeycode-ai.online/OneDash-v1.0.0-arm64-v8a.apk`
