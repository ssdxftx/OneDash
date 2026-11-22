# OneDash 1Panel v2.5.1 API 全量审计报告

- 审计日期：2026-11-21
- 客户端基线：`98d7be8 fix(ui): close remaining 1Panel v2.5.1 contract gaps`
- 服务端基线：1Panel `v2.5.1`，commit `806de63`
- 服务端源码：`/tmp/1panel-v2.5.1`
- 审计范围：`lib/data/api/`、`lib/data/dto/`、`lib/data/repositories_impl/`、`lib/presentation/` 中直接拼接 API/WebSocket 路径的页面
- 审计方式：静态提取客户端调用、静态提取 Go 路由、逐模块对照 handler/service/request/response、核对字段与异步任务语义
- 代码变更：本轮只写报告，未修改业务代码

## 1. 执行摘要

路由层健康度较高。客户端 851 个唯一 `method + path` 调用全部能在面板 v2.5.1 路由表中找到对应项，未发现 404/405 型路径或方法错配。

协议层仍有较多确定问题。确认 19 个 P1、36 个 P2，主要集中在：

- 请求字段类型错误或字段缺失，导致服务端 panic、校验失败、配置被静默覆盖
- 响应字段名读错，导致列表名称、ID、状态为空或恒为 0
- 服务端异步任务已启动，客户端立即提示成功，失败不可见
- 编辑场景只提交部分字段，服务端按全量覆盖，导致原有配置丢失

覆盖情况：面板 v2.5.1 共 866 条社区版路由，客户端直接匹配 845 条，覆盖率约 97.6%。未直接调用的 21 条中，18 条属于别名、内部接口、Core/Agent 重复或已有替代，真实移动端功能缺口 4 条。

上一轮修复项已逐项复核，当前代码仍然有效。

## 2. 基线与统计

### 2.1 服务端路由

| 来源 | 路由数量 |
| --- | ---: |
| Agent `/api/v2/*` | 762 |
| Core `/api/v2/core/*` | 104 |
| 合计 | 866 |

统计包含普通 HTTP 路由，未把静态资源、内部终端、xpack 专属路由纳入移动端功能覆盖判断。

### 2.2 客户端调用

| 指标 | 数量 |
| --- | ---: |
| 唯一 `method + path` 调用 | 851 |
| 路径与方法匹配 | 851 |
| 路径或方法不匹配 | 0 |
| 直接匹配的服务端路由 | 845 |
| 未直接调用的服务端路由 | 21 |
| 路由覆盖率 | 约 97.6% |

动态路径已展开核对：

- `McpApi._base` 拼接的 `/api/v2/core/mcp/*`
- `DatabaseApi._typePath` 生成的 `/databases/pg/*`、`/databases/mongodb/*`
- AI 渠道路径 `telegram/discord/wecom/dingtalk/qqbot/feishu`
- 备份账号按 `isPublic` 切换 Core/Agent
- VM 控制台、进程、文件下载、终端等页面直接拼接的 WebSocket/下载路径

### 2.3 判定标准

| 级别 | 判定 |
| --- | --- |
| P0 | 必然失败、数据被破坏、配置被清空、安全能力被关闭，或可能操作到错误对象 |
| P1 | 主要功能错误、编辑后配置丢失、异步结果不可见、接口语义不符 |
| P2 | 字段解析错误、展示错误、低使用率接口契约偏差、功能入口缺失 |

本轮未发现必然触发的 P0。数据库删除实例名错误存在特定条件下操作到另一实例同名库的风险，按 P1 记录。

## 3. P1 问题

### P1-01 应用参数编辑把数值字段全部转成字符串，服务端 panic

- 客户端：`lib/presentation/features/app_store/widgets/installed_app_actions.dart:469`
- 服务端：`v2.5.1/agent/app/service/app_install.go:501`
- 证据：客户端对所有可编辑参数统一执行 `field.key: controllers[field.key]?.text.trim()`，端口字段发送 `"8080"`。
- 服务端：`port, ok := req.Params["PANEL_APP_PORT_HTTP"]` 后直接执行 `port.(float64)`。
- 影响：只要参数包含端口字段，`POST /api/v2/apps/installed/params/update` 在服务端 panic 并返回 500，移动端“编辑参数”基本不可用。
- 建议：按 `field.type` 转换。number 用 `num.tryParse` 后发送数字，select/multiple 按官方表单约定发送。

