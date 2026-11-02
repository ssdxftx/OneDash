# OneDash 可控能力补全回执（第一批）

- 基线：`68d1436`
- 依据：`OneDash-可控能力补全任务书`
- 范围：P0 基础设施 + 遗留必修 + 容器 / 编排 / 计划任务 / 告警第一批接线

## 基础设施

- 新增 `ActionSheetScaffold`、`ActionSheetInfoCard`、`ActionSheetSection`、
  `ActionSheetRow`、`ActionSheetStatusPill`，复用 `showAppSheet`。支持分组标题、
  副标题、状态徽章、禁用态、危险态和尾部组件。
- 新增 `TaskProgressSheet`：执行中显示进度与最近一条面板日志，成功后 600ms
  自动关闭，失败展示面板日志原文并可重试，执行中可转到后台继续。
- 新增可达性守卫：
  - `tool/check_action_reachability.py`
  - `tool/check_action_reachability.sh`
  - `tool/unwired_allowlist.txt`
  - 当前阈值 `189`，比报告基线 `217` 下调 `28`。

## 遗留必修

- `task_failedNoDetail` 改为“请查看面板日志。”，`describeError` 不再出现
  “任务执行失败：任务执行失败…”。
- 网站打开失败、终端服务器缺失、防火墙不支持的后端全部改为
  `ApiBusinessException`，不再被兜底成“出现了一点问题”。
- 文件子目录无 `itemTotal` 时显示“文件夹”，不再恒显示“0 项”。
- 容器创建页在“转到后台继续”前主动刷新列表；后台任务完成后即使页面已关闭，
  也通过 ProviderContainer 刷新容器列表。

## 容器

- 长按容器改为 5 组动作面板：
  - 运维：终端、日志、实时监控
  - 生命周期：启动、停止、重启、暂停、恢复、强制停止
  - 配置：编辑容器、升级容器、制作镜像
  - 危险：删除容器（输入容器名确认）
- 容器编辑复用创建表单并回填镜像、端口、挂载、环境变量、网络、资源限制、
  restart policy 等字段；未在表单暴露的 hostname、DNS、labels 等原值保留。
- 新增镜像与网络页：搜索镜像、拉取镜像、重设标签、删除镜像、搜索网络、
  新建网络、删除非系统网络。
- 新增 Docker 设置页：启停/重启 Docker、日志切割参数、IPv6 参数、
  daemon.json 原文读写。
- 列表工具条新增清理未使用容器、镜像网络入口、Docker 设置入口。

## 编排

- 新增创建/编辑页。编辑时通过 `/containers/inspect` 读取 YAML，保存走
  `/compose/update`；创建走 `/compose`，均通过 taskID 轮询任务结果。
- 编排动作面板补编辑、日志、清空日志、up/restart/down/stop/rebuild、
  删除（输入名称确认）。
- 表单支持本地 YAML 校验（`/compose/test`）。

## 计划任务

- 列表右上角新增“新建”，卡片点击进入动作面板。
- 新增创建/编辑表单，覆盖 shell、日志切割、访问 URL、备份网站、备份数据库、
  备份目录、备份应用、快照、清理面板日志、清理垃圾、时间同步。
- 支持 cron 表达式、保留份数、重试次数、超时、目录/文件模式、日志范围等字段。
- 动作面板新增停止正在执行、执行记录、清理记录；记录可查看原始执行日志。

## 告警

- 列表右上角新增“新建”，点击卡片可编辑。
- 表单覆盖 CPU、内存、磁盘、负载、SSH 登录、面板登录、证书到期、网站到期、
  面板更新等规则，支持阈值、周期、每日发送上限、通知配置多选和目标。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85 通过
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：189，exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 未覆盖

- 报告中的网站、文件、应用、数据库、备份、主机、运行时、面板设置批次尚未接线。
- 容器备份/恢复依赖备份账号，本批只接入了镜像、网络和 Docker 设置。
- 无 Android 真机或模拟器，动作只通过静态分析、单元/组件测试和路由冒烟验证。
- 面板未安装 PostgreSQL、MongoDB、PHP、ClamAV、Fail2ban，相关写操作未执行。

## 构建产物

`flutter build apk --release --target-platform android-arm64 --split-per-abi` 成功，
产物大小 24,592,166 字节，SHA-256
`874b3992829e1542325d0cf3fae948a59d5a5cde85231c65e245fcdd1bbc34d6`。
预览地址：
`https://8000-5f085df3015621c9.monkeycode-ai.online/OneDash-v1.0.0-arm64-v8a.apk`
