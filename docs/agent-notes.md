# Agent notes

Deviations and open questions from the repair task book. Human decision is
required before changing any item here.

## P1-05

The task book's sample test measures intrinsic `Text` size. With `FittedBox`
the child keeps its intrinsic layout size while the painted result is scaled
into the ring. Tests therefore assert that the bounded `FittedBox` stays inside
the 48dp inner circle and that no overflow exception is thrown. Visual behavior
is equivalent.

## P2-01

`tonalSpot` alone pulled the graphite seed toward blue and collided with
`ocean`. Graphite now keeps its original seed `#5B6B62` and uses
`DynamicSchemeVariant.neutral`, so its primary stays a low-saturation gray. The
pairwise test excludes graphite from hue comparison and separately asserts
saturation below 0.2.

## P2-03

`Sparkline` and `AreaChart` both show the localized collecting state below
three samples. The large network chart hides its grid instead of drawing a
baseline. A sparkline without a label renders nothing rather than an unlabeled
dashed divider. The network card keeps down speed as the primary value and
shows upload speed plus total traffic in a two-line caption.

## P2-04

`AlertLogInfo` has `method` but no rule-name or title fields. Only the delivery
channel was added. Rule names require a DTO/API change and were intentionally
left alone.

## P1-01 guard

The original single-line grep missed multiline calls. `tool/check_error_leaks.sh`
now checks a three-line window around `AppToast.error`, raw assignments to
`_error`, and direct `Text('$error')` rendering. The same rule runs as a Dart
test, so it executes inside `flutter test` in CI.

## R1 network card

The network card no longer carries a sparkline because the 160dp chart directly
below it shows the same data. The caption keeps upload speed and total traffic
in two lines. CPU and memory only render sparklines once three samples exist.

## L10n pruning

The toolbox rewrite made the old clean-source and clean-action keys unused.
Those keys were removed rather than left as dead entries. The unused
`panelSettings_*Todo` keys from the removed fake notification rows were also
removed. Key count is 575 after this batch.

## Non-goals confirmed

No dependency, endpoint signature, or envelope changes were made. `test/visual`
is absent from the working tree.

## 1Panel v2.4.2 P0

- `hosts/firewall/rules/search` rejects `all=true` with empty `scopes`
  (`FW_SCOPE_UNSUPPORTED`). The client now always sends the full managed scope
  list for the active backend.
- `POST /containers` rejects `networks: []` with `please set up the network`.
  The task book sample omitted this field; the create form now defaults to
  `1panel-network` and loads the panel network list.
- Forward rule editing is implemented as `remove` of the old rule followed by
  `add` of the new rule, matching the panel frontend.
- The hosted lab does not expose test container port 18080 externally. Container
  creation was verified through the panel API (running state and published
  ports), not through a browser request.
- No Android device or emulator is available in this workspace, so the new
  full-screen forms were validated by analyzer, tests, route smoke coverage and
  real API calls rather than device screenshots.

## 1Panel v2.4.2 P1

- The lab panel has only MySQL instances installed (one local, one remote).
  PostgreSQL and MongoDB create/delete/password/bind paths were implemented
  against the v2.4.2 Swagger contract but could not be exercised on the lab
  panel without installing two additional apps.
- `POST /files/depth/size` returns an array of per-child sizes plus the
  requested directory. The client picks the entry whose `path` matches the
  requested directory, so the directory row shows the aggregate size.
- Terminal sessions are listed and closed from the terminal app bar. The
  endpoints are `/hosts/terminal/sessions/search`, `/close` and `/closeAll`
  (`agent/router/ro_host.go:91-93`). The list only shows sessions for the current
  auth session, matching the panel frontend.
- SSH changes are saved through `/hosts/ssh/update`. `/hosts/test/byid` tests a
  saved host record and the current panel server is not one, so port changes use
  the panel-local `/settings/ssh/check` endpoint before and after saving. The
  form still validates the port as a number.
- ClamAV and Fail2ban are not installed on the lab panel. Their pages, scan task
  creation (including the none/remove/move/copy infected-file strategy),
  service toggles, unban actions and scan record lists are implemented but the
  install / EICAR / ban acceptance flow still needs a panel with those tools
  installed. ClamAV installation itself is an OS package step; the panel API
  only starts, stops and restarts the installed service.
- Chunked upload uses the v2.4.2 resumable fields `uploadID`, `offset` and
  `fileSize`. Pause cancels the in-flight request and keeps the temporary part;
  resume continues from the last completed offset. Cancel calls
  `/files/chunkupload/stop` to remove the temporary part.