### P1-02 运行时创建时 `port` 被服务端丢弃

- 客户端：`lib/data/dto/runtime/runtime_dto.dart:299`、`lib/presentation/features/runtimes/screens/runtimes_page.dart:392`
- 服务端：`v2.5.1/agent/app/dto/request/runtime.go:14`、`v2.5.1/agent/app/service/runtime.go:185`
- 证据：客户端创建请求发送 `port`，服务端 `RuntimeCreate` 没有 `port` 字段，端口只来自 `create.ExposedPorts`。
- 影响：新建 Node/Java/Go/Python 运行时，用户填写的端口被静默丢弃，容器没有发布端口，业务无法访问。
- 建议：创建时把 `port` 转成 `exposedPorts: [{hostPort: port, containerPort: port, protocol: 'tcp'}]`。

### P1-03 应用安装未等待异步任务

- 客户端：`lib/presentation/features/app_store/widgets/app_install_sheet.dart:160`
- 服务端：`v2.5.1/agent/app/service/app.go:607`
- 证据：客户端已生成 `taskID` 并提交，服务端在 goroutine 中执行安装任务，接口立即返回。
- 影响：用户看到“安装成功”，实际安装可能仍在进行或已失败，失败原因只在任务日志中。
- 建议：复用 `TaskProgressSheet` + `waitForTask(taskID)`，等待任务结束后再提示和关闭。

### P1-04 网站全局访问密码不会写入 nginx 鉴权指令

- 客户端：`lib/presentation/features/websites/screens/website_advanced_page.dart:1031`
- 服务端：`v2.5.1/agent/app/service/website_auth_basic.go:84`
- 证据：客户端目标状态为启用时发送 `operate: create` 或 `edit`；服务端只有 `operate == "enable"` 分支调用 `updateNginxConfig` 写入 `auth_basic` 与 `auth_basic_user_file`，`create/edit` 只改密码文件。
- 影响：首次开启访问密码后站点仍无鉴权；关闭后重新开启走 `edit`，同样不会恢复 nginx 指令。
- 建议：启用时在 `create/edit` 成功后再发送一次 `operate: "enable"`；关闭时保持 `disable`。

### P1-05 SSL 编辑多个备用域名时分隔符不一致

- 客户端：`lib/data/dto/website/ssl_manage_dtos.dart:96`、`lib/presentation/features/websites/screens/website_ssl_manage_page.dart:936`
- 服务端：`v2.5.1/agent/app/service/website_ssl.go:815`
- 证据：客户端 `otherDomains` 回退读 `domains`，服务端 `WebsiteSSL.Domains` 是逗号拼接；更新接口按 `strings.Split(update.OtherDomains, "\n")` 拆分并逐个校验。
- 影响：含 2 个及以上附加域名的证书，编辑保存返回 `ErrDomainFormat`，无法修改备注、自动续签等字段。
- 建议：提交前把 `domains` 的逗号替换为换行。

### P1-06 新建网站勾选创建数据库时数据库可能被静默跳过

- 客户端：`lib/presentation/features/websites/screens/website_create_wizard.dart:453`、`lib/presentation/features/websites/screens/website_create_wizard.dart:969`
- 服务端：`v2.5.1/agent/app/service/website.go:396`、`v2.5.1/agent/app/dto/request/website.go:75`
- 证据：服务端用 `databaseRepo.Get(repo.WithByName(create.DbHost))` 查找已安装数据库实例，查不到时直接 `return nil`；`DataBaseConfig` 没有 `dbType` 字段。
- 客户端把 `dbHost` 做成自由文本 Host 输入，并额外提交 `dbType`，服务端不会读取该字段。
- 影响：用户填写 IP/主机名时不会创建数据库，也不会收到错误提示；MySQL/PostgreSQL 选择被丢弃。
- 建议：通过 `GET /apps/services/{dbType}` 获取实例列表，将所选实例名作为 `dbHost`；或在服务端增加 `dbType` 字段并校验实例类型。

