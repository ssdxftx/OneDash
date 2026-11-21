# OneDash 1Panel v2.5.1 API 全量审计报告

- 审计日期：2026-11-20
- 客户端基线：`ca53eb2 fix(ui): bound subtitle shrink and align server address format`
- 服务端基线：1Panel `v2.5.1`，commit `806de63`
- 服务端源码位置：`/tmp/1panel-v2.5.1`
- 客户端审计范围：`lib/data/api/`、`lib/data/dto/`、`lib/data/repositories_impl/`，以及直接拼接 API/WebSocket 路径的页面代码
- 审计方式：路径与方法静态匹配、Go 路由/handler/service/request/response 源码对照、DTO 字段核对、现有测试覆盖检查
- 代码变更：本轮只写报告，未修改业务代码

## 1. 执行摘要

路由层整体健康：客户端的 HTTP 调用均能在 1Panel v2.5.1 路由表中找到对应路径和 HTTP 方法，未发现 404 型接口或明显的方法错配。

协议与业务层存在较多确定问题，集中在以下区域：

- 容器 CPU/内存单位与类型错误，涉及数据写坏风险
- Compose 环境变量、测试、多文件编排处理错误
- 镜像仓库、镜像导出和镜像构建的请求语义错误
- 防火墙“恢复备份”走进了“重置规则”接口
- 工具箱系统清理可能删除不可删除目录
- 数据库新增、删除和状态查询存在错误路由或错误类型
- 面板 MFA、代理设置、API 配置和 API Key 的会话与字段处理错误
- 公共备份账号在社区版中创建后不可见
- 网站 SSL 详情、默认文档、更换数据库存在数据展示或解绑风险

覆盖情况：服务端 v2.5.1 共有 866 条路由定义，客户端没有直接调用的有 31 条。31 条中多数是别名、Core/Agent 重复路由或 Web 专用流程；真正建议补齐的主要是 VM 控制台初始化、网站 SSL 按站点查询、网站完整列表、远程数据库删除链路等。

现有 438 个 Flutter 测试全部通过，当前问题没有被这些测试覆盖。本轮没有真实面板凭据，所有写操作结论来自源码对照，仍需要真实 1Panel v2.5.1 环境回归。

## 2. 审计范围与基线

### 2.1 服务端路由规模

| 来源 | 路由数量 |
| --- | ---: |
| Agent 路由 `/api/v2/*` | 762 |
| Core 路由 `/api/v2/core/*` | 104 |
| 合计 | 866 |

统计包含普通 HTTP 路由；未把 xpack、internal、静态资源路由纳入移动端覆盖范围。

### 2.2 客户端调用规模

| 指标 | 数量 |
| --- | ---: |
| 数据层 API 调用点 | 841 |
| 去掉重复后的唯一 `method + path` | 817 |
| 直接拼接在页面/网络层的 WebSocket 或下载路径 | 另行手工核对 |
| 路径或方法与服务端路由不匹配 | 0 |

动态路径已单独解析，包括：

- `McpApi._base` 拼接的 `/api/v2/core/mcp/*`
- `DatabaseApi._typePath` 生成的 `/databases/pg/*`、`/databases/mongodb/*`
- 备份账号按 `isPublic` 条件切换到 Core 或 Agent
- 文件、终端、VM 控制台、下载等直接拼接的路径

### 2.3 判定标准

| 级别 | 判定 |
| --- | --- |
| P0 | 必然失败、数据被破坏、配置被清空、安全能力被关闭，或可能操作到错误对象 |
| P1 | 主要功能错误、编辑后配置丢失、异步结果不可见、接口语义不符 |
| P2 | 字段解析错误、展示错误、低使用率接口契约偏差 |

## 3. P0 问题

### P0-01 容器 CPU/内存单位与类型双重错误

- 客户端：`lib/data/dto/container/container_info_dto.dart:47-49,117-119`
- 客户端：`lib/presentation/features/containers/screens/container_create_page.dart:105-110,301-302`
- 客户端：`lib/presentation/features/containers/screens/container_detail_page.dart:476-478`
- 服务端：`agent/app/dto/container.go:124-125`
- 服务端：`agent/app/service/container.go:683-687,1925-1926`

服务端 `NanoCPUs` 是 `float64`，单位是“核”；`Memory` 也是 `float64`，单位是 MB。客户端把两个字段声明为 `int`，读取后按纳核和字节换算，提交时又乘以 `1e9` 和 `1024*1024`。

影响：

- `nanoCPUs=0.5` 等小数值会解析失败
- 编辑已有容器时 CPU/内存显示为 0
- 保存时限制值被放大数亿倍，Docker 拒绝或生成异常限制
- 详情页把 MB 当字节显示

建议：DTO 改为 `double`，界面按“核/MB”展示和提交，移除 `1e9` 与 `1024*1024` 的二次换算。

### P0-02 Compose 环境变量解析类型错误

- 客户端：`lib/data/api/container_api.dart:915-921`
- 服务端：`agent/app/service/container_compose.go:694-700`