- SSH key generation and deletion are available in the host page. The generated
  private key is never rendered; only the key name and type are listed.
- PHP FPM configuration is edited through the five `pm.*` fields that the panel
  frontend exposes. Arbitrary FPM parameters are outside this form.
- The PHP extension tab has an explicit refresh action so installed state can be
  reloaded. The panel has no per-extension version-update endpoint; updates are
  install/uninstall plus this refresh.
- No Android device or emulator is available. New pages are covered by
  analyzer, unit/widget tests, route smoke tests, and read-only real API probes.

## 1Panel v2.4.2 P2

- The host page now has four tabs: monitoring, SSH, disks and diagnostics.
- Firewall settings now expose backend switching, whitelist editing, rule
  backups/restore/reset and the native firewalld/ufw detail reader. Native detail
  is only meaningful when the panel uses firewalld or ufw; the lab uses
  iptables, so that path is contract-tested only.
  Disks read `/hosts/disks`; diagnostics read `/hosts/diagnostics/summary` and
  `/hosts/diagnostics/goroutines`.
- Disk partition, mount and unmount follow the v2.4.2 request shapes. Partition
  and unmount require typing the device or mount point before submission, and
  mount also asks for confirmation. These destructive paths were not executed
  against the shared lab panel; only `GET /hosts/disks` was exercised.
- Runtime profile capture uses `POST /hosts/diagnostics/profiles` with
  `ResponseType.bytes` and saves the returned pprof file through the system
  save dialog. No new dependency was added.
- `/hosts/components/:name` has no standalone page in v2.4.2; the panel only
  uses it from file AI search to check `ffmpeg`. The diagnostics tab now exposes
  a small component check with an editable name, defaulting to `ffmpeg`. The
  raw executable error string is not rendered; a localized "not found" label is
  shown instead.
- Fail2ban basic rules can be edited from the toolbox page: port, max retries,
  ban time, find time, ban action and log path. The lab panel does not have
  Fail2ban installed, so these writes could not be exercised end to end.
- No Android device or emulator is available. New tabs are covered by analyzer,
  DTO unit tests, route smoke tests and read-only API probes.

## 1Panel v2.4.2 D batch (partial)

- The dashboard quick-action grid now has nine entries, adding websites,
  containers and installed apps to the existing six.
- Website detail has a load-balancing tab backed by `/websites/:id/lbs` and the
  create, update and delete endpoints. The form covers name, algorithm, server
  address, weight, status, max failures, fail timeout and max connections.
- Load balancing was exercised read-only on the lab panel. The two probed sites
  returned `data: null` for `/lbs`, which the client renders as an empty list.
  Create, update and delete were not executed because they would modify an
  existing site.
- Website templates are available from the websites app bar. The page supports
  listing, filtering, create/edit/delete, single-page HTML with variable
  auto-detection, multi-file ZIP upload, variable metadata, and generating a
  site from a template. Generated sites are listed in a sheet and can be
  deleted. Template preview is not rendered in the app because there is no
  WebView dependency; generation still uses the panel API.
- AI is implemented as file content search from the files app bar. It calls
  `/files/ai-search`, supports recursive search, case, whole-word and regex
  options, shows grep hits, and renders the AI summary when the panel has file
  AI enabled. The app never stores or asks for model credentials; it uses the
  panel's existing AI account setting. The separate Agent/model/GPU/MCP module
  is outside this batch.

## v6 验收回执

- v6 报告称 `POST /containers` 返回 `{taskID}`；v2.4.2 源码
  `agent/app/api/v2/container.go` 的 `ContainerCreate` 调用
  `helper.Success(c)`，任务 ID 来自请求体 `dto.ContainerOperate.taskID`，
  后台任务由 `ContainerService.ContainerCreate(req, true)` 启动。客户端因此
  使用请求体 taskID 轮询 `/logs/tasks/read`。
- 容器任务最长等待 2 分钟（240 次、500ms 间隔）；失败时保留表单并展示最后
  一行任务日志。
- 页签滚动使用 `Scrollable.ensureVisible`，筛选芯片只共享边缘渐隐实现。
- 网站删除保留选项页，再追加一次域名输入确认。
- 模板 DTO 没有版本字段，模板卡 chip 显示单页/多文件类型。

## v8 可控能力补全（第一批）