### P1-07 新建 runtime 站点时域名端口被运行时后端端口覆盖

- 客户端：`lib/presentation/features/websites/screens/website_create_wizard.dart:271`、`lib/presentation/features/websites/screens/website_create_wizard.dart:376`
- 服务端：`v2.5.1/agent/app/service/website.go:353`
- 证据：客户端用同一个 `_portController` 同时作为 `domains[].port` 与 `RuntimeConfig.Port`。选择运行时后控制器被改写为运行时端口，例如 PHP-FPM `9000`。
- 服务端会把非默认端口写入 `primaryDomain`。
- 影响：runtime 站点容易创建成 `example.com:9000`，80/443 无法直接访问。
- 建议：拆分“站点 HTTP/HTTPS 端口”和“运行时后端端口”两个字段。

### P1-08 数据库列表把“类型”当作“实例名”查询

- 客户端：`lib/presentation/features/databases/screens/databases_page.dart:51`
- 服务端：`v2.5.1/agent/app/service/database_mysql.go:388`
- 证据：客户端 `types = instances.map((e) => e.type)`，随后 `searchDatabases(database: type)`；服务端 `mysqlRepo.WithByMysqlName(search.Database)`，`Database` 是实例名。
- 影响：实例名非默认（如 `mysql2`）或同类型存在多实例时列表漏数据；MariaDB 会命中 MySQL 查询。
- 建议：按每个实例的 `database` 字段查询，不要按类型去重。

### P1-09 数据库类型集合缺 MariaDB 和各类集群

- 客户端：`lib/presentation/features/databases/screens/databases_page.dart:48`、`lib/presentation/features/databases/screens/databases_page.dart:509`
- 服务端：`v2.5.1/agent/app/dto/database.go:145`
- 证据：本地列表固定请求 `mysql,postgresql,redis,mongodb`，远程列表固定 `['mysql','postgresql','mongodb','redis']`；服务端支持 `mariadb`、`mysql-cluster`、`postgresql-cluster`、`redis-cluster`。
- 影响：MariaDB 和集群实例的数据库完全不展示；新建 MariaDB 远程连接后列表里消失。
- 建议：补齐服务端支持的全部类型，并对 Redis 隐藏无意义的“加载数据库”动作。

### P1-10 远程数据库列表 DTO 读错字段，名称全为空

- 客户端：`lib/data/dto/database/database_instance_dto.dart:31`
- 服务端：`v2.5.1/agent/app/dto/database.go:392`
- 证据：`/databases/db/search` 返回 `dto.DatabaseInfo`，字段是 `name`；客户端只解析 `json['database']`，`name => database`。
- 影响：远程实例列表标题为空；测试连接、加载数据库、编辑都会使用空 `name`。
- 建议：`database: json['database'] ?? json['name'] ?? ''`。

### P1-11 远程数据库测试连接缺少必填 `version`

- 客户端：`lib/presentation/features/databases/screens/databases_page.dart:703`
- 服务端：`v2.5.1/agent/app/dto/database.go:431`
- 证据：`DatabaseCreate.Version` 带 `validate:"required"`；客户端测试请求只有 name/type/from/address/port/username/password/ssl/timeout。
- 影响：远程数据库“测试连接”每次都返回 400。
- 建议：请求体增加 `version`，使用当前实例版本或该类型默认版本。

### P1-12 远程数据库编辑丢失 `initialDB`、TLS 证书和 `skipVerify`

- 客户端：`lib/presentation/features/databases/screens/databases_page.dart:639`
- 服务端：`v2.5.1/agent/app/dto/database.go:452`、`v2.5.1/agent/app/service/database.go:384`
- 证据：客户端编辑只提交 name/type/from/version/database/address/port/username/password/description/ssl/timeout；服务端 `DatabaseUpdate` 包含 `initialDB/rootCert/clientKey/clientCert/skipVerify`，更新时全量覆盖。
- 影响：编辑远程 PG 会清空 `initialDB`；编辑启用 SSL 的远程 Mongo/MySQL 会清空证书并重置 `skipVerify`。
- 建议：编辑前调用 `GET /databases/db/:name` 获取完整详情，并回填提交这些字段。

### P1-13 数据库列表页删除 PG/Mongo 时把库名当实例名

