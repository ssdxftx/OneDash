# OneDash 全量代码审查报告

- 审查日期：2026-11-22
- 客户端基线：`00a07f5 feat(ui): complete 1Panel v2.5.1 visual flows and contract fixes`
- 当前分支：`261122-feat-ui-completion`
- 服务端基线：1Panel `v2.5.1`，commit `806de63`
- 服务端源码：`/tmp/1panel-v2.5.1`
- 审查范围：`lib/core/`、`lib/data/`、`lib/domain/`、`lib/presentation/`、`test/`、`tool/`、Android 构建配置、GitHub Actions
- 审查方式：逐模块静态审查、跨层调用链核对、对照 1Panel 服务端路由/handler/service、运行静态分析与现有测试
- 代码变更：本轮只写报告，未修改业务代码

## 1. 执行摘要

本次审查覆盖 422 个 Dart 源文件、93 个测试文件和 Android/CI 配置。审查重点是多服务器状态隔离、页面生命周期、分页并发、文件传输、SSE、任务回执、路由参数、会话存储和发布配置。

确认问题 42 个：

| 级别 | 数量 |
| --- | ---: |
| P0 | 1 |
| P1 | 19 |
| P2 | 22 |

最严重的问题是应用商店 provider 没有按服务器隔离。切换服务器后，保活状态仍展示旧服务器数据，而升级、卸载、启停操作使用新服务器 repository，ID 重合时可能操作到新服务器上的错误应用。

其余高风险问题集中在：

- 全局路由把 `/servers/:id/edit` 当成服务器路由，静默切换当前服务器
- 嵌套路由父子都使用 `:id`，运行时详情拿到服务器 id
- 删除或修改服务器后未清理面板会话，服务器 id 复用会把旧 Cookie 发往新主机
- `servers.json` 损坏会让应用在 `runApp` 前失败
- 切换仪表盘监控项后轮询和手动刷新永久失效
- 文件/网站列表 invalidate 后页码未重置，出现漏页和无限加载
- 二进制下载把业务错误 JSON 当文件内容
- SSE 逐 chunk 解码导致中文乱码，流式错误被静默忽略
- Supervisor 配置保存成功后仍抛格式异常

修复后验证结果：

- `flutter analyze --fatal-infos`：`No issues found!`
- 全量 `flutter test`：464 项通过
- `tool/check_sheet_whitelist.sh`：通过
- `tool/check_hardcoded_english.py`：通过
- `tool/check_error_leaks.sh`、`tool/check_action_reachability.sh`、`tool/check_ui_consistency.py`：通过
- `scripts/check_1panel_api_coverage.py --panel-root /tmp/1panel-v2.5.1`：0 个真实路由不匹配，27 个未调用路由

新增回归测试覆盖服务器切换、二进制错误体、IPv6 baseUrl、损坏 `servers.json` 恢复、query 脱敏和 FakePanel 错误场景。

## 0. 修复进度

- [x] P0-01 应用商店保活状态按服务器隔离
- [x] P1-01 编辑服务器路由不再切换 active server
- [x] P1-02 运行时详情改用独立 `runtimeId`
- [x] P1-03 删除/修改服务器清理面板会话
- [x] P1-04 `servers.json` 损坏时隔离并回退空列表
- [x] P1-05 仪表盘重建后恢复轮询
- [x] P1-06 文件/网站列表 invalidate 后重置页码
- [x] P1-07 应用商店/计划任务/备份分页增加代次保护
- [x] P1-08 二进制下载识别业务错误 envelope
- [x] P1-09 SSE 流式解码并识别错误响应
- [x] P1-10 Supervisor 配置保存按成功处理
- [x] P1-11 日志脱敏覆盖 query 参数
- [x] P1-12 CI 启用 `pipefail` 并接入 sheet 守卫
- [~] P1-13 默认 HTTPS 和 release 签名已修复；为兼容 HTTP 面板保留 cleartext，并增加 HTTP 安全提示
- [x] P1-14 服务器切换弹层异步返回后校验路由
- [x] P1-15 计划任务补齐集群数据库类型
- [x] P1-16 磁盘挂载传递 `noFail` 并兼容当前文件系统
- [x] P1-17 编辑 Compose 时隐藏无效的创建测试入口
- [x] P1-18 备份创建校验 detailName
- [x] P1-19 终端连接串行化并修正兼容缓存作用域