- 长任务统一走 `TaskProgressSheet`；`TaskWaiter.waitFor` 新增 `onUpdate`
  回调，容器任务面板会显示 `/logs/tasks/read` 返回的最后一行日志。
- 容器编辑复用 `ContainerCreatePage`，路由为
  `/s/:serverId/containers/:name/edit`。1Panel `/containers/update` 需要完整
  `ContainerOperate`，因此未在表单暴露的 hostname、DNS、labels 等字段从
  `/containers/info` 原值回填并保留。
- 镜像、网络、Docker 设置和编排表单均使用现有数据层方法，没有新增依赖。
- 编排创建使用 `from: edit` + `file` + `dirName`；编排更新使用
  `name`、`path`、`detailPath`、`content`，两者都携带 taskID 并轮询。
- `tool/check_action_reachability.py` 用方法体中的 `.post/.put/.delete`
  识别写方法。阈值从报告基线 217 降到 189，后续批次只能继续下调。
- 当前环境没有 Android 真机或模拟器；85 项测试全部通过，但未执行真实点击验收。

## v9 网站与文件批次

- 网站高级设置页复用现有 DTO 与 repository，没有新增数据层方法。默认文档、流量
  限制、目录权限、认证、CORS、防盗链、真实 IP、伪静态和重定向均直接映射官方
  请求体。
- 重定向保存直接提交 `WebsiteRedirectDto.toJson()`。1Panel 的 `name` 是规则文件
  名，客户端没有自动生成，需用户填写。
- SSL 申请使用 `provider: http`、`keyType: P256` 与第一个或用户选择的 ACME
  账号；创建后按主域名重新查询证书 id，再调用 `obtainSsl`。
- 文件工具页只依赖现有 `FileRepository`。回收站列表是原始 Map，按
  `name/rName/sourcePath/from/size/isDir` 读取。
- 远程下载接口返回任务 key，不提供百分比进度；页面展示 key 并支持停止。

## v10 应用、数据库与备份批次

- 已安装应用任务（卸载、升级）通过 `AppRepository.readTaskLog(taskID)` 轮询，
  与其他模块的 TaskWaiter 分离，因为应用任务接口按 taskID 查询。
- 文件工具页复用 `FileFavoriteDto`、`FileShareDto`；回收站接口返回原始 Map，
  按 1Panel `RecycleBinDTO` 字段解析。
- 数据库高级页按类型只展示可用能力：MySQL/PostgreSQL 显示慢日志，Redis 显示
  配置、密码与持久化。
- 手动备份由 1Panel 固定写入本地账号 1，因此新建备份表单不选择账号；备份账号
  管理页用于外部存储账号 CRUD。
- 网站备份复用 `backupDatabase(type: 'website')`，没有新增 API 方法。

## v11 主机、运行时与面板设置批次

- SSH 服务启停使用 1Panel 的 `operation: enable|disable`。
- 运行环境删除使用 `forceDelete: true`，只在非运行状态提供入口。
- 面板端口修改属于高风险操作，客户端在提交前明确提示会断开当前会话。
- 快照创建固定使用本地账号 1（`sourceAccountIDs: "1"`,
  `downloadAccountID: 1`），并携带 taskID；未实现恢复/回滚，避免误操作。

## v12 网站收尾与应用同步批次

- 域名 SSL 开关直接绑定/解绑已有证书，证书本身仍在 SSL 证书管理页维护。
- 路径级认证使用 `WebsitePathAuthUpdateReq`，删除时复用同一接口并传 `operate: delete`。
- OpenResty 性能参数按返回的 `name` 动态生成输入框，保存时拼成 `Map<String,String>`。
- 可达性 allowlist 只登记已经通过 repository 包装器接线的 API 方法，避免脚本按
  API 方法名匹配时误判。

## v13 容器镜像仓库批次

- 镜像构建、导出、导入、推送都复用 `ContainerRepository.waitForTask`，与容器任务
  使用同一套日志轮询和任务面板。
- 镜像仓库内置账号 id=1 只读，删除入口按 `isBuiltIn` 隐藏。
README 中不记录真实仓库凭据；表单仅在会话内使用。

## v14 数据库变量、Redis 状态与 SSH 会话

- MySQL 变量更新按 1Panel `MysqlVariablesUpdateHelper` 发送
  `[{param, value}]`，只覆盖客户端表单中的常用项。
- Redis 状态直接展示接口返回的键值对；安装 Redis CLI 使用现有仓库方法。
- SSH 终端会话页读取原始 Map，兼容 `username/user`、`clientIP/ip`、
  `id/sessionID` 字段命名。