服务端 `LoadComposeEnv` 返回 `.env` 文件全文 `string`。客户端使用 `ApiResponseParser.primitiveList<String>`，当 `data` 为字符串时直接抛出 `ApiFormatException`。

影响：存在 `.env` 的编排项目，打开“环境变量”面板必然报错。

建议：改为 `ApiResponseParser.primitive<String>` 或直接读取 `data` 字符串。

### P0-03 编辑 Compose 后测试缺少必填字段 `from`

- 客户端：`lib/presentation/features/containers/screens/compose_form_page.dart:88-118`
- 服务端：`agent/app/dto/container.go:319-329`

编辑分支的 `_payload` 没有 `from`。服务端 `ComposeCreate.From` 带 `validate:"required,oneof=edit path template"`，测试请求会在绑定校验阶段失败。

影响：编辑任意 Compose 后点击“测试编排”返回 400。

建议：编辑请求补 `from: 'edit'`，或为测试构造独立载荷。

### P0-04 多文件 Compose 被当成单个文件

- 客户端：`lib/presentation/features/containers/screens/compose_form_page.dart:63-66,95`
- 服务端：`agent/app/dto/container.go:298-311`
- 服务端：`agent/app/service/container.go:397-410`
- 服务端：`agent/app/service/container_compose.go:549-553`

`ComposeInfo.configFile` 来自 Docker Compose 的 `config_files`，多文件时是逗号分隔列表。客户端把整个字符串传给 `detail` 和 `detailPath`。

影响：多 `-f` 或多 compose 文件项目查看、编辑时报“compose file 不属于该项目”或文件读取失败。

建议：按官方前端做法取第一个文件作为 `detail`/`detailPath`，同时保留完整文件列表用于展示。

### P0-05 镜像仓库编辑把 `Option` 当完整仓库对象

- 客户端：`lib/data/api/container_api.dart:560-567`
- 客户端：`lib/data/dto/container/image_dtos.dart:62-75`
- 客户端：`lib/presentation/features/containers/screens/container_resources_page.dart:1075-1091,1297-1306`
- 服务端：`agent/app/dto/image_repo.go:36-40`
- 服务端：`agent/app/service/image_repo.go:67-80`

`GET /containers/repo` 返回 `[]ImageRepoOption`，字段只有 `id/name/downloadUrl`，并且只返回成功状态的仓库。客户端把它解析成完整 `ImageRepoDto`，编辑时协议回退为 `https`、鉴权回退为 `false`、用户名密码为空。

影响：

- 编辑 `http` 协议仓库会被静默改回 `https`
- 编辑带鉴权的仓库会清空凭据
- 失败状态的仓库不出现在管理列表，无法修复或删除

建议：列表展示和编辑使用 `repo/search` 的完整 `ImageRepo` 数据；`repo` 接口只用于选择器。

### P0-06 防火墙“恢复备份”实际执行重置

- 客户端：`lib/data/api/firewall_api.dart:353-358`
- 客户端：`lib/presentation/features/firewall/screens/firewall_page.dart:338,760`
- 服务端：`agent/app/dto/firewall.go:148-159,278-281`
- 服务端：`agent/app/api/v2/firewall.go:228-239`

客户端把 `backupFile` 发到 `/hosts/firewall/rules/reset`。`FirewallRuleReset` 没有 `backupFile` 字段，Go 会丢弃。恢复备份的真实入口是 `/hosts/firewall/rules` 的 `FirewallRuleCreate.BackupFile`。

影响：点击“恢复备份”会执行重置规则，存在规则丢失风险。

建议：恢复操作改调 `/hosts/firewall/rules`，提交 `initialize` 或 `backupFile` 与空 `items`，按服务端语义分支。

### P0-07 工具箱系统清理忽略树结构与 `canDelete`

- 客户端：`lib/presentation/features/toolbox/screens/toolbox_device_page.dart:315-345`
- 服务端：`agent/app/dto/setting.go:55-67`
- 服务端：`agent/app/service/device_clean.go:47-56,94-115`

客户端只遍历每组顶层节点，直接提交 `treeType/name/size`，没有递归 `children`，也没有检查 `canDelete`/`isCheck`。`1panel_original` 和回滚目录的 `canDelete` 为 `false`，名称可能为空；服务端对空名称会拼接目录根路径并删除整个目录。

影响：清理操作可能删除服务端标记为不可删除的目录，同时漏掉真正的可清理叶子项。

建议：递归收集 `canDelete && isCheck` 的叶子节点，按服务端树结构提交。

### P0-08 VM 控制台 WebSocket 预检必然失败

- 客户端：`lib/presentation/features/vm/screens/vm_console_page.dart:64-86`
- 客户端：`lib/core/network/web_socket_connector.dart:28-93`
- 服务端：`agent/app/api/v2/vm.go:532-541`
- 服务端：`agent/app/api/v2/helper/helper.go:26-33`

客户端先对 `/api/v2/vms/console/ws` 发普通 HTTP GET 预检。服务端在非 WebSocket 升级时返回 HTTP 200 + JSON `code=400`，预检会抛 `ApiBusinessException`，连接不会继续。