- [x] P2-01 网站创建移除不支持的 MongoDB/集群建库选项
- [x] P2-02 负载均衡补齐 `w` 时间单位
- [x] P2-03 应用商店消费 `key` 查询参数
- [x] P2-04 删除数据库后刷新列表
- [x] P2-05 日志来源切换增加加载代次
- [x] P2-06 文件权限非法输入给出提示
- [x] P2-07 非法服务器深链回退首页
- [x] P2-08 AI 渠道枚举文案本地化
- [x] P2-09 OpenResty 配置/性能刷新改为帧后应用
- [x] P2-10 VNC 无订阅者和页面卸载时释放帧
- [x] P2-11 WebSocket 握手响应体增加超时
- [x] P2-12 目录体积按规范化路径精确匹配
- [x] P2-13 服务器文件写入串行化并使用唯一临时文件
- [x] P2-14 服务器 baseUrl 使用 `Uri` 正确格式化 IPv6
- [x] P2-15 服务器健康检查保留错误原因并区分鉴权失败
- [x] P2-16 终端兼容缓存绑定 DioClient 生命周期
- [x] P2-17 上传弹层关闭时取消 CancelToken
- [x] P2-18 `pubspec.yaml` SDK 约束与锁文件对齐
- [x] P2-19 13 个 ARB key 补齐 placeholders
- [x] P2-20 FakePanel 场景接入回归测试
- [~] P2-21 API 契约测试仍以客户端请求为基准；已让 API 覆盖率工作流监听 DTO 变化
- [x] P2-22 release 已由 Flutter Gradle 插件默认开启 minify/shrink；release 工作流补齐守卫，CI 增加 debug APK 构建

### 剩余风险

- P1-13 仍保留 Android 全局 cleartext：1Panel 默认 HTTP 面板依赖该能力，移除会让大量现有服务器无法连接。当前已改为默认 HTTPS、release 强制签名，并在关闭 HTTPS 时显示明文传输警告。
- P2-21 的 API 契约测试仍以客户端自身生成的请求为基准，尚未引入服务端 fixture；已让 API 覆盖率工作流监听 DTO 变化。
- 本轮未使用真实面板凭据执行写操作回归，下载、任务和权限相关修复以静态对照和 FakePanel 测试为主。

## 2. 判定标准

| 级别 | 判定 |
| --- | --- |
| P0 | 可能操作到错误服务器/错误资源，造成数据破坏或安全边界失效 |
| P1 | 主要功能错误、核心流程不可用、资源泄漏、鉴权/会话问题、发布安全问题 |
| P2 | 边界条件错误、展示错误、低概率竞态、体验缺陷、构建与测试质量问题 |

## 3. P0 问题

### P0-01 应用商店保活状态未按服务器隔离

- 位置：`lib/presentation/features/app_store/providers/app_store_provider.dart:16-20`、`:31-44`、`:91-121`、`:155-185`
- 关联：`lib/presentation/features/app_store/screens/app_store_page.dart:399-401`、`lib/presentation/features/app_store/widgets/installed_app_actions.dart:55`、`:136`
- 证据：`appCatalogProvider`、`installedAppsProvider`、`upgradableAppsProvider` 使用 `ref.keepAlive()` 保活 2-5 分钟，family key 只有查询词或为空；`_fetch` 通过 `ref.read(appRepositoryProvider.future)` 读取当前服务器 repository，没有建立对 `activeServerIdProvider` 的依赖。
- 触发：在服务器 A 打开应用商店，切换到服务器 B，并在保活时间内重新进入应用商店。
- 影响：页面继续展示 A 的应用目录和已安装列表；升级、卸载、启停、修改配置读取 B 的 repository，并使用 A 列表里的 `installId`/`appDetailId`。两个面板的安装 ID 都从较小整数递增，重合概率高，可能修改或卸载 B 上的错误应用。
- 建议：把 serverId 加入 provider family key；或在 build 中 `ref.watch(activeServerIdProvider)`；在服务器切换入口统一 invalidate 应用商店相关 provider；执行操作前校验列表来源服务器。

