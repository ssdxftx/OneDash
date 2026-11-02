# OneDash 可控能力补全回执（第七批：数据库变量、Redis 状态、SSH 会话）

## 数据库

- MySQL 高级页新增性能变量读写：max_connections、buffer pool、log buffer、key/join/read buffer、table open cache、thread cache、tmp table、慢查询开关与阈值等。
- Redis 高级页新增运行状态读取，并可从状态面板安装 Redis CLI。
- 原有配置文件、慢日志、Redis 配置/密码/持久化保留。

## 主机 / SSH

- SSH 页新增终端会话管理：列出活动会话、关闭单个会话、全部关闭。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85 通过
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：89，exit 0；阈值从 93 下调到 89
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 未覆盖

- 数据库远程库编辑/删除/连通性测试、PG/Mongo 专用删除。
- 主机 SSH 配置文件、连接测试、磁盘挂载/分区、进程终止。
- 网站 ACME/DNS/CA、PHP 版本切换、代理原始文件。
- 运行时创建/编辑、PHP 扩展、Node scripts。
- 面板 SSL/MFA/Passkey、API 开关、快照恢复/回滚/导入。
- 无 Android 真机或模拟器，未执行真实点击与真面板写操作验收。

## 构建产物

`flutter build apk --release --target-platform android-arm64 --split-per-abi` 成功，
产物大小 24,990,170 字节，SHA-256
`b88a19dbb9bb3cc48de14cfd6df23c1c9cd7e87fd1613f133ef3b849d3ac0247`。
预览地址：
`https://8000-5f085df3015621c9.monkeycode-ai.online/OneDash-v1.0.0-arm64-v8a.apk`
