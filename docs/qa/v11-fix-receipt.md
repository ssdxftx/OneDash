# OneDash 可控能力补全回执（第四批：主机、运行时、面板设置）

- 依据：`OneDash-可控能力补全任务书` 4.8、4.9、4.11

## 主机 / SSH

- SSH 状态行可直接启停 SSH 服务（`enable` / `disable`）。
- 密钥列表新增“同步 SSH 密钥”，调用 `/hosts/ssh/cert/sync`。
- 原有 SSH 端口、root 登录、密码登录、公钥登录、密钥生成/删除保留。

## 运行时

- 运行环境页新增同步按钮，调用 `/runtimes/sync`。
- 运行环境动作面板新增删除（需输入名称，运行中的环境禁用删除），调用
  `/runtimes/del`。

## 面板设置

- 面板端口可修改，提交前提示会断开会话。
- 绑定域名可修改，复用当前 IPv6 设置提交 bind 信息。
- 面板登录密码可修改，包含当前密码、新密码和确认校验。
- API 接口/凭据行可生成 API Key 并复制。
- 新增快照入口与快照页：
  - 列表、创建、重建、删除。
  - 可编辑描述。
  - 创建时可选择 Docker 配置、监控数据、登录/操作/系统/任务日志。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85 通过
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：123，exit 0；阈值从 135 下调到 123
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 未覆盖

- SSH 配置文件原文读写、连接测试、终端会话管理。
- 运行时创建/编辑、PHP 扩展、Node scripts、FPM 配置。
- 面板 SSL、MFA、Passkey、API 接口开关。
- 快照恢复/回滚/导入。
- 主机分组、磁盘挂载/分区、进程终止。
- 无 Android 真机或模拟器，未执行真实点击与真面板写操作验收。

## 构建产物

`flutter build apk --release --target-platform android-arm64 --split-per-abi` 成功，
产物大小 24,858,334 字节，SHA-256
`b52fa88229f5026687a9981f659ffd986cb1ac92e0346a1787d9bc689ce0b81c`。
预览地址：
`https://8000-5f085df3015621c9.monkeycode-ai.online/OneDash-v1.0.0-arm64-v8a.apk`