另外客户端没有先调用 `POST /api/v2/vms/console` 获取控制台图形参数。

影响：VM 控制台无法打开。

建议：先调用 `POST /vms/console` 获取初始化数据，再直接建立 WebSocket；预检只接受 401 或无 body 的握手错误。

### P0-09 SSH 密钥编辑必然失败

- 客户端：`lib/presentation/features/host/screens/host_page.dart:987-994`
- 服务端：`agent/app/service/ssh.go:565-568,1721-1725`

客户端编辑只提交 `id/name/encryptionMode/description`，空密钥字段在 `toJson` 中被省略。服务端 `EditRootCert` 始终调用 `validateSSHKeyPair`，公钥为空直接返回 `ErrSSHPublicKey`。

影响：SSH 密钥无法重命名或修改备注，所有编辑请求失败。

建议：编辑前读取完整证书，按服务端要求回传 Base64 编码的公钥、私钥和口令。

### P0-10 新增远程数据库必失败，创建走成更新

- 客户端：`lib/presentation/features/databases/screens/databases_page.dart:586-605`
- 服务端：`agent/app/dto/database.go:431-445`
- 服务端：`agent/router/ro_database.go:51-56`

新增时 `version` 为 `''`，服务端 `DatabaseCreate.Version` 必填。新增和编辑都调用 `updateRemoteDatabase`，新增请求没有 `id`，服务端按 `id=0` 更新。

影响：新增 MySQL/PostgreSQL/MongoDB 远程实例在测试连接阶段即失败；即使绕过校验，也不会创建记录。

建议：新增走 `/databases/db/check` 与 `/databases/db`，编辑走 `/databases/db/update`；表单补版本选择。

### P0-11 数据库列表删除使用错误类型和错误路由

- 客户端：`lib/presentation/features/databases/screens/databases_page.dart:376-386`
- 客户端：`lib/data/api/database_api.dart:963-967`
- 服务端：`agent/router/ro_database.go:32-33,58-59,65-66,80-81`

列表行删除把 `item.from`（`local/remote`）当成数据库类型传入 `deleteDatabase`。`_typePath` 只识别 `postgresql` 和 `mongodb`，因此 PostgreSQL/MongoDB 的删除请求会落到 MySQL 的 `/databases/del`。

影响：

- PostgreSQL/MongoDB 删除失败
- 若 ID 与其他 MySQL 记录冲突，可能删除错误对象
- 远程数据库同样无法走 `/databases/db/del`

建议：删除使用 `item.dbType`，远程数据库按 `from=remote` 走 `/databases/db/del`，删除前检查也对应切换。

### P0-12 MFA 二次登录缺少 `EntranceCode`

- 客户端：`lib/data/api/setting_api.dart:84-92`
- 客户端：`lib/presentation/features/settings/screens/panel_settings_page.dart:887-890,924-927`
- 服务端：`core/app/api/v2/auth.go:104-110`
- 服务端：`core/app/auth/auth.go:140-142`

首次登录会把安全入口写入 MFA session。`MFALogin` 只从请求头读取 `EntranceCode`，并与 session 中的值比较。客户端的 MFA 请求只发送 `sessionId/code`，没有安全入口头。

影响：启用安全入口后，密码登录可以进入 MFA 阶段，提交验证码时返回 `ErrEntrance`，无法完成登录。

建议：`loginPanelMfa` 增加 `entrance` 参数并复用 `_entranceHeaders`，界面把首次登录输入的安全入口传入。

### P0-13 代理设置读取了 Agent 设置

- 客户端：`lib/presentation/features/panel_settings/screens/advanced_settings_pages.dart:245-264`
- 客户端：`lib/data/api/setting_api.dart:414-421,481-505`
- 服务端：`agent/app/dto/setting.go:3-30`
- 服务端：`core/app/dto/setting.go:55-60`

页面通过 Agent `/api/v2/settings/search` 读取配置，Agent 的 `SettingInfo` 不含 `proxyType/proxyUrl/proxyPort/proxyUser/proxyPasswd/proxyDocker/withDockerRestart`。这些字段只在 Core `/api/v2/core/settings/search` 中。

影响：

- 代理表单始终显示为空
- 保存时会把已有代理用户名、密码、Docker 代理和重启选项覆盖为空或 false

建议：代理页改用 `searchCoreSettings`，保存继续使用 Core `/core/settings/proxy/update`。

### P0-14 代理“记住密码”枚举值错误

- 客户端：`lib/data/api/setting_api.dart:487,501`
- 服务端：`core/app/dto/setting.go:201-209`
- 服务端：`core/app/service/setting.go:143,403`

客户端发送 `'true'/'false'`，服务端 `ProxyPasswdKeep` 是字符串枚举，只识别 `Enable/Disable`。

影响：记住密码永远无法生效，后续保存容易清空代理密码。

建议：改为发送 `Enable/Disable`，并回填已有配置。

### P0-15 切换 API 接口会清空白名单和有效期