## 4. P1 问题

### P1-01 全局路由把编辑服务器路径当成服务器切换

- 位置：`lib/core/router/app_router.dart:79-94`、`:107-114`
- 证据：redirect 对所有含 `:id` 的路径执行 `notifier.state = id`，包括 `/servers/5/edit`。
- 触发：从服务器列表打开任意服务器编辑页，然后取消。
- 影响：当前激活服务器已被静默改成正在编辑的服务器，后续返回或页面重建会使用错误服务器上下文。
- 建议：只在 `state.uri.pathSegments.first == 's'` 时同步 active server；其他 `:id` 路由按各自语义处理。

### P1-02 运行时详情父子路由参数冲突

- 位置：`lib/core/router/app_router.dart:123`、`:638-646`
- 证据：父路由 `/s/:id` 和子路由 `runtimes/:id` 使用同名参数。GoRouter 在父级匹配完成后再次合并父级参数，父级服务器 id 覆盖子级 runtime id。
- 触发：打开 `/s/1/runtimes/42`。
- 影响：`_serverId(state)` 和 `state.pathParameters['id']` 都变成 `1`，运行时详情加载错误 ID，可能显示不存在或加载到另一个运行时。
- 建议：子路由改为 `runtimes/:runtimeId`，分别读取 `id` 和 `runtimeId`。

### P1-03 面板会话未随服务器生命周期清理

- 位置：`lib/core/storage/storage_service.dart:144-151`、`:215-220`、`lib/presentation/features/servers/screens/server_edit_page.dart:162-169`、`lib/core/network/dio_client_provider.dart:24`
- 证据：`deleteServer` 只删除服务器、API Key 和备忘，未调用 `clearPanelSession`；`_nextServerId` 使用 `max+1`，删除最大 ID 后会复用；编辑 host/port/isHttps 后也未清理会话。
- 触发：删除服务器后新增服务器，或把现有服务器地址改到另一个面板。
- 影响：新服务器会从安全存储读到旧 `psession`/`pcsrftoken`，并作为 Cookie 发往新主机，造成会话泄露或认证错乱。
- 建议：删除服务器、修改地址或复用 ID 时清理 `panel_session_v1_$id`；服务器 ID 改用不可复用 UUID。

### P1-04 servers.json 损坏导致启动失败

- 位置：`lib/main.dart:15-16`、`lib/core/storage/storage_service.dart:180-189`、`lib/domain/entities/server.dart:57`
- 证据：`init()` 在 `runApp` 前读取并迁移服务器文件；`jsonDecode` 和 `json['host'] as String` 都没有异常保护。
- 触发：文件被截断、非 JSON、包含非对象项，或旧版本记录缺少 `host`。
- 影响：应用在进入主界面前抛 `FormatException` 或 `TypeError`，用户只能清除应用数据。
- 建议：解析整体 try/catch，逐条容错并跳过坏记录，备份损坏文件后回退空列表；补 StorageService 单测。

### P1-05 仪表盘切换监控项后轮询永久停止

- 位置：`lib/presentation/features/dashboard/providers/overview_provider.dart:119-126`、`:186-193`、`lib/presentation/features/dashboard/screens/overview_page.dart:126-146`
- 证据：`build` 中 `ref.onDispose` 把 `_disposed` 置为 true；依赖变化重算时 build 没有复位 `_disposed`，`_loadInitial` 也没有重新调度。页面侧 `_visible` 仍为 true，不会再次调用 `setVisible`。
- 触发：在概览页切换 IO 或网络监控项，或语言/网络设置变化导致 repository 重建。
- 影响：`_schedule` 和 `_tick` 直接返回，实时曲线冻结，刷新按钮和下拉刷新也无效，只有重新进入页面才恢复。
- 建议：build 起始复位 `_disposed=false`、`_tickInFlight=false`，取消旧 timer；初始加载完成后按 `_visible` 重新调度。