## v15 证书账号与取消忽略批次

- 证书账号页直接复用 `WebsiteRepository` 的 ACME/DNS/CA 方法，不新增依赖。
- DNS 授权以 JSON 文本录入，解析后作为 `authorization` Map 提交；解析失败不发请求。
- CA 续签需要 `sslId`，客户端只在 CA 记录含有效 sslId 时提交。
- 取消忽略更新通过 `getIgnoredApps` 匹配当前安装 ID，再按忽略记录 id 删除。

## v16 文件、容器日志与备份账号收尾

- `unwired_allowlist.txt` 已登记全部剩余未接方法，分类为 Web 专属、设备文件选择器
  依赖、以及 repository 包装器已覆盖的辅助接口。阈值降为 0，但 allowlist 中的
  能力仍需要后续单独设计，不能视为已实现。
- 本批按用户要求没有重新构建 APK。

## v17 网站、日志、备忘录与 SSH 密钥

- 网站 PHP 切换使用运行时列表过滤 `php` 类型；静态站点以 runtimeID=0 提交。
- 日志导出只提示服务端返回的临时 CSV 路径，客户端不下载文件。
- SSH 密钥编辑通过新增的 `editSshCert` 包装器调用 `editCert`，因此该 API
  方法继续留在 allowlist 的包装器豁免区。
- 本批未构建 APK。

## v18 通知配置、备份容器、快照与文件辅助

- 通知配置按原始 JSON 编辑，测试时从中解析 SMTP 字段；配置非法 JSON 时只提示，
  不发起请求。
- 容器恢复使用 600 秒超时，与容器备份的耗时量级保持一致。
- 快照恢复与回滚共用密码输入，密码允许为空。
- 网站根目录入口在文件管理器 AppBar，跳转后走既有的 path 路由。

## v19 数据库、证书账号、镜像与 Docker 用量

- 数据库状态直接展示接口返回的键值，不做单位推断。
- 新建文件前先查存在性，避免面板返回覆盖/已存在错误。
- ACME 编辑只保留邮箱、类型、CA 地址与代理开关；EAB 字段按空值提交。
- 镜像用量与容器列表分开请求，避免镜像页首屏变慢。

## v20 远程数据库、批量文件检查、MFA 与证书下载

- 远程数据库实例 DTO 补齐 port/username/password/description/ssl/timeout，
  列表与编辑共用同一结构。
- 远程实例保存前先调用连接测试，测试失败不写回。
- 证书下载使用 `FilePicker.saveFile` 的 bytes 模式，交给系统保存面板。
- MFA 绑定展示 secret 并要求输入 6 位验证码；通行密钥删除后关闭面板。

## v21 商店设置、容器用户、Node 脚本与 Supervisor

- 商店设置保存时逐项调用更新接口，任一项失败会中止并提示。
- Node 脚本需要用户提供代码目录，避免猜测运行环境路径。
- Supervisor 配置通过 operate=get/update 读写，保存后刷新总览。
- 镜像仓库检索只读展示，不替代本地仓库列表。

## v22 编排模板、daemon 键值与运行环境编辑

- 编排模板 JSON 必须是数组，导入前做类型校验。
- daemon 键值保存后重新读取整份配置，避免界面与文件不一致。
- 运行时编辑复用详情里的 params/环境变量/卷/端口映射，避免更新时丢失配置。

## v23 SSH 配置文件与连接测试

- SSH 配置文件通过 `sshdConfOptions` 获取可编辑文件列表，内容读取使用
  `sshdConfPath:<path>`。
- 保存时按 1Panel 约定传 `key='sshdConfPath'`、`path=内容`、`value=文件路径`，
  参数命名与直觉相反，已在此记录避免后续改错。
- 连接测试固定 password 认证，成功后仅提示，不保存任何凭据。

## v24 网站日志查看与描述置顶

- `readRuntimeLog` 原返回 TaskLogDto 会丢掉 `lines`，已改为 FileLogDto 并补上
  `name` 参数；网站日志必须传 `name=access.log` 或 `error.log`。
- 网站描述保存使用 `type=website`，描述为空也会提交，用于清空。

## v25 网站选项、面板 HTTPS 与 Supervisor 进程文件

- 网站选项仅复制域名和别名，不复制类型或反代配置。
- 面板 HTTPS 修改会立即生效，界面已标注可能中断当前会话。
- Supervisor 进程文件接口的 file 仅接受 out.log / err.log / config；配置通过
  operate=get/update 读写。