- 客户端：`lib/data/api/setting_api.dart:900-904`
- 客户端：`lib/presentation/features/panel_settings/screens/panel_settings_page.dart:706-709`
- 服务端：`core/app/auth/auth.go:354-375`

客户端只发送 `apiInterfaceStatus` 和 `apiKey`。服务端对 `ApiInterfaceStatus`、`ApiKey`、`IpWhiteList`、`ApiTrustedProxies`、`ApiKeyValidityTime` 全部执行 `UpdateOrCreate`。

影响：

- 每次开关 API 接口都会清空 IP 白名单和可信代理
- `apiKeyValidityTime` 被写成 0，时间戳校验被关闭

建议：更新前读取完整 API 配置，或只提交服务端定义的部分更新接口；移动端至少补齐四个字段的现有值。

### P0-16 创建 API Key 默认空白名单必失败

- 客户端：`lib/data/api/setting_api.dart:929-952`
- 客户端：`lib/presentation/features/panel_settings/screens/panel_settings_page.dart:1341-1405`
- 服务端：`core/app/service/api_key.go:136-145`

客户端默认 `ipWhiteList=''`，创建表单只校验名称。服务端 `validateAPIKeyFields` 对空白名单调用 `HandleIPList` 后返回空列表，随后返回 `ErrInvalidParams`。

影响：按默认流程创建 API Key 直接失败。

建议：默认填充 `0.0.0.0/0\n::/0`，或要求用户填写并在客户端校验。

### P0-17 编辑 API Key 会重置 `allowAppBinding`

- 客户端：`lib/data/api/setting_api.dart:956-980`
- 客户端：`lib/presentation/features/panel_settings/screens/panel_settings_page.dart:1489-1498`
- 服务端：`core/app/service/api_key.go:274-283`

编辑请求没有传入 `item.allowAppBinding`，参数默认 false。服务端更新时直接覆盖该字段。

影响：编辑任何已开启 App 绑定的 Key，都会静默关闭绑定能力。

建议：ApiKey 列表回填 `allowAppBinding`，更新时原样提交。

### P0-18 Passkey 登录成功后没有持久化会话

- 客户端：`lib/data/repositories_impl/setting_repository_impl.dart:431-439`
- 客户端：`lib/data/repositories_impl/setting_repository_impl.dart:70-71`
- 客户端：`lib/data/api/setting_api.dart:824-849`

`passkeyFinishLogin` 只更新内存中的 Dio 会话，Repository 没有调用 `_storage.savePanelSession`。`hasPanelSession` 读取的是持久化存储。

影响：Passkey 登录后设置页仍显示未登录，重启 App 会话丢失。

建议：与密码登录一致，在 Repository 中保存 `PanelSession`。

### P0-19 修改密码后本地会话仍保留

- 客户端：`lib/data/api/setting_api.dart:529-543`
- 客户端：`lib/presentation/features/panel_settings/screens/panel_settings_page.dart:1988-1999`
- 服务端：`core/app/auth/auth.go:316-338`

服务端在提交新密码后删除当前会话。客户端成功后只提示成功，没有清空或刷新本地 `PanelSession`。

影响：密码修改成功后本地 `psession` 已失效，后续请求 401，直到用户手动重新登录。

建议：修改密码成功后清空本地会话并跳转登录，或重新建立会话。

### P0-20 公共备份账号创建后列表不可见

- 客户端：`lib/data/api/backup_api.dart:303-366`
- 客户端：`lib/presentation/features/backups/screens/backup_accounts_page.dart:305-316,341-359`
- 服务端：`core/app/service/backup.go:65-105`
- 服务端：`agent/app/repo/backup.go:57-66`
- 服务端：`core/utils/xpack/helper/multi_node_helper.go:58`

客户端创建公共账号走 Core `/api/v2/core/backups`，列表、连接测试、桶列表和 Token 刷新走 Agent `/api/v2/backups/*`。社区版 Core 与 Agent 使用不同的 `core.db` 和 `agent.db`，多节点同步实现为空操作。

影响：

- `isPublic=true` 的账号创建后不出现在列表
- 无法继续测试连接、列桶、编辑或删除
- 计划任务选择备份账号时同样不可见

建议：公共账号的查询、测试、桶列表、刷新 Token 全部走 Core 路由，或在社区版禁用公共账号入口并说明限制。

### P0-21 网站详情 SSL 对象是零值

- 客户端：`lib/data/dto/website/website_detail_dto.dart:68,87-89`
- 客户端：`lib/presentation/features/websites/screens/website_detail_page.dart:1025-1068`
- 服务端：`agent/app/service/website.go:693-703`
- 服务端：`agent/app/repo/website.go:163-169`
- 服务端：`agent/app/model/website.go:43`

`GetWebsite` 只预加载 `Domains`，没有预加载 `WebsiteSSL`。模型中的 `WebsiteSSL` 是值类型且带 JSON tag，因此响应始终存在一个零值对象。

影响：

- `webSiteSSLId>0` 时客户端直接使用零值对象
- SSL 区域显示空域名、错误提供商、`0001-01-01` 到期时间
- 证书名称退化为 `Certificate #0`