- 客户端：`lib/presentation/features/databases/screens/databases_page.dart:388`
- 服务端：`v2.5.1/agent/app/service/database_postgresql.go:304`、`v2.5.1/agent/app/service/database_mongodb.go:286`
- 证据：删除调用使用 `database: item.name`；PG `LoadPostgresqlClientByFrom(req.Database)` 和 Mongo `runMongodbDelete(db.From, req.Database, db.Name)` 都把 `req.Database` 当实例名。
- 影响：从列表页删除本地 PG/Mongo 数据库失败；若存在与库名相同的另一实例，存在连接到错误实例并删除同名库的风险。
- 建议：改为 `item.instanceName`。

### P1-14 备份账号凭据双重 base64

- 客户端：`lib/presentation/features/backups/screens/backup_accounts_page.dart:372`、`lib/presentation/features/backups/screens/backup_accounts_page.dart:398`
- 服务端：`v2.5.1/agent/app/service/backup.go:117`、`v2.5.1/agent/app/service/backup.go:143`
- 证据：搜索返回的 `accessKey/credential` 已是 `StringDecryptWithBase64` 的结果；页面 `_encode` 又编码一次。服务端 `CheckConn` 只解码一次。
- 影响：`rememberAuth=true` 的账号测试连接/列桶必失败；编辑保存会把已存密钥改成双重 base64，后续连接全部失效。
- 建议：列表回填时先 base64 解码为明文，提交时只编码一次。

### P1-15 SSH 配置文件保存把 path 与 value 传反

- 客户端：`lib/presentation/features/host/screens/host_page.dart:762`、`lib/data/api/host_api.dart:243`
- 服务端：`v2.5.1/agent/app/service/ssh.go:875`
- 证据：签名是 `updateSshFile(String key, String path, String value)`，调用却是 `updateSshFile('sshdConfPath', value, path)`。
- 服务端把 `req.Path` 当文件路径并执行 `isSSHConfigPathAllowed`。
- 影响：SSH 配置文件编辑保存必然失败。
- 建议：改为 `updateSshFile('sshdConfPath', path, value)`。

### P1-16 保存代理设置会清空已存代理密码

- 客户端：`lib/presentation/features/panel_settings/screens/advanced_settings_pages.dart:277`
- 服务端：`v2.5.1/core/app/service/setting.go:399`
- 证据：页面不加载旧密码，也没有“保留密码”选项；`updatePanelProxy` 默认 `proxyPasswdKeep=false`，服务端把空密码加密后写回 `ProxyPasswd`。
- 影响：只改代理地址、端口或 Docker 开关就会静默清除代理认证密码。
- 建议：密码为空时传 `proxyPasswdKeep: true`，或显式回填/保留原密码。

### P1-17 计划任务更新会清空分组、备份密码、排除规则等字段

- 客户端：`lib/presentation/features/cronjobs/screens/cronjob_form_page.dart:236`
- 服务端：`v2.5.1/agent/app/service/cronjob.go:820`
- 证据：服务端无条件写入 `group_id`、`secret`、`exclusion_rules`、`args`、`command`、`container_name`、`user`、`executor`；客户端 `CronjobCreateReq` 虽支持这些字段，但表单构造请求时未携带。快照规则也重建为 `SnapshotRuleDto(withImage: _withImage)`，丢失 `ignoreAppIDs`。
- 影响：通过移动端编辑任一计划任务会把任务移回默认分组、清空备份压缩密码/排除规则/容器执行用户等；备份任务后续归档可能不再加密。
- 建议：加载时保留并回传这些字段，或服务端改为 patch 语义。重点处理 `secret`、`groupID`、`snapshotRule`。

### P1-18 VM 异步任务等待器默认 30 秒，长任务被误报失败

- 客户端：`lib/data/api/task_waiter.dart:10`、`lib/data/api/vm_api.dart:354`
- 服务端：`v2.5.1/agent/app/service/vm.go:522`
- 证据：`TaskWaiter` 默认 `500ms × 60`，VM 调用使用默认配置；服务端 VM 子任务超时为 30 分钟，并在 goroutine 中执行。
- 影响：VM 创建/更新/重命名/删除/模板创建/快照创建超过 30 秒即抛 `timedOut`，服务端仍在继续执行。
- 建议：VM 任务使用 2 秒间隔、300 次以上，或按任务状态持续轮询。