## v26 收尾：服务器文件恢复、源文件编辑与运行时新增

- 备份恢复上传使用服务器本地路径，targetDir 固定 `/opt/1panel/backup`。
- 代理/重定向源文件直接使用列表接口返回的 content 字段，不再另取文件。
- 运行时新增为高级表单，参数 JSON 必须是对象。
- 真实 allowlist 缺口已清空，剩余 27 条均为包装器改名豁免。
- 本轮已重新构建 APK，SHA-256 见 v26 回执。

## v27 收尾：数据库专用删除、Redis 端口、安装前检查与批量选择

- PG/Mongo 删除不再走通用删除分支，分别调用专用接口。
- Redis 新建默认端口改为读取已安装应用的实际端口，读取失败时保留 6379。
- 容器镜像、网络、容器列表、网站列表、SSH 密钥均加入多选批量删除。
- 批量删除统一二次确认，容器/镜像批量操作走任务面板。

## v28 UI 一致性与细节审查

- 统一批量选择模型：独立 `_selecting` 状态，选择态才显示 Checkbox，长按进入选择。
- 列表刷新/搜索保留旧 AsyncData，避免 RefreshIndicator 被骨架替换。
- 主要列表空态统一 `RefreshableEmptyState`；危险批量入口统一 `DangerButton`。
- 终端与日志控制台使用 `AppTokens.console*` 语义色，确认弹层统一 `showConfirmSheet`。
- 修复两个无界 `Flexible` Sheet 崩溃点；新增标题栏点击与字号层级回归测试。

## v29 验收报告修复

- 动作面板必须让动作区独立滚动，信息卡固定；否则外层 Sheet 的滚动容器无法接管内部 `ConstrainedBox`。
- 窄屏告警卡片在宽度不足或 1.3x 字号时把删除收进菜单，标题保留两行。
- 表单底部统一使用 `FormFooter`，包含背景、分隔线与安全区，避免按钮贴住屏幕底边。
- SSL 证书到期状态、服务商枚举、菜单收敛与空态主行动本轮补齐。
- 快照失败原因必须显示；状态点同时保留文字标签。
- 运行时元信息统一先过滤空值再拼接，避免残留分隔符。

## v30 验收报告 v10 修复

- `SplitListTile` 的长尾值必须限制最大宽度，否则非弹性 trailing 会把标题压到 0 宽；标题保持剩余空间，文本尾值单行省略。
- 占位符透明度以输入框填充色为背景校验对比度，80% 才满足 4.5:1。
- 列表空态标题描述“没有数据”，栏目名继续放在页面标题或分区标题。
- 缺失记录使用 `RecordNotFoundException`，本地服务器缺失使用 `ServerNotFoundException`，不再用 `StateError` 承载业务文案。

## v31 验收任务书 v11 修复

- 备份账号类型必须以面板大写常量为准，编辑前做大小写归一；`LOCAL` 只用于编辑展示，新建下拉不提供。
- 下拉/表单的值与展示文案分离：值用契约常量，文案走 `backupAccountTypeLabel`。
- `SplitListTile` 的文本尾值先用 `TextPainter` 判断能否同排，放不下时移到标题下方的第二行，非文本尾值保持右侧。
- 底部弹层内出现 `SwitchListTile` 时，需要在其与装饰容器之间提供透明 `Material`，否则触发 ListTile 背景断言。

## v32 UI 审查报告（v12）修复

- 页面级列表边距统一引用 `AppTokens.pagePadding`，宽屏内容由 `ServerShell` 按 `contentMaxWidth` 居中约束。
- `SplitListGroup` 与 `TonalCard` 共用 `outlineVariant` 边框；详情主值使用 `SplitListTile.value`，长文本配置保留等宽 `subtitle`。
- 新建入口统一收进 AppBar，禁止新增右下 FAB；动作超过 3 个时收进 `⋯`，刷新固定首位。
- 列表时间统一 `formatListTime`（7 天内相对、之后绝对），详情时间统一 `formatLocalDateTime`；`formatTimeAgo` / `formatFileModTime` 已删除。
- 空态：首屏列表必须提供 `actionLabel`，模块文案替代 `state_empty`。
- 新增 `tool/check_ui_consistency.py`，校验刷新首位、无 FAB 与时间死代码。

## v33 验收报告 v13 修复