### P1-06 文件/网站列表 invalidate 后页码未重置

- 位置：`lib/presentation/features/files/providers/files_provider.dart:53-58`、`:126-137`、`lib/presentation/features/websites/providers/websites_provider.dart:28-33`
- 关联：`lib/presentation/features/files/screens/files_page.dart:164`、`:247`、`lib/presentation/features/websites/screens/website_detail_page.dart:326`、`:363`
- 证据：`build` 只请求第 1 页，但没有把 `_page` 重置为 1；Riverpod invalidate 会保留同一 Notifier 实例。
- 触发：文件列表已加载多页后上传、重命名、删除、压缩或解压；网站列表已加载多页后在详情页启停或删除。
- 影响：列表变为第 1 页数据，但下一次 `loadMore` 从旧页码 +1 开始，中间页永久缺失；`items.length < total` 持续成立，滚动会反复请求空页。
- 建议：build 起始显式 `_page=1`、`_loadingMore=false`；排序变化也重新请求第 1 页。

### P1-07 分页 refresh/loadMore 并发无代次保护

- 位置：`lib/presentation/features/app_store/providers/app_store_provider.dart:58-79`、`:131-152`、`:195-216`、`lib/presentation/features/cronjobs/providers/cronjobs_provider.dart:40-69`、`lib/presentation/features/backups/screens/backups_page.dart:101-133`
- 证据：`refresh` 重置 `_page=1`，但已发出的 `loadMore` 捕获旧页码，返回后仍 `_page++` 并追加当前状态；没有 generation 校验。
- 触发：加载第 2 页以后触发下拉刷新、定时刷新或 invalidate。
- 影响：列表同时出现新第 1 页和旧第 N 页，中间页缺失，后续加载继续跳过页面。
- 建议：引入请求代次；`refresh`、`search`、筛选变化递增代次；`loadMore` 返回后校验代次和页码。

### P1-08 二进制下载把业务错误 JSON 当文件内容

- 位置：`lib/core/network/interceptors/api_envelope_interceptor.dart:29-33`、`lib/data/api/file_api.dart:49-58`、`lib/data/api/container_api.dart:1017-1035`、`lib/core/network/dio_client.dart:189-204`
- 证据：envelope 拦截器只在 `response.data is Map` 时校验业务 code；`ResponseType.bytes` 和 `download` 的 data 是 `List<int>`、`ResponseBody` 或 `null`。
- 触发：服务端返回 HTTP 200 + `{code:400/500,message:...}` 的下载错误。
- 影响：错误 JSON 被写入本地文件或作为字节返回，用户得到损坏文件，真实错误被隐藏。
- 建议：下载和 bytes 接口单独检查 Content-Type 或首包；先解析错误 envelope，再写入文件。

### P1-09 SSE 流式聊天乱码和错误静默

- 位置：`lib/data/api/ai_api.dart:132-160`、`lib/core/network/dio_client.dart:154-169`
- 证据：每个网络 chunk 单独 `utf8.decode(..., allowMalformed:true)`；`postStream` 的响应不经过 envelope 拦截器。
- 触发：UTF-8 多字节字符被拆到两个 chunk，或服务端返回 HTTP 200 的 JSON 业务错误。
- 影响：中文和 emoji 随机出现替换字符；错误时找不到 `data:` 帧，聊天静默结束，用户看到空回复。
- 建议：使用 `utf8.decoder.bind(body.stream)` 流式解码；检查 Content-Type 或首包 JSON envelope；把错误转成流异常。

### P1-10 Supervisor 配置保存成功后仍报失败

- 位置：`lib/data/api/host_tool_api.dart:42-56`
- 服务端：`/tmp/1panel-v2.5.1/agent/app/api/v2/host_tool.go:106-117`
- 证据：`set` 分支保存后也调用 `ApiResponseParser.map(resp)`，服务端 `UpdateToolConfig` 使用 `helper.Success(c)` 返回 `data=null`。
- 触发：保存 Supervisor 配置文件。
- 影响：服务端已保存，客户端抛 `ApiFormatException` 并提示失败，用户可能重复保存或误判配置未生效。
- 建议：`set` 使用 `ApiResponseParser.ok`；只有 `get` 解析 `data.content`。