### P1-19 AI 插件/技能/渠道安装不等待任务

- 客户端：`lib/data/api/ai_api.dart:496`、`lib/data/api/ai_api.dart:1167`
- 服务端：`v2.5.1/agent/app/api/v2/agents.go:1471`、`v2.5.1/agent/app/service/agents_plugins.go:101`
- 证据：客户端 `_awaitTask` 只在 `data['queued'] == true && taskID` 时等待；安装类接口统一返回 `helper.Success(c)`，`data` 为 null。服务端实际在 goroutine 中执行安装任务。
- 影响：插件/技能/渠道安装、升级、卸载提示成功但列表/状态未变化；渠道安装后立即检查状态会得到旧状态。
- 建议：使用调用方已生成的 `taskID` 主动通过 `TaskWaiter` 等待，完成后再刷新列表。

## 4. P2 问题

### 4.1 应用与容器

| 编号 | 问题 | 客户端 | 服务端 | 影响 |
| --- | --- | --- | --- | --- |
| P2-01 | 忽略升级 ID 读大写 `ID` | `lib/data/dto/app/app_ignored_dto.dart:31` | `v2.5.1/agent/app/model/base.go:6` | 服务端字段是 `id`，客户端恒为 0，取消忽略调用 `cancelIgnore(0)` 返回 400 |
| P2-02 | 忽略状态用 install id 对比 appID | `lib/presentation/features/app_store/providers/app_store_provider.dart:248` | `v2.5.1/agent/app/model/app_ignore_upgrade.go:4` | 忽略后 UI 仍显示“忽略更新” |
| P2-03 | Compose 删除未传 `withFile` | `lib/presentation/features/containers/screens/compose_page.dart:405` | `v2.5.1/agent/app/service/container_compose.go:498` | 容器删除成功，目录和 compose 文件残留 |
| P2-04 | 运行时创建/删除异步未等待 | `lib/data/api/runtime_api.dart:30`、`lib/data/api/runtime_api.dart:63` | `v2.5.1/agent/app/service/runtime.go:239`、`:392` | 创建/删除立即提示成功，失败不可见 |
| P2-05 | PHP 扩展安装异步未等待 | `lib/presentation/features/runtimes/screens/runtime_detail_page.dart:297` | `v2.5.1/agent/app/service/runtime.go:993` | 刷新后扩展状态未变化，用户可能重复点击 |
| P2-06 | 镜像更新检查异步未等待 | `lib/presentation/features/containers/screens/container_resources_page.dart:161` | `v2.5.1/agent/app/service/container_image_check_update.go:76` | 立即提示检查完成，更新数量未刷新 |
| P2-07 | 镜像推送忽略“新镜像名” | `lib/presentation/features/containers/screens/container_resources_page.dart:697` | `v2.5.1/agent/app/service/image.go:460` | `name` 仍使用原镜像名，用户输入的目标名无效 |
| P2-08 | 按 id 获取应用详情的 DTO 不匹配 | `lib/data/api/app_api.dart:146` | `v2.5.1/agent/app/dto/response/app.go:69` | 返回 `model.AppDetail`，客户端按 `AppDetailDto` 解析，名称/描述为空；当前页面未使用 |

### 4.2 网站与文件