建议：详情响应预加载 `WebsiteSSL`，或改调 `GET /websites/ssl/website/:websiteId` 获取绑定证书。

### P0-22 关闭网站默认文档会写入非法空参数

- 客户端：`lib/data/api/website_api.dart:205-218`
- 客户端：`lib/presentation/features/websites/screens/website_advanced_page.dart:555-562`
- 服务端：`agent/app/service/website.go:905-927`
- 服务端：`agent/app/service/website_utils.go:1171-1183`
- 服务端：`agent/utils/nginx/components/block.go:45-72`

关闭开关时客户端传 `index: ''`，并固定 `operate: update`。服务端 `getParamArray("index", "")` 返回 `[""]`，`UpdateDirective` 收到非空参数后写入空参数指令。

影响：Nginx 配置检查失败并回滚，用户无法关闭默认文档。

建议：关闭时使用 `operate: delete` 删除 `index` 指令，启用时再提交文件列表。

### P0-23 更换数据库弹窗默认选中 runtime 资源

- 客户端：`lib/presentation/features/websites/screens/website_detail_page.dart:713-785`
- 服务端：`agent/app/service/website.go:2376-2436`
- 服务端：`agent/app/service/website.go:2470-2481`

`GET /websites/resource/:id` 对 runtime 站点先追加 `type: runtime`，再追加 `type: database`。客户端用 `resources.first.resourceID` 作为当前数据库，通常得到 runtime ID，不在数据库列表时回退为 0。

影响：

- 弹窗默认显示“解绑数据库”
- 用户直接保存会提交 `databaseID: 0`，解绑已有数据库
- runtime ID 与数据库 ID 冲突时可能选中错误数据库

建议：使用详情对象中的 `dbID`/`dbType` 初始化，或只在 `type == database` 的资源中查找当前值。

### P0-24 告警配置更新缺少 `revision`/`displayName`

- 客户端：`lib/data/dto/alert/alert_dto.g.dart:120-158`
- 客户端：`lib/data/api/alert_api.dart:136-138`
- 服务端：`agent/app/service/alert.go:513-525`
- 服务端：`agent/app/dto/alert.go:308-315`

`AlertConfigInfo.fromJson` 和 `AlertConfigUpdateReq.toJson` 都没有 `revision`、`displayName`。服务端对 `custom` 类型或使用 mutation 的类型要求 `revision != nil`，并与 `updated_at` 比较。

影响：

- 编辑 custom webhook 或 mutation 类型返回 409 `ALERT_CONFIG_REVISION_REQUIRED`
- `displayName` 永远无法保存

建议：DTO 增加 `revision` 和 `displayName`，列表回填，更新时原样提交。

## 4. P1 问题

### P1-01 容器更新异步完成，客户端立即提示成功

- 客户端：`lib/presentation/features/containers/screens/container_create_page.dart:193-198`
- 服务端：`agent/app/service/container_update.go:34-50`

`ContainerUpdate` 启动 goroutine 后立即返回，客户端更新分支没有 `waitForTask`。同页新建分支已正确等待任务。

影响：更新失败没有提示，页面提前关闭并提示成功。

建议：使用请求中的 `taskID` 走任务轮询，等待结果再关闭。

### P1-02 镜像导出把镜像 tag 当文件名

- 客户端：`lib/presentation/features/containers/screens/container_resources_page.dart:658-665`
- 服务端：`agent/app/dto/image.go:61-66`
- 服务端：`agent/app/service/image.go:401`

服务端用 `fmt.Sprintf("%s/%s.tar", req.Path, req.Name)` 拼导出路径，`Name` 是文件名。客户端把镜像 tag 当 `name` 提交。

影响：带 `/` 的镜像名生成不存在的多级目录；普通镜像生成不可控的 `<tag>.tar`。

建议：像官方前端一样增加独立文件名输入，`TagName` 用镜像 tag，`Name` 用文件名。

### P1-03 镜像构建的 `from` 语义错误

- 客户端：`lib/presentation/features/containers/screens/container_resources_page.dart:649-657`
- 客户端：`lib/data/dto/container/image_dtos.dart:132-157`
- 服务端：`agent/app/dto/image.go:34-41`
- 服务端：`agent/app/service/image.go:213-235`

客户端把用户输入的“基础镜像”写进 `from`。服务端只在 `req.From == "edit"` 时把 `Dockerfile` 当内联内容，其他值一律当宿主机路径。

影响：基础镜像输入不生效，粘贴 Dockerfile 内容的构建方式不可用。

建议：内联 Dockerfile 使用 `from: 'edit'`，宿主路径模式再提交目录路径。

### P1-04 飞书渠道配置缺少必填字段并会丢 bot 密钥

- 客户端：`lib/data/dto/ai/ai_feishu_config_dto.dart:1-32`
- 客户端：`lib/presentation/features/ai/screens/ai_agents_actions.dart:1073-1084`
- 服务端：`agent/app/service/agents_feishu.go:300-321`
- 服务端：`agent/app/dto/agents.go:464-472`