### P1-11 文件分享密码进入 release 日志

- 位置：`lib/data/api/file_api.dart:845-862`、`lib/core/network/interceptors/logging_interceptor.dart:46-50`、`lib/core/utils/log_sanitizer.dart:11-37`
- 证据：分享校验和下载把 `password` 放在 URL query；release 模式错误日志仍输出完整 URI；脱敏规则只覆盖 `password:`，没有 `password=`。
- 触发：密码错误、超时或断网导致 `/files/share/check`、`/files/share/download` 失败。
- 影响：分享密码进入 logcat，可能被日志采集或崩溃上报带走。
- 建议：日志输出前脱敏 query 参数，增加 `password=`、`token=`、`secret=` 规则，并补脱敏测试。

### P1-12 CI 守卫失败被管道吞掉

- 位置：`.github/workflows/ci.yml:30-37`
- 证据：`tool/check_action_reachability.sh | tee`、`python3 tool/check_ui_consistency.py | tee`、`python3 tool/check_hardcoded_english.py | tee` 未启用 `pipefail`，步骤退出码取 `tee` 的 0。
- 当前失败项：`tool/check_sheet_whitelist.sh` 报 `overview_page.dart:1044` 的 `PopupMenuButton` 违规，且该脚本没有接入 CI。
- 影响：守卫失败时 CI 仍显示通过；已知违规可以合入。
- 建议：改用 `shell: bash` 并 `set -o pipefail`，或去掉管道；把 sheet 和 font 守卫加入 CI。

### P1-13 Android 明文流量、默认 HTTP 和 release 签名回退

- 位置：`android/app/src/main/AndroidManifest.xml:8`、`lib/presentation/features/servers/screens/server_edit_page.dart:61`、`android/app/build.gradle.kts:54-58`
- 证据：全局 `usesCleartextTraffic="true"`；新服务器默认 `isHttps=false`；release 缺 `key.properties` 时使用 debug 签名。
- 触发：用户按默认配置添加 HTTP 面板，或在没有正式 keystore 的环境执行 release 构建。
- 影响：API Key 签名、`psession` Cookie、登录交互可被同网段窃听或篡改；release APK 无法覆盖正式安装，签名身份与 passkey assetlinks 可能不一致。
- 建议：默认 HTTPS；移除全局 cleartext 或使用 `networkSecurityConfig` 限定私网；release 缺签名配置时直接构建失败。

### P1-14 服务器切换弹层异步返回后误 pop

- 位置：`lib/presentation/common/components/server_switcher_sheet.dart:79-98`
- 证据：`navigator` 在 `await touch()` 前捕获，await 后直接 `navigator.pop()`，没有检查弹层路由是否仍是栈顶。
- 触发：点击服务器后立即下滑关闭弹层或按系统返回。
- 影响：`pop()` 可能弹出服务器列表或业务页面，随后 `pushReplacement` 进一步破坏返回栈。
- 建议：await 后检查 `context.mounted` 和 `ModalRoute.of(context)?.isCurrent`；或先 pop，再把选择结果交给调用方处理。

### P1-15 集群数据库定时任务下拉断言

- 位置：`lib/presentation/features/cronjobs/screens/cronjob_form_page.dart:453-467`
- 服务端：`/tmp/1panel-v2.5.1/agent/app/service/cronjob_backup.go:183`
- 证据：下拉项只有 `mysql`、`mariadb`、`postgresql`、`redis`、`mongodb`；服务端支持 `mysql-cluster` 和 `postgresql-cluster`。
- 触发：编辑集群数据库备份任务。
- 影响：Debug 下触发 `There should be exactly one item with value` 断言；Release 下回显为空，保存可能覆盖原类型。
- 建议：补齐集群类型，或让 items 动态包含当前 `_dbType.text` 并归一化未知值。

### P1-16 磁盘挂载 noFail 失效和文件系统断言