| 编号 | 问题 | 客户端 | 服务端 | 影响 |
| --- | --- | --- | --- | --- |
| P2-09 | 网站批量启停/批量 SSL 异步未等待 | `lib/presentation/features/websites/screens/websites_page.dart:126` | `v2.5.1/agent/app/service/website_op.go:14` | 列表刷新早于任务完成，失败无感知 |
| P2-10 | 代理缓存单位固定为 `m/m/h` | `lib/presentation/features/websites/screens/website_detail_page.dart:591` | `v2.5.1/agent/app/dto/request/nginx.go:45` | 原本 `10g` 缓存上限被改成 `10m` |
| P2-11 | 防盗链无法编辑 `serverNames` 白名单 | `lib/presentation/features/websites/screens/website_advanced_page.dart:1207` | `v2.5.1/agent/app/dto/request/nginx.go:82` | 只能原样回传已有域名，首次启用无法添加自己的域名 |
| P2-12 | OpenResty 构建任务不等待 | `lib/presentation/features/websites/screens/openresty_advanced_sheets.dart:432` | `v2.5.1/agent/app/service/nginx.go:186` | 构建失败或模块未生效时用户无从得知 |
| P2-13 | 文件“精确大小”对普通文件调用目录统计 | `lib/presentation/features/files/screens/files_page.dart:1047` | `v2.5.1/agent/app/service/file.go:1356` | `du -s` 返回磁盘块占用，1 字节文件可能显示 4KB |
| P2-14 | 删除 deployment 网站未暴露 `deleteApp` | `lib/presentation/features/websites/screens/websites_page.dart:1210` | `v2.5.1/agent/app/dto/request/website.go:111` | 删除站点后关联应用残留 |
| P2-15 | SSL 申请固定 `provider: http` | `lib/presentation/features/websites/screens/website_ssl_manage_page.dart:405` | `v2.5.1/agent/app/service/website_ssl.go:227` | 已配置的 DNS 账号无法用于签发泛域名证书 |

### 4.3 数据库、主机与设置

| 编号 | 问题 | 客户端 | 服务端 | 影响 |
| --- | --- | --- | --- | --- |
| P2-16 | MySQL 状态弹窗用库名当实例名 | `lib/presentation/features/databases/screens/database_detail_page.dart:399` | `v2.5.1/agent/app/service/database_mysql.go:1455` | 状态查看失败 |
| P2-17 | 终端会话列表/关闭缺少身份头 | `lib/data/api/host_api.dart:301` | `v2.5.1/agent/app/api/v2/terminal.go:177` | 服务端返回 missing terminal identity |
| P2-18 | PostgreSQL 慢日志类型服务端不支持 | `lib/presentation/features/databases/widgets/database_advanced_tab.dart:56` | `v2.5.1/agent/app/service/file.go:1453` | `postgresql-slow-logs` 进入 default 分支报 `ErrNotSupportType` |
| P2-19 | MongoDB 配置文件编辑被校验拒绝 | `lib/presentation/features/databases/widgets/database_advanced_tab.dart:43` | `v2.5.1/agent/app/dto/database.go:8` | `DBConfUpdateByFile.Type oneof` 不含 mongodb |
| P2-20 | 远程 Redis 的“加载数据库”走 MySQL 接口 | `lib/presentation/features/databases/screens/databases_page.dart:726` | `v2.5.1/agent/app/dto/database.go:145` | `MysqlLoadDB.Type oneof` 不含 redis，必失败 |
| P2-21 | 防火墙规则固定 100 条，无分页 | `lib/data/api/firewall_api.dart:31` | `v2.5.1/agent/app/dto/firewall.go:161` | 规则超过 100 条时列表不完整 |
| P2-22 | 快照创建未提交 `appData/backupData` | `lib/presentation/features/panel_settings/screens/snapshot_page.dart:430` | `v2.5.1/agent/app/dto/snapshot.go:12` | 应用镜像和备份数据可能不进入快照 |
| P2-23 | 网站模板产物未提交 `TemplateOutputID` | `lib/data/dto/website/website_template_dto.dart:140` | `v2.5.1/agent/app/dto/request/website.go:37` | 模板只能生成，无法直接落地到新站点 |
| P2-24 | 文件远程下载未暴露 `useProxy`、`useServerFilename` | `lib/data/api/file_api.dart:763` | `v2.5.1/agent/app/dto/request/file.go:119` | 移动端无法使用服务端代理和服务器文件名 |

### 4.4 AI、MCP 与 VM