客户端没有发送 `groupSessionScope`，bot 的 `toJson` 只包含 `accountId/name/enabled/isDefault/appId`，缺少 `dmPolicy/allowFrom/appSecret`。

影响：

- 保存 bundled Feishu 配置返回 `ErrFeishuConfig`
- bot 的 `dmPolicy/allowFrom/appSecret` 被清空或改写

建议：DTO 和更新请求补全字段，编辑时从现有配置回填密钥或使用服务端保留逻辑。

### P1-05 非 MySQL 数据库状态调用 MySQL 专用接口

- 客户端：`lib/presentation/features/databases/screens/database_detail_page.dart:192,401`
- 客户端：`lib/data/api/database_api.dart:120-131`
- 服务端：`agent/router/ro_database.go:38`
- 服务端：`agent/app/api/v2/database_mysql.go:514-520`

所有数据库类型的“状态”按钮都调用 `POST /databases/status`，服务端进入 MySQL 的 `show global status`，没有按类型分派。

影响：PostgreSQL/MongoDB/Redis 详情页点击“状态”报错或返回无效数据。

建议：按类型隐藏状态入口，或使用各数据库自己的状态接口。

### P1-06 计划任务 `urlItems` 完全漏接

- 客户端：`lib/data/dto/cronjob/cronjob_dto.dart:120-140,236-255`
- 服务端：`agent/app/dto/cronjob.go:22-25,64-76`
- 服务端：`agent/app/service/cronjob.go:631-633,948-973`

客户端只读写 `url`，没有 `urlItems`。服务端支持逐 URL 的 User-Agent，并在缺少 `urlItems` 时回退到旧格式。

影响：

- 无法创建多 URL 且每个 URL 独立 Header 的 curl 任务
- 编辑已有分组任务会丢失 Header

建议：DTO 增加 `urlItems`，创建/编辑提交结构化 URL 列表，展示层兼容旧 `url`。

### P1-07 仪表盘应用显示开关枚举错误

- 客户端：`lib/data/api/dashboard_api.dart:160-168`
- 服务端：`agent/app/service/dashboard.go:374-386`
- 服务端：`agent/constant/status.go:16-17`

客户端发送 `True/False`，服务端只识别 `Enable/Disable`。

影响：首页应用显示/隐藏切换静默无效。

建议：改为 `Enable/Disable`。

### P1-08 运行时编辑端口不会生效

- 客户端：`lib/data/dto/runtime/runtime_dto.dart:278-302`
- 服务端：`agent/app/dto/request/runtime.go:68-81`
- 服务端：`agent/app/service/runtime.go:650-785`

客户端在更新请求中发送顶层 `port`。`RuntimeUpdate` 没有 `Port` 字段，服务端最终用 `req.ExposedPorts` 生成 `runtime.Port`。

影响：用户修改端口后保存成功，实际端口保持不变。

建议：编辑端口时同步修改 `exposedPorts`。

### P1-09 编辑脚本会清空脚本分组

- 客户端：`lib/presentation/features/panel_settings/screens/script_library_page.dart:206-213`
- 服务端：`core/app/service/script_library.go:151-160`

编辑请求固定携带 `groups: ''`，页面没有分组选择。服务端更新时直接写入该字段。

影响：编辑任意已有脚本后，原有分组关联被清空。

建议：编辑时回填并提交原 `groups`，或在表单增加分组选择。

### P1-10 自定义 webhook 告警测试不可用

- 客户端：`lib/data/dto/alert/alert_dto.dart:186-206`
- 客户端：`lib/presentation/features/alerts/screens/alerts_page.dart:821-830`
- 客户端：`lib/data/api/alert_api.dart:140-147`
- 服务端：`agent/app/api/v2/alert.go:380-409`
- 服务端：`agent/app/service/alert.go:866-884`

客户端 `AlertConfigTestReq` 没有 `id/type/config`，只发送邮件字段。服务端只有 `Type == "custom"` 才进入 webhook 测试，否则按邮件配置处理。custom 分支返回对象，客户端固定按 bool 解析。

影响：

- custom webhook 测试必定走邮件分支失败
- 即使补上 `type`，响应类型也会导致解析异常

建议：测试请求补 `id/type/config`，响应兼容 bool 和 `AlertConfigTestResult`。

### P1-11 Docker 端口防护绑定/解绑成功后被当作失败

- 客户端：`lib/data/api/firewall_api.dart:253-261`
- 服务端：`agent/app/api/v2/firewall.go:530-548`

`bind`/`unbind` 分支调用 `helper.Success(c)`，响应 `data` 为 `null`。客户端随后仍用 `ApiResponseParser.object` 解析 `FirewallTaskResult`。

影响：操作成功后仍提示错误，并且不会刷新状态。

建议：只有 `initialize` 分支解析对象，其他分支使用 `ApiResponseParser.ok`。

## 5. P2 问题

### P2-01 网站列表读取不存在的 `dbID/dbType`