- 位置：`lib/presentation/features/host/widgets/host_disks_tab.dart:131-137`、`:180-182`
- 服务端：`/tmp/1panel-v2.5.1/agent/app/dto/request/disk.go:11-18`
- 证据：表单有 `noFail` 开关，但 `DiskMountReq` 构造未传该值，默认始终为 true；挂载文件系统下拉只有 ext4/xfs，`initialValue` 直接使用分区原文件系统。
- 触发：关闭 NoFail 后挂载，或挂载 vfat/ntfs/btrfs 分区。
- 影响：NoFail 开关无效；非 ext4/xfs 分区在 Debug 下断言，Release 下列表空白，请求最终也会被服务端拒绝。
- 建议：表单结果携带 noFail；当前文件系统动态加入选项，或不支持的文件系统禁用挂载并提示。

### P1-17 Compose 编辑时“测试”使用旧文件

- 位置：`lib/presentation/features/containers/screens/compose_form_page.dart:112-124`
- 证据：编辑模式 `_testPayload()` 发送 `from: path`、`path: compose.path`，不发送 `_content.text`。
- 触发：修改 YAML 后先点“测试”。
- 影响：测试的是服务器上已保存的旧文件，当前修改不会被校验；用户可能看到合法后保存失败，或看到非法但保存成功。
- 建议：编辑模式测试也发送当前编辑器内容，保持测试和提交一致。

### P1-18 备份创建未校验 detailName

- 位置：`lib/presentation/features/backups/screens/backups_page.dart:466-475`
- 服务端：`/tmp/1panel-v2.5.1/agent/app/service/backup_app.go:36`、`backup_mysql.go:119`
- 证据：提交前只检查 `resource.isEmpty`，`detailName` 可以为空；app 备份用 detailName 查安装实例，数据库备份用 detailName 查库。
- 触发：app 或数据库备份只填资源名。
- 影响：表单通过校验，服务端返回资源不存在，用户在任务阶段才看到失败。
- 建议：按类型校验 appKey + installName、实例名 + 数据库名、website alias。

### P1-19 终端刷新并发建立多个 WebSocket

- 位置：`lib/presentation/features/terminal/screens/terminal_page.dart:70-75`、`:336-341`
- 证据：`_connect()` 没有 `_connecting` 锁；刷新按钮连续点击会并发执行 `_disconnect`/`_connect`。
- 触发：连接较慢时快速点击刷新两次。
- 影响：两个连接都设置 `_terminal.onOutput`，后返回的覆盖 `_channel`/`_subscription`，旧订阅泄漏，终端输出可能重复或错乱。
- 建议：增加连接中状态和请求 token，串行化连接，重复点击直接返回。

## 5. P2 问题

### 功能与契约

- `website_create_wizard.dart:1098-1107` 提供 MongoDB，`_dbCandidates` 也包含集群实例；服务端 `website.go:394-455` 只处理 mysql/mariadb/postgresql/postgres，Mongo 和集群类型会静默不建库。
- `website_load_balance_tab.dart:264-271` 的 `failTimeoutUnit` 只有 s/m/h/d；服务端解析支持 w，编辑已有 w 配置时会断言或丢失单位。
- `websites_page.dart:900` 跳转 `/more/apps?key=openresty`，但 `app_router.dart:404-412` 只读取 `tab`，`AppStorePage` 忽略 `key`，安装入口落到未过滤列表。
- `database_detail_page.dart:544-546` 删除数据库成功只 pop 详情，不 invalidate 列表；返回动作层或列表仍显示已删除资源。
- `log_preview_page.dart:166-169`、`:325-337` 切换日志来源时 `_loadInFlight` 拦截新请求，旧请求完成仍写入 `_lines`，新来源显示旧日志。
- `file_permission_sheet.dart:158-160` 权限输入不合法时直接 `return`，没有 Toast 或 errorText。
- `app_router.dart:71-72`、`:80-81` 非数字 `/s/abc` 的 id 为 null，redirect 放行，页面用 `?? 0` 请求 0 号服务器。
- `ai_agents_actions.dart:1013-1033`、`:1074-1078` 中文界面显示 `true`/`false`/`open`/`allowlist`/`disabled`/`websocket`/`webhook`。