| 编号 | 问题 | 客户端 | 服务端 | 影响 |
| --- | --- | --- | --- | --- |
| P2-25 | MCP 服务器更新未回传网关字段 | `lib/presentation/features/ai/screens/ai_mcp_actions.dart:139` | `v2.5.1/agent/app/service/mcp_server.go:111` | `hostIP/gatewayImage/protocolVersion/gatewayArgs/streamableHttpPath` 被清空 |
| P2-26 | VM 更新未回传 `isoPaths` | `lib/presentation/features/vm/screens/vm_page.dart:827` | `v2.5.1/agent/app/service/vm.go:631` | 改 CPU/内存可能丢失 ISO 挂载 |
| P2-27 | VM 创建无 ISO 选择 | `lib/presentation/features/vm/screens/vm_page.dart:291` | `v2.5.1/agent/app/service/vm.go:452` | 没有模板的新环境无法创建虚拟机 |
| P2-28 | VM 快照恢复/删除、磁盘扩容未等待任务 | `lib/data/api/vm_api.dart:135`、`lib/data/api/vm_api.dart:222` | `v2.5.1/agent/app/service/vm.go:813` | UI 立即提示成功，状态仍旧 |
| P2-29 | `rememberApiKey=false` 的 AI 账号无法编辑/发现模型 | `lib/presentation/features/ai/screens/ai_accounts_actions.dart:380` | `v2.5.1/agent/app/dto/agents.go:360` | 服务端要求 `apiKey` 必填，列表返回空 key |
| P2-30 | AI 账号编辑重置 `authMode` | `lib/presentation/features/ai/screens/ai_accounts_actions.dart:164` | `v2.5.1/agent/app/dto/agents.go:364` | 非默认认证方式的账号被改回默认值 |
| P2-31 | Ollama“加载模型”返回详情被丢弃 | `lib/data/api/ai_api.dart:57` | `v2.5.1/agent/app/api/v2/ai.go:121` | 接口返回 `ollama show` 详情，客户端按 void 丢弃 |
| P2-32 | 新增告警通知预填第一个已启用配置 | `lib/presentation/features/alerts/screens/alerts_page.dart:717` | `v2.5.1/agent/app/service/alert.go:476` | 新增会复制现有配置，企业/中文版触发唯一名冲突 |
| P2-33 | AI Provider 能力标志被 DTO 丢弃 | `lib/data/dto/ai/ai_provider_dto.dart:15` | `v2.5.1/agent/app/dto/agents.go:425` | `editableBaseUrl`、`supportsModelDiscovery` 未解析，UI 无法限制能力 |
| P2-34 | 创建 `custom/vllm/ollama/llmman` 账号未提交 `models` | `lib/presentation/features/ai/screens/ai_accounts_actions.dart:152` | `v2.5.1/agent/app/service/agents_utils.go:1518` | 这些 provider 无初始模型时返回 `ErrAgentAccountModelsRequired` |
| P2-35 | VM ISO 编辑未回传 `description` | `lib/presentation/features/vm/widgets/vm_resources_sheet.dart:708` | `v2.5.1/agent/app/service/vm-iso.go:119` | 编辑 ISO 名称/路径后描述丢失 |
| P2-36 | VM ISO 导入未提交 `tempFileID` | `lib/presentation/features/vm/widgets/vm_resources_sheet.dart:521` | `v2.5.1/agent/app/service/vm-iso.go` | 仅创建记录并直接标记 ready，未真正上传文件 |

## 5. 功能覆盖缺口

### 5.1 未直接调用的真实功能缺口

| 接口 | 影响 | 优先级 |
| --- | --- | --- |
| `POST /api/v2/ai/agents/channel/weixin/get` | 无法查看微信渠道配置，当前只有登录入口 | P3 |
| `GET /api/v2/apps/detail/node/:appKey/:version` | 创建 Node 运行时无法按应用 key/版本自动解析 | P3 |
| `POST /api/v2/databases/db/del/check` | 远程数据库删除前缺少占用检查 | P2 |
| `POST /api/v2/hosts/update/group` | 无法在移动端调整远程主机分组 | P3 |

### 5.2 参数级能力缺口

- SSL 申请固定 `provider: http`，已配置 DNS 账号无法用于签发泛域名证书。
- 网站模板产物未提交 `TemplateOutputID`，模板只能生成不能直接落地。
- 文件远程下载未暴露 `useProxy`、`useServerFilename`。
- 文件分享 UI 固定 60 分钟，未使用已支持的 `password` 字段。
- AI 创建 `custom/vllm/ollama/llmman` 账号未提供模型列表录入。
- VM ISO 导入未真正提交上传文件。

## 6. 上一轮修复复核