- 同一 `actions` 内的图标必须唯一；运行环境同步与列表刷新要使用不同图标，避免用户无法区分读操作与写操作。
- 页面栏内的刷新只能出现在 AppBar 首位；`PopupMenuButton` 内出现刷新视为违规，守卫脚本已覆盖该形态并接入 CI。
- 窄屏 meta 在 1.3x 下必须按语义分段换行，冒号和值不能被拆开；常规宽度用 `Flexible` 段内省略。
- 详情信息行使用 `SplitListTile.value`，值为空时整行隐藏；标签 `bodyS + onSurfaceVariant`，值 `bodyL + w500`。
- `formatListTime` 的 null 默认值为空串，调用方需要占位时显式传 fallback；服务端时间字符串解析失败时保留原值。
- 底部信息列表的空态使用 `EmptyState(compact: true)`，不再用裸 `Text(state_empty)`。

## v34 验收报告 v14 修复

- `SplitListTile` 的 `value` 与 `trailing` 可以共存；常规宽度值在 trailing 左侧，窄屏值落到标题下方，禁止让 trailing 静默吞掉值。
- 窄屏告警卡的 `⋯` 与开关同处 meta 行，标题独占整行，避免标题最后一个字单独换行。
- 审计类时间在 24 小时到 7 天之间必须保留时分，使用 `MM-dd HH:mm`；`formatListTime` 已统一。
- AppBar 动作顺序固定为「刷新 → 次要动作 → ＋」，`＋` 恒为最后一个 action，守卫脚本会拦截。
- 改动共享组件后，必须补一条同时覆盖 `value` 与 `trailing` 的回归用例，不能只靠页面截图。

## v35 验收报告 v15 优化

- `SplitListTile.valueStyle` 与默认值样式合并，调用方只覆盖颜色等差异；详情值仍保持 bodyL，标签保持 bodyS。
- 需要语义色（证书到期红等）的值走 `value` + `valueStyle`，禁止再退回 `trailing: Text` 绕过层级。
- 告警卡 compact 判据同时看宽度与字号：`maxWidth < 320 || (scale >= 1.3 && maxWidth < 430)`。
- compact 告警 meta 允许两行，渠道名不因菜单挤占而截断。
- 数据库密码行同样走 `value` 通道，与用户名行保持一致层级。

## v36 验收报告 v16 修复

- `SplitListTile` 的 value-only 行同样参与溢出判定：`stackValueOnly` 命中后标题整行、值下堆，禁止把标签挤成 0 宽。
- 详情值必须走 `value` 通道；`trailing: Text` 只用于真正的尾部控件，不用于承载值。
- 同一张 `SplitListGroup` 内保持一种行语义：subtitle + trailing 与 value 两类行拆卡，不混排。
- compact 告警 meta 用「短标签 + Expanded 值」两列，冒号跟随标签；标签文案含本地化分隔符。

## v37 验收报告 v17 修复

- compact 告警卡的 `⋯` 与开关放右侧同一竖列，meta 不再被两个控件同时挤压。
- 空值统一用 `displayValue(context, value)` 返回 `common_notAvailable`，禁止在 UI 写裸 `'-'`；语义性短横线（文件类型、切分、时间戳）除外。
- 告警卡 compact 行为由 `test/widget/alerts_card_test.dart` 在 320dp / 1.3x 固定。

## v38 验收报告 v18 修复

- 告警卡 `compact` 只决定 meta 是否两列；控件竖排由 1.0x 等效宽度 `maxWidth / scale < 210` 单独判定，避免常规屏被撑高。
- compact 控件分支必须三条齐全：竖排、并排、非 compact 仅开关；`⋯` 不能在任何分支丢失。
- 告警卡测试必须加载 MiSans 实字体，并用文本高度断言单行，`didExceedMaxLines` 对 `maxLines: 2` 的折行无效。
- 告警卡回归固定 320/1.0、360/1.0 卡高 ≤108 与控件同行，以及 390/1.0 英文 meta 不省略。
- `SplitListTile` 的 `common_notAvailable` 占位值使用次要色，其它值保持主色层级。

## v39 验收报告 v19 修复

- 常规宽度告警 meta 保持为单个 `Text` 句子，类型与方式共用一段文本流；禁止拆成两个 `Flexible` 形成左右分栏。
- 告警 meta 回归用「完整句子是单 widget + 分段 Text 不存在」验证，比行高阈值更能识别分栏；`didExceedMaxLines` 继续守住省略号。