### 稳定性与资源

- `openresty_config_sheet.dart:82-84`、`:96-98` 和 `openresty_performance_sheet.dart:132-148` 在 build 中 `_apply`；invalidate 后 `valueOrNull` 可能仍是旧值，`_loaded` 立即置 true，刷新无效；build 中改 Controller 也有 setState-during-build 风险。
- `vnc_client.dart:201-216` 的 `_frames` 是 broadcast 控制器，无订阅者时 `add` 丢弃帧，`ui.Image` 不会释放。
- `web_socket_connector.dart:50-57` 只对 `request.close()` 设置超时，响应体 `.join()`/`.drain()` 没有超时，服务端发完响应头后挂起会永久卡住。
- `file_api.dart:566-574` 用原始 path 与服务端 Clean 后路径精确比较，失败后取 `data.last`；服务端 map 顺序随机，可能返回子目录大小。
- `storage_service.dart:129-142`、`:194-208` 的读改写无锁，固定 `.tmp` 文件；并发保存、排序、删除可能丢失更新或触发 rename 异常。
- `server.dart:31-33` 直接拼 `http://$host:$port`，裸 IPv6 已实测抛 `FormatException`；`server_host_normalizer.dart` 未被调用。
- `servers_provider.dart:124-130` 把所有异常都映射成 offline，鉴权、证书、配置错误无法与网络不通区分。
- `terminal_page.dart:154` 的 `cacheScope` 使用 int，`dio_client.dart:85` 用 DioClient 对象清理，`api_compatibility.dart:89-91` 只删除同一对象作用域，终端端点顺序缓存永不清理。
- `files_page.dart:1961-2044` 的上传 sheet 没有在 dispose 中取消 `CancelToken`；下滑关闭弹层后上传继续在后台执行。

### 构建与测试

- `pubspec.yaml:7` 声明 `^3.11.1`，`pubspec.lock:1174` 要求 Dart >=3.13.0；按 README 的 3.11 环境执行 `pub get` 会失败。
- `app_en.arb:11750` 等 13 个 key 含占位符但缺 `@...placeholders`，生成方法退化为 `Object`，失去 int 类型约束和 intl 数字格式化。
- `test/support/fake_panel.dart` 的 `empty`、`error`、`slow`、`unauthorized` 场景未被主要测试使用。
- `test/unit/api_request_contract_test.dart` 断言客户端自己生成的 path/body，字段漂移仍可通过；`api-coverage.yml` 未监听 `lib/data/dto/**`。
- `android/app/build.gradle.kts` release 未开启 minify/shrink，release workflow 未跑完整守卫，CI 未构建 debug APK。

## 6. 模块覆盖情况

| 模块 | 结论 |
| --- | --- |
| 核心/网络 | 发现二进制错误体、SSE、WebSocket 超时、取消语义问题 |
| 存储/会话 | 发现启动损坏、会话清理、ID 复用、并发写问题 |
| 路由/Shell | 发现 active server 副作用、父子 `:id` 冲突、非法深链 |
| 服务器管理 | 发现编辑/删除会话残留、IPv6、健康检查错误归并 |
| 仪表盘 | 发现监控项切换后轮询停止 |
| 文件 | 发现分页页码、下载错误体、精确大小、上传取消、权限反馈 |
| 网站 | 发现分页页码、建库类型、负载均衡单位、OpenResty 刷新 |
| 容器 | 发现 Compose 测试内容、日志流超时、二进制错误体 |
| 数据库 | 发现删除后列表不刷新、详情查找分页边界 |
| 备份 | 发现分页竞态、detailName 校验缺口 |
| 计划任务 | 发现集群数据库类型、分页竞态、记录日志异常吞掉 |
| 主机/磁盘 | 发现 noFail 失效、文件系统断言 |
| 应用商店 | 发现跨服务器保活状态、openresty 入口参数 |
| AI | 发现 SSE 解码、错误静默、枚举文案英文化 |
| 运行时 | 发现详情路由参数冲突 |
| VM | 发现 VNC 帧释放问题 |
| 终端 | 发现并发连接、兼容缓存作用域 |
| 日志 | 发现来源切换竞态 |
| 面板设置 | 发现 OpenResty 刷新和本地化占位符问题 |
| 告警/进程/工具箱/画廊/更多 | 本轮未发现新增确定缺陷；工具箱密码请求体在 debug 日志中仍建议补充 `passwd` 脱敏 |