以下项目已逐项核对，当前代码仍然正确：

- 容器 CPU/内存单位与类型：`NanoCPUs` 为核、`Memory` 为 MB。
- Compose 环境变量按字符串解析、编辑请求补 `from: 'edit'`、多文件 compose 取首个文件。
- 镜像仓库编辑使用 `repo/search` 完整数据，认证仓库编辑要求重新输入密码。
- 告警配置 `revision` 回退读取 `updatedAt`，更新时携带 `displayName`。
- 系统清理只提交 `canDelete && isCheck` 节点。
- SSH 密钥编辑先解码 `passPhrase`，避免二次 Base64。
- 镜像导出 path 默认留空，归档文件名与镜像 tag 分离。
- 防火墙恢复备份走 `/hosts/firewall/rules`，`initialize: true`。
- 修改密码后 invalidate 面板设置并重新登录。
- 运行时端口只更新首个目标端口，`ExposedPort` 保留 `protocol`。
- 远程数据库新增/删除路由、MFA 安全入口头、代理设置 Core/Agent 分离、API Key 白名单与 `allowAppBinding`、Passkey 会话持久化、公共备份账号 Core 路由。
- 网站 SSL 详情兜底、默认文档关闭、更换数据库默认值、SSL 导入。
- VM 控制台初始化和 WebSocket 预检、终端 WebSocket 鉴权。

## 7. 验证结果

- `flutter analyze --fatal-infos`：通过，0 issues。
- `flutter test test/unit/api_request_contract_test.dart`：120 项全部通过。
- 本轮未修改业务代码，`pubspec.lock` 已恢复。
- 工作区未跟踪文件仍为 APK 与 `tool/ui_audit/shots/`。

## 8. 建议修复顺序

1. 数据与配置类 P1：数据库列表/远程 DTO/删除实例名、备份账号 base64、计划任务更新、SSH 配置保存、代理密码。
2. 应用与网站主流程：应用参数类型、运行时端口、网站访问密码、SSL 多域名、建站建库、runtime 站点端口。
3. 统一异步任务：应用安装、AI 安装、VM 任务、网站批量操作、镜像检查，全部复用 `TaskWaiter` 并延长 VM 超时。
4. P2 展示与语义问题，以及 4 条覆盖缺口。

## 9. 未直接调用的 21 条路由分类

| 方法 | 路径 | 分类 |
| --- | --- | --- |
| POST | `/api/v2/ai/agents/channel/weixin/get` | 真实缺口 |
| GET | `/api/v2/apps/detail/node/:appKey/:version` | 真实缺口 |
| POST | `/api/v2/databases/db/del/check` | 真实缺口 |
| POST | `/api/v2/hosts/update/group` | 真实缺口 |
| GET | `/api/v2/apps/installed/list` | `installed/search` 替代 |
| POST | `/api/v2/containers/list` | `containers/search` 替代 |
| GET | `/api/v2/containers/repo` | `repo/search` 替代 |
| GET | `/api/v2/containers/template` | `template/search` 替代 |
| GET | `/api/v2/websites/list` | `websites/search` 替代 |
| POST | `/api/v2/websites/ssl/list` | `ssl/search` 替代 |
| POST | `/api/v2/core/commands/list` | `commands/search` 替代 |
| POST | `/api/v2/internal/terminal/sessions/revoke` | 内部接口 |
| GET | `/api/v2/internal/terminal/capabilities` | 内部接口 |
| GET | `/api/v2/core/hosts/diagnostics/summary` | Agent 同名接口已覆盖 |
| GET | `/api/v2/core/hosts/diagnostics/goroutines` | Agent 同名接口已覆盖 |
| POST | `/api/v2/core/hosts/diagnostics/profiles` | Agent 同名接口已覆盖 |
| POST | `/api/v2/core/settings/search/base` | 已有 Core 设置接口替代 |
| GET | `/api/v2/core/settings/search/available` | 低价值，无移动端入口 |
| POST | `/api/v2/core/settings/ssl/reload` | 内部接口 |
| POST | `/api/v2/hosts/info` | 主页/主机列表信息已覆盖 |
| GET | `/api/v2/settings/search/available` | 低价值，无移动端入口 |