- 客户端：`lib/data/dto/website/website_dto.dart:63-64`
- 客户端：`lib/presentation/features/websites/screens/websites_page.dart:1291-1293`
- 服务端：`agent/app/dto/response/website.go:26-47`

`POST /websites/search` 返回 `WebsiteRes`，没有 `dbID`、`dbType`。客户端读取后固定得到 `0` 和空字符串。

影响：删除确认弹窗的数据库副标题显示为 ` · 0`，列表无法展示真实数据库信息。

建议：需要这些字段时调用 `GET /websites/list` 获取完整 `WebsiteDTO`，或让服务端补充字段。

### P2-02 备份记录 `size` 永远为 0

- 客户端：`lib/data/dto/backup/backup_record_dto.dart:66`
- 客户端：`lib/presentation/features/backups/screens/backups_page.dart:601`
- 服务端：`agent/app/dto/backup.go:105-117`
- 服务端：`agent/app/service/backup_record.go:42-66`

搜索接口的 `BackupRecords` 没有 `size` 字段，客户端 DTO 固定写 0。

影响：备份记录列表每条都显示 0 B。

建议：列表查询后按需调用 `/backups/record/size`，或在服务端补充大小字段。

### P2-03 数据库实例 DTO 与 `/db/list/:type` 契约不符

- 客户端：`lib/data/api/database_api.dart:17-31`
- 客户端：`lib/data/dto/database/database_instance_dto.dart:31-48`
- 服务端：`agent/app/dto/database.go:415-422`

`DatabaseOption` 只有 `id/type/from/database/version/address`，客户端读取 `username/password/description/ssl/timeout`，这些字段恒为空或默认值。

影响：当前页面主要使用该结果收集类型，展示层影响有限；后续使用这些字段会出错。

建议：拆分 `DatabaseOptionDto`，完整实例信息使用 `/db/search` 的 `DatabaseInfo`。

### P2-04 日志 DTO 丢弃审计字段

- 客户端：`lib/data/dto/log/operation_log_dto.dart:1-30`
- 客户端：`lib/data/dto/log/login_log_dto.dart:1-18`
- 服务端：`core/app/dto/logs.go:7-27,45-54`

服务端操作日志返回 `user`、`apiKeyID`、`apiKeyName`、`authMethod`，登录日志返回 `user`。客户端 DTO 没有映射。

影响：审计页面无法展示操作者、API Key 名称和认证方式。

建议：补充字段并在日志行展示或详情中展示。

### P2-05 VM 调整磁盘读取不存在的 `diskTarget`

- 客户端：`lib/presentation/features/vm/screens/vm_page.dart:648`
- 服务端：`agent/app/dto/vm.go:365-399`

`VMInfo` 没有 `diskTarget` 字段，磁盘目标位于 `disks[].target`。

影响：预填值始终回退为 `vda`，对 sata 或其他 target 的 VM 直接提交会使用错误设备。

建议：从选中的 disk 读取 `target`。

## 6. API 覆盖分析

### 6.1 覆盖结论

服务端 v2.5.1 共 866 条路由。客户端没有直接调用的路由有 31 条，逐条分类如下。

| 路由 | 分类 |
| --- | --- |
| `POST /api/v2/backups/refresh/token` | 条件分支已覆盖（公共/非公共） |
| `POST /api/v2/backups/del` | 条件分支已覆盖 |
| `POST /api/v2/backups/update` | 条件分支已覆盖 |
| `GET /api/v2/apps/installed/list` | `installed/search` 的轻量别名 |
| `POST /api/v2/containers/list` | `containers/search` 的轻量别名 |
| `GET /api/v2/containers/search/log` | 页面 raw GET 已使用 |
| `GET /api/v2/containers/template` | 全量模板列表，当前使用分页搜索 |
| `POST /api/v2/databases/description/update` | 动态路径已覆盖 MySQL |
| `POST /api/v2/databases/db/del/check` | 远程数据库删除前检查未覆盖 |
| `POST /api/v2/databases/pg/description` | 动态路径已覆盖 |
| `POST /api/v2/databases/mongodb/description` | 动态路径已覆盖 |
| `GET /api/v2/files/wget/process` | 页面 raw 下载已使用 |
| `POST /api/v2/hosts/info` | 列表/详情可覆盖 |
| `POST /api/v2/hosts/update/group` | 当前未使用，可补分组入口 |
| `GET /api/v2/hosts/terminal/local` | 终端页面 raw WebSocket 已使用 |
| `GET /api/v2/hosts/terminal/ssh` | 终端页面 raw WebSocket 已使用 |
| `GET /api/v2/hosts/terminal/container` | 终端页面 raw WebSocket 已使用 |
| `GET /api/v2/settings/search/available` | 健康检查 |
| `POST /api/v2/vms/console` | 未覆盖，VM 图形初始化关键接口 |
| `GET /api/v2/vms/console/ws` | 已实现，当前预检错误 |
| `POST /api/v2/websites/ssl/list` | SSL 分页搜索的轻量别名 |
| `GET /api/v2/websites/ssl/website/:websiteId` | 未覆盖，网站 SSL 修复所需 |
| `POST /api/v2/core/commands/list` | 命令树/搜索的别名 |
| `POST /api/v2/core/backups/update` | 条件分支已覆盖 |
| `GET /api/v2/core/hosts/diagnostics/summary` | Agent 同名路由的重复 |
| `GET /api/v2/core/hosts/diagnostics/goroutines` | Agent 同名路由的重复 |
| `POST /api/v2/core/hosts/diagnostics/profiles` | Agent 同名路由的重复 |
| `GET /api/v2/core/script/run` | 终端页面 raw WebSocket 已使用 |
| `POST /api/v2/core/settings/search/base` | 当前未使用 |
| `GET /api/v2/core/settings/search/available` | 健康检查 |
| `POST /api/v2/core/settings/ssl/reload` | Web 面板本机回环专用 |