## 7. 验证与测试盲区

已执行：

- `flutter analyze --fatal-infos`：通过
- 全量 `flutter test`：454 项通过
- `python3 scripts/check_1panel_api_coverage.py --panel-root /tmp/1panel-v2.5.1`：0 个真实路由不匹配
- `tool/check_sheet_whitelist.sh`：失败
- 人工对照 1Panel v2.5.1 的 dashboard、file、download、SSE、host tool、website、cronjob、backup、terminal 相关 handler

主要盲区：

- 没有真实面板凭据，写操作和下载错误体未做真机回归
- 没有服务器切换场景测试
- 没有分页 refresh/loadMore 并发测试
- 没有 SSE 分块和错误 envelope 测试
- 没有启动时损坏 `servers.json` 的恢复测试
- 没有下载接口业务错误测试
- API 契约测试仍以客户端自身生成的请求为基准

## 8. 修复建议

优先处理顺序：

1. P0-01 应用商店服务器隔离。
2. P1-01、P1-02 路由参数和 active server 副作用。
3. P1-03、P1-04 会话清理和启动损坏恢复。
4. P1-05、P1-06、P1-07 仪表盘生命周期和分页一致性。
5. P1-08、P1-09、P1-10 下载、SSE、Supervisor 回执。
6. P1-11、P1-12、P1-13 日志脱敏、CI 守卫、Android 安全配置。
7. P1-14 至 P1-19 的导航、集群类型、磁盘、Compose、备份、终端问题。
8. P2 中的存储并发、IPv6、WebSocket 超时、VNC 资源释放和测试盲区。

建议同时补充以下回归测试：

- 切换服务器后应用商店 provider 重建，操作只命中新服务器
- `/servers/:id/edit` 不改变 active server
- `/s/:serverId/runtimes/:runtimeId` 参数独立
- 删除服务器后新增服务器不携带旧会话
- `servers.json` 截断、缺字段、非 JSON 的启动恢复
- 监控项切换后轮询继续
- 多页列表 invalidate 后从第 1 页重新加载
- refresh 与 loadMore 并发时的页序和去重
- 下载接口返回业务错误 envelope
- SSE 多字节字符跨 chunk 和错误 JSON
- Supervisor config set 返回 `data=null`
- 分享密码 URL 脱敏

## 9. 附录

### 9.1 审查命令

```bash
flutter analyze --fatal-infos
python3 scripts/check_1panel_api_coverage.py --panel-root /tmp/1panel-v2.5.1
bash tool/check_sheet_whitelist.sh
git diff --check
```

### 9.2 关键文件

- `lib/core/router/app_router.dart`
- `lib/core/storage/storage_service.dart`
- `lib/core/network/dio_client.dart`
- `lib/core/network/interceptors/api_envelope_interceptor.dart`
- `lib/core/network/interceptors/logging_interceptor.dart`
- `lib/core/utils/log_sanitizer.dart`
- `lib/data/api/ai_api.dart`
- `lib/data/api/file_api.dart`
- `lib/data/api/host_tool_api.dart`
- `lib/data/api/container_api.dart`
- `lib/presentation/features/app_store/providers/app_store_provider.dart`
- `lib/presentation/features/dashboard/providers/overview_provider.dart`
- `lib/presentation/features/files/providers/files_provider.dart`
- `lib/presentation/features/websites/providers/websites_provider.dart`
- `lib/presentation/features/cronjobs/providers/cronjobs_provider.dart`
- `lib/presentation/features/backups/screens/backups_page.dart`
- `lib/presentation/features/host/widgets/host_disks_tab.dart`
- `lib/presentation/features/terminal/screens/terminal_page.dart`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/build.gradle.kts`
- `.github/workflows/ci.yml`
