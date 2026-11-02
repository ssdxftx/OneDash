# OneDash 可控能力补全回执（第三批：应用 + 数据库 + 备份）

- 依据：`OneDash-可控能力补全任务书` 4.5、4.6、4.7

## 应用商店

- 已安装应用详情右上角新增菜单：
  - 升级：读取可用版本，选择版本、升级前备份、拉取最新镜像，走长任务面板。
  - 修改参数：读取 `AppInstalledParams`，编辑可编辑字段，支持高级容器名、重启策略、
    CPU/内存限制和 compose 内容。
  - 修改端口：按 app key 与安装名提交。
  - 连接信息：读取 `apps/installed/conninfo` 并逐项展示。
  - 忽略更新：写 `scope: app`。
  - 卸载：可选删除数据库、备份、镜像、强制删除，走长任务面板，成功后返回列表。
- 任务等待复用 `/logs/tasks/read` 轮询，面板日志最后一行进入任务面板。

## 数据库

- 数据库详情新增“高级”页签：
  - 配置文件读取与保存。
  - MySQL / PostgreSQL 慢查询日志读取。
  - Redis 配置（timeout、maxclients、maxmemory）、Redis 密码、AOF/RDB 持久化。
- 原有远程访问开关、修改密码、删除数据库、用户授权保留。

## 备份

- 备份页右上角新增“新建备份”：支持应用、MySQL、PostgreSQL、MongoDB、Redis、
  网站、容器；数据库密码、备注、容器备份前停止。
- 新建任务携带 taskID，通过任务日志轮询并展示最后一行。
- 新增备份账号管理页：列表、新建、编辑、删除、连接测试。账号表单覆盖
  local/SFTP/S3/OSS/COS/MinIO、Access Key、Secret、Bucket、路径、vars 和凭据记忆。
- 原备份记录下载、删除、应用/数据库恢复保留。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85 通过
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：135，exit 0；阈值从 152 下调到 135
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 未覆盖

- 应用商店同步远程/本地应用、取消忽略更新、应用连接信息以外的服务详情。
- 远程数据库的编辑/删除/连通性测试、PG/Mongo 专用删除入口。
- 备份账号的 bucket 列表、Token 刷新、恢复上传流程。
- 文件、主机/SSH、运行时、面板设置/快照/分组批次仍未接线。
- 无 Android 真机或模拟器，未执行真实点击与真面板写操作验收。

## 构建产物

`flutter build apk --release --target-platform android-arm64 --split-per-abi` 成功，
产物大小 24,858,010 字节，SHA-256
`415601b4d7e925b13f92a3960c5fc2593b9de01a730efdef5bc0d3c269f47fdc`。
预览地址：
`https://8000-5f085df3015621c9.monkeycode-ai.online/OneDash-v1.0.0-arm64-v8a.apk`