### 6.2 建议补齐的能力

优先级从高到低：

1. `POST /vms/console`：VM 控制台初始化，配合修复 WebSocket 预检。
2. `GET /websites/ssl/website/:websiteId`：修复网站详情 SSL 信息。
3. `POST /websites/ssl/list`：按 ACME 账号获取证书列表。
4. `GET /websites/list`：获取完整网站字段，包括 `dbID/dbType/streamPorts`。
5. `POST /databases/db/del`、`POST /databases/db/del/check`：远程数据库删除链路。
6. `GET /containers/template`：一次获取全部编排模板。
7. `POST /containers/list`：轻量容器选择器。
8. `POST /hosts/update/group`：主机分组维护入口。

## 7. 已验证与未验证范围

### 7.1 已验证

- 所有数据层 API 路径和 HTTP 方法均能在 v2.5.1 路由表中匹配
- 动态参数、Core/Agent 条件路径、MCP base 路径已单独解析
- 上述 P0/P1/P2 问题均已对照客户端代码、服务端路由/handler/service/request/response DTO
- 现有 438 个 Flutter 测试全部通过，未覆盖本报告中的契约问题

### 7.2 未验证

- 没有真实 1Panel v2.5.1 面板凭据，未执行登录、MFA、验证码、面板备份和写操作
- 没有 Android 真机，视觉与交互仍需真机回归
- VM 控制台 VNC、终端 WebSocket 和文件下载仍需真实面板联调
- xpack、enterprise、internal 路由未纳入移动端覆盖评估

## 8. 建议修复顺序

### 第 1 批：阻断与数据风险

1. P0-01 容器 CPU/内存
2. P0-06 防火墙恢复
3. P0-07 工具箱清理
4. P0-10、P0-11 数据库新增与删除
5. P0-13 至 P0-19 面板设置、API 配置、API Key、MFA、Passkey 和密码会话
6. P0-20 公共备份账号
7. P0-21 至 P0-23 网站 SSL、默认文档、更换数据库

### 第 2 批：主要功能错误

1. P0-02 至 P0-05 Compose 与镜像
2. P0-08 VM 控制台
3. P0-09 SSH 密钥
4. P0-24 告警 revision
5. P1-01 至 P1-11

### 第 3 批：契约与展示

1. P2-01 至 P2-05
2. 覆盖缺口中的 VM、网站 SSL、远程数据库和模板列表

## 9. 修复验证建议

每个修复至少补以下测试：

- 请求契约测试：路径、HTTP 方法、必填字段、枚举值、Base64 编码
- DTO 解析测试：服务端真实 JSON 字段和类型
- 页面行为测试：保存失败、任务失败、会话失效、解绑确认
- 真实面板回归：登录/MFA、容器创建更新、数据库创建删除、防火墙恢复、网站 SSL 绑定、备份账号全流程

建议把本报告的 P0 项作为 API 契约测试的固定用例，避免后续 UI 迭代再次引入同类问题。

## 10. 修复状态（2026-11-20）

本轮已完成报告中的 P0 与 P1 修复，并处理了大部分 P2：

- P0-01 至 P0-24：全部修复
- P1-01 至 P1-11：全部修复
- P2-01、P2-02、P2-04、P2-05：已修复
- P2-03：暂未改动。`/databases/db/list/:type` 只返回 `DatabaseOption`，但客户端当前仅使用 `type/from/database`，这三个字段与服务端一致，剩余字段未被使用，因此没有实际行为影响

核验报告 `docs/qa/v37-1panel-api-fix-review.md` 发现的 8 项遗留问题已全部修复，包括告警 revision、清理 isCheck、SSH 口令、镜像导出路径、防火墙 initialize、改密会话、运行时端口协议和认证仓库密码。详见该报告第 9 节。

验证结果：

- `flutter analyze --fatal-infos`：通过，0 issues
- `flutter test`：454 个测试全部通过
- `python3 tool/check_hardcoded_english.py`：通过
- `pubspec.lock` 已恢复，未纳入改动

公共备份账号采用社区版隐藏入口的处理方式：Core 端没有 `search`、`conn/check`、`buckets` 路由，无法在社区版把公共账号完整接入 Agent 列表；Pro 版仍保留公共账号入口。
