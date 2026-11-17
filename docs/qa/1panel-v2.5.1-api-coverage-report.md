# OneDash 1Panel API 覆盖与 UI 对齐报告

- 报告日期：2026-11-16
- 客户端：OneDash（Flutter Android）
- 服务端基准：1Panel 最新稳定版 `v2.5.1`
- 服务端 commit：`806de6307bd56b11883e04059ad9f1e41ecd06e8`
- 源码位置：`/tmp/1panel-latest`（浅克隆，未纳入本仓库）
- 核对方式：静态路由提取 + 客户端调用提取 + 关键模块 DTO 抽查

## 一、结论摘要

1. 客户端主调用的 HTTP 路径和方法与 1Panel v2.5.1 基本一致，未发现主路径或主方法错误。
2. 审计时客户端有 12 个兼容回退地址在 v2.5.1 中不存在。它们只在主接口返回 404/405 时触发，会掩盖未来版本的真实故障；本轮已全部删除。
3. 审计时面板 866 条路由中，43 条没有被客户端直接调用。排除 WebSocket、自定义流式下载、内部接口、重复变体和动态路径解析误差后，真实功能缺口为 9 个；本轮已修复 5 个普通缺口，并实现 Passkey 登录/注册 4 条接口。Passkey 需要面板域名提供 Android 应用关联文件。
4. 功能覆盖接近完整，接口未 1:1 覆盖。审计时的主要缺口集中在 Passkey 登录/注册、容器卷创建、面板自定义菜单、主 SSL 导入、命令库 CSV 上传和备份客户端信息。
5. App 现有功能都有对应 UI 入口。反向检查发现 18 个 repository 方法未被页面引用，其中大部分是重复方法或弃用方法，不是独立功能。

## 二、核对范围与方法

### 2.1 服务端

1. 通过 GitHub API 确认最新 release 为 `v2.5.1`（2026-11-12）。
2. 浅克隆 `1Panel-dev/1Panel` 的 `v2.5.1` 标签。
3. 解析 `agent/router/*.go` 与 `core/router/*.go`，提取路由组、方法和路径，得到 866 条社区版路由。
4. 人工补录 `core/router/ro_mcp.go` 中通过参数传递路由组的前缀，避免 `/api/v2/core/mcp/*` 被漏计。

### 2.2 客户端

1. 解析 `lib/data/api/*.dart` 中 `_client.get/post/put/delete/patch`、`postMultipart`、`postStream` 调用。
2. 展开 `$_base` 常量和三元表达式中的双路径，得到 826 个唯一「方法 + 路径」组合。
3. 路径参数统一归一化后与面板路由比对。
4. 对 v2.5.1 新增或变化较大的模块抽查请求字段与响应字段。

### 2.3 统计口径

| 项目 | 数量 |
| --- | ---: |
| 面板路由（社区版） | 866 |
| 客户端唯一调用 | 826 |
| 路径与方法匹配 | 812 |
| 客户端未匹配调用 | 14 |
| 面板未被直接调用路由 | 43 |

客户端 14 个未匹配调用中：

- 12 个是历史兼容回退地址。
- 2 个是数据库动态路径的解析残片，不是真实错误。

## 三、API 正确性

### 3.1 路径与 HTTP 方法

未发现主调用路径错误，也未发现 GET/POST 方法颠倒。以下高风险调用均与 v2.5.1 一致：

- 核心接口前缀为 `/api/v2/core/*`，业务接口前缀为 `/api/v2/*`。
- 面板登录、验证码、MFA 登录使用 `/api/v2/core/auth/*`。
- 网站 Nginx 配置使用 `GET /api/v2/websites/:id/config/:type`。
- 文件按行读取使用 `POST /api/v2/files/read/:type`。
- 应用详情使用 `GET /api/v2/apps/detail/:appId/:version/:type`。
- 网站日志使用 `POST /api/v2/websites/log/search` 和 `/log/operate`。

### 3.2 无效兼容回退

以下 12 个回退路径在 v2.5.1 中不存在。当前主调用有效，因此不会触发；一旦主接口在未来版本被移除，客户端会落到这些无效地址。

| 文件 | 无效回退 | 当前正确主调用 |
| --- | --- | --- |
| `setting_api.dart` | `/api/v2/core/settings/password/update` | `/api/v2/core/auth/current/update` |
| `setting_api.dart` | `/api/v2/core/settings/mfa` | `/api/v2/core/auth/mfa` |
| `setting_api.dart` | `/api/v2/core/settings/mfa/bind` | `/api/v2/core/auth/mfa/bind` |
| `setting_api.dart` | `/api/v2/core/settings/passkey/list` | `/api/v2/core/auth/passkey/list` |
| `setting_api.dart` | `DELETE /api/v2/core/settings/passkey/{id}` | `POST /api/v2/core/auth/passkey/del` |
| `setting_api.dart` | `/api/v2/core/settings/api/config/generate/key` | `/api/v2/core/auth/api/generate` |
| `setting_api.dart` | `/api/v2/core/settings/api/config/update` | `/api/v2/core/auth/api/update` |
| `file_api.dart` | `/api/v2/files/path/websiteDir` | `GET /api/v2/settings/website/dir` |
| `file_api.dart` | `/api/v2/files/read` | `/api/v2/files/read/{type}` |
| `host_tool_api.dart` | `/api/v2/hosts/tool` | `/api/v2/hosts/tool/status` |
| `host_tool_api.dart` | `/api/v2/hosts/tool/config` | `/api/v2/hosts/tool/config/get` 或 `/config/set` |
| `website_api.dart` | `/api/v2/websites/log` | `/api/v2/websites/log/operate` |

风险等级：中低。建议删除这些回退，或在 `ApiCompatibility` 中只保留与当前支持的 1Panel 版本区间对应的变体。

### 3.3 请求与响应契约抽查

以下模块已对照 v2.5.1 的 Go DTO 或路由参数进行静态抽查，未发现主要字段错误：

| 模块 | 抽查内容 | 结果 |
| --- | --- | --- |
| AI Agent 通道 | `agentId`、`bots`、`dmPolicy`、`groupPolicy`、`streaming` | 一致 |
| MCP 凭据 | `requestID`、`revision`、`toolPolicies`、`nodeIds` | 一致 |
| 防火墙 Docker 策略 | `family`、`hostIP`、`hostPort`、`protocol`、`mode`、`sources` | 一致 |
| VM | 快照、ISO、网络、存储、控制台 WebSocket | 一致 |
| 主机诊断 | summary、goroutines、profiles 的 type/duration | 一致 |
| 网站 SSL | search、obtain、resolve、upload、push | 一致 |

限制：本轮没有使用真实面板凭据做在线全量回归，也没有对 866 条接口逐一做字段级比对。静态抽查能覆盖新增模块和主要写操作，不能替代真实面板回归。

### 3.4 其他正确性风险

1. AI 通道配置页面原使用原始 JSON 编辑器，本轮已改为结构化表单，见 7.1。
2. `ApiCompatibility` 只在 404/405 时切换变体。若后端返回 400 表示参数错误，客户端不会尝试其他路径，这是合理行为，但要求主路径必须长期准确。
3. 部分内部接口没有客户端调用是预期行为，例如终端能力查询、终端会话回收、面板 SSL 重载。

## 四、API 覆盖

### 4.1 覆盖统计

- 面板路由：866
- 直接调用：823
- 未直接调用：43
- 其中：
  - 9 条已通过 WebSocket、SSE 或自定义下载实现，静态解析未识别。
  - 25 条属于重复接口、内部接口、已有替代接口或动态路径解析误差。
  - 9 条为真实功能缺口。

覆盖率按接口计算约为 95.0%；按功能域计算接近完整。

### 4.2 真实功能缺口

| # | 面板接口 | 功能影响 | 建议优先级 | 状态 |
| --- | --- | --- | --- | --- |
| 1 | `POST /api/v2/core/auth/passkey/begin` | 无法使用 Passkey 登录 | P1 | 已实现，待真实面板验证 |
| 2 | `POST /api/v2/core/auth/passkey/finish` | 无法完成 Passkey 登录 | P1 | 已实现，待真实面板验证 |
| 3 | `POST /api/v2/core/auth/passkey/register/begin` | 无法在 App 内注册 Passkey | P2 | 已实现，待真实面板验证 |
| 4 | `POST /api/v2/core/auth/passkey/register/finish` | 无法在 App 内完成 Passkey 注册 | P2 | 已实现，待真实面板验证 |
| 5 | `POST /api/v2/containers/volume` | 容器卷页面只能查看和删除，不能新建 | P2 | 已修复 |
| 6 | `POST /api/v2/core/settings/menu/update` | 面板菜单只能重置，不能自定义 | P2 | 已修复 |
| 7 | `POST /api/v2/websites/ssl/import` | 缺少主 SSL 证书导入 | P2 | 已修复 |
| 8 | `POST /api/v2/core/commands/upload` | 命令库只能粘贴导入，不能上传 CSV 文件 | P3 | 已修复 |
| 9 | `GET /api/v2/core/backups/client/:clientType` | 缺少备份客户端元信息展示 | P3 | 已修复 |

说明：

- Passkey 需要面板域名提供 `assetlinks.json`，且 App 通过同一个 HTTPS 绑定域名访问，见 7.2。
- 其余 5 个缺口已在本轮补齐，修复记录见 7.1。

### 4.3 非缺口未调用项

| 分类 | 数量 | 典型接口 |
| --- | ---: | --- |
| WebSocket、SSE、自定义下载 | 9 | `hosts/terminal/*`、`process/ws`、`vms/console/ws`、`containers/search/log`、`files/wget/process`、`files/share/download`、`core/script/run` |
| 重复或替代接口 | 7 | `apps/installed/list`、`containers/list`、`containers/template`、`websites/list`、`settings/search/available`、`websites/ssl/list`、`websites/ssl/website/:id` |
| 内部或移动端不需要 | 5 | `internal/terminal/*`、`core/settings/ssl/reload`、`vms/console` |
| 动态路径解析误差 | 8 | `databases/del*`、`databases/description/update`、`databases/pg/*`、`databases/mongodb/*` |
| 已有替代调用 | 5 | `core/hosts/diagnostics/*`、`core/settings/search/base`、`hosts/info`、`hosts/update/group`、`core/commands/list` |

### 4.4 未直接调用的 43 条路由

| 方法 | 路径 | 分类 |
| --- | --- | --- |
| GET | `/api/v2/apps/installed/list` | 重复，search 已覆盖 |
| POST | `/api/v2/containers/list` | 重复，search 已覆盖 |
| GET | `/api/v2/containers/search/log` | SSE，自定义实现 |
| GET | `/api/v2/containers/template` | 重复，template/search 已覆盖 |
| POST | `/api/v2/containers/volume` | 功能缺口 |
| POST | `/api/v2/core/auth/passkey/begin` | 功能缺口 |
| POST | `/api/v2/core/auth/passkey/finish` | 功能缺口 |
| POST | `/api/v2/core/auth/passkey/register/begin` | 功能缺口 |
| POST | `/api/v2/core/auth/passkey/register/finish` | 功能缺口 |
| GET | `/api/v2/core/backups/client/:clientType` | 功能缺口，低优先级 |
| POST | `/api/v2/core/commands/list` | 重复，commands/search 已覆盖 |
| POST | `/api/v2/core/commands/upload` | 功能缺口，低优先级 |
| GET | `/api/v2/core/hosts/diagnostics/goroutines` | Agent 同名接口已覆盖 |
| POST | `/api/v2/core/hosts/diagnostics/profiles` | Agent 同名接口已覆盖 |
| GET | `/api/v2/core/hosts/diagnostics/summary` | Agent 同名接口已覆盖 |
| GET | `/api/v2/core/script/run` | WebSocket，终端页已实现 |
| POST | `/api/v2/core/settings/menu/update` | 功能缺口 |
| GET | `/api/v2/core/settings/search/available` | 重复 |
| POST | `/api/v2/core/settings/search/base` | 重复 |
| POST | `/api/v2/core/settings/ssl/reload` | 内部接口 |
| POST | `/api/v2/databases/db/del/check` | 动态路径，已覆盖 |
| POST | `/api/v2/databases/del` | 动态路径，已覆盖 |
| POST | `/api/v2/databases/del/check` | 动态路径，已覆盖 |
| POST | `/api/v2/databases/description/update` | 动态路径，已覆盖 |
| POST | `/api/v2/databases/mongodb/del/check` | 动态路径，已覆盖 |
| POST | `/api/v2/databases/mongodb/description` | 动态路径，已覆盖 |
| POST | `/api/v2/databases/pg/del/check` | 动态路径，已覆盖 |
| POST | `/api/v2/databases/pg/description` | 动态路径，已覆盖 |
| GET | `/api/v2/files/share/download` | 自定义下载，已实现 |
| GET | `/api/v2/files/wget/process` | WebSocket，已实现 |
| POST | `/api/v2/hosts/info` | 重复，search 已覆盖 |
| GET | `/api/v2/hosts/terminal/container` | WebSocket，已实现 |
| GET | `/api/v2/hosts/terminal/local` | WebSocket，已实现 |
| GET | `/api/v2/hosts/terminal/ssh` | WebSocket，已实现 |
| POST | `/api/v2/hosts/update/group` | create/update 已带 groupID |
| GET | `/api/v2/internal/terminal/capabilities` | 内部接口 |
| POST | `/api/v2/internal/terminal/sessions/revoke` | 内部接口 |
| GET | `/api/v2/settings/search/available` | 重复 |
| POST | `/api/v2/vms/console` | 控制台 WebSocket 已实现 |
| GET | `/api/v2/vms/console/ws` | WebSocket，已实现 |
| POST | `/api/v2/websites/ssl/import` | 功能缺口 |
| POST | `/api/v2/websites/ssl/list` | 重复，ssl/search 已覆盖 |
| GET | `/api/v2/websites/ssl/website/:websiteId` | 重复，网站详情已包含 |

## 五、UI 覆盖

### 5.1 功能域矩阵

| 面板域 | App 模块 | API 覆盖 | UI 状态 |
| --- | --- | --- | --- |
| Dashboard | 概览 | 完整 | 完整 |
| Websites | 网站列表、详情、SSL、CA、DNS、模板、分组、日志 | 完整 | 完整 |
| Apps | 应用商店、已安装应用、详情、参数 | 完整 | 完整 |
| Databases | MySQL、PostgreSQL、MongoDB、Redis | 完整 | 完整 |
| Containers | 容器、镜像、网络、卷、Compose、模板 | 高 | 缺新建卷 |
| Files | 浏览、编辑、上传、下载、分享、回收站、收藏 | 完整 | 完整 |
| Cronjobs | 计划任务 | 完整 | 完整 |
| Backups | 备份账号、记录、恢复、上传、快照 | 高 | 缺客户端元信息 |
| Firewall | 规则、转发、Docker 端口守卫、设置 | 完整 | 完整 |
| Hosts | 监控、SSH、磁盘、诊断、防火墙、工具 | 完整 | 完整 |
| Process | 进程、监听端口、WebSocket | 完整 | 完整 |
| Terminal | 本地、SSH、容器、Redis、脚本 | 完整 | 完整 |
| Runtimes | PHP、Node、Java、Python 等 | 完整 | 完整 |
| Toolbox | 设备、Clam、Fail2ban、FTP | 完整 | 完整 |
| AI | 账号、模型、Agent、通道、插件、技能、MCP、GPU | 完整 | 完整，通道配置为 JSON 编辑器 |
| Alerts | 告警列表与配置 | 完整 | 完整 |
| VM | 虚拟机、快照、ISO、网络、存储、控制台 | 高 | 缺桥接列表选择 |
| Panel Settings | 登录、MFA、密码、Passkey、API Key、菜单、命令库、脚本库、MCP、快照、升级 | 高 | 已补 Passkey 登录/注册和菜单编辑 |
| Logs | 操作日志、SSH 日志、网站日志、容器日志 | 完整 | 完整 |
| MCP | 服务、设置、凭据、调用记录 | 完整 | 完整 |
| Commands / Scripts / Groups | 命令库、脚本库、分组管理 | 高 | 缺命令 CSV 上传 |

### 5.2 UI 缺口

| 缺口 | 当前 UI | 影响 |
| --- | --- | --- |
| Passkey 登录 | 密码 + MFA，或 Android Passkey | 需要面板域名提供 assetlinks.json |
| Passkey 注册 | Android 原生注册或跳转面板网页 | 需要面板域名提供 assetlinks.json |
| 容器卷创建 | 仅列表、搜索、删除 | 不能新建卷 |
| 面板自定义菜单 | 仅重置菜单 | 不能编辑菜单 |
| 主 SSL 导入 | 支持上传、申请、推送 | 缺少主证书导入 |
| 命令 CSV 上传 | 支持粘贴导入 | 缺少文件上传 |
| 备份客户端信息 | 账号类型表单 | 缺少客户端元信息 |
| VM 桥接列表 | 已支持选择主机网桥 | 已修复 |
| AI 通道配置 | 已改为结构化表单 | 已修复 |

### 5.3 反向检查

现有页面没有发现“有 UI 但无 API”的功能。静态检查发现 18 个 repository 方法未被页面直接引用：

| 方法 | 判断 |
| --- | --- |
| `getGpuOptions` | 未使用的 GPU 选项接口 |
| `getAppDetailById` | 由应用详情其他接口替代 |
| `operateInstalled` | 由分项操作替代 |
| `getAllImages` | 由镜像搜索替代 |
| `getDashboard` | 由 snapshot/base 替代 |
| `changeAccess` | 由远程访问更新接口替代 |
| `checkInstalled` | 由安装流程其他接口替代 |
| `getDatabase` | 由 commonInfo 替代 |
| `getRecycleBinStatus` | UI 使用 `getRecycleStatus` |
| `getDockerEndpoints` | UI 使用 `getDockerGuard().endpoints` |
| `getListeningProcesses` | UI 使用 `listListening` |
| `getBaseDir` | 未使用 |
| `getLoginSetting` | 登录 API 内部使用 |
| `getSystemIP` | 未使用 |
| `loadSSLInfo` | 未使用，面板当前 SSL 信息未展示 |
| `listNetworkBridges` | 未使用，VM 桥接列表未展示 |
| `listDomains` | 网站详情 DTO 已包含域名 |
| `readWebsiteLog` | 由 `searchWebsiteLog` 替代 |

这些方法大多可以删除或标记为弃用，避免后续维护时误判为可用能力。

## 六、结论与建议

### 6.1 结论

OneDash 对 1Panel v2.5.1 的 API 调用整体正确，主要运维功能已经覆盖。接口覆盖不是 1:1，但功能覆盖已接近完整。当前没有阻断级 API 错误，主要问题是 9 个功能缺口和 12 个无效兼容回退。

### 6.2 建议优先级

已完成：12 个无效回退清理、路由对照脚本、容器卷创建、面板菜单编辑、主 SSL 导入、命令 CSV 上传、OneDrive 客户端信息、AI 通道结构化表单、VM 网桥选择、Passkey 登录/注册和 arm64 测试 APK。

剩余：

1. 使用真实 1Panel 面板完成在线登录、MFA、Passkey 和写操作回归。
2. 在 1Panel 版本升级时同步更新 CI 中固定的标签。

### 6.3 验证限制

1. 本轮没有真实 1Panel v2.5.1 面板凭据，未执行在线登录、写操作、MFA 和 Passkey 回归。
2. 请求与响应字段只对新增模块和主要写操作做了静态抽查，没有覆盖全部 866 条路由。
3. 面板 `main` 分支可能包含 `v2.5.1` 之后的提交，本报告以最新稳定 release 为准。
4. WebSocket 和流式接口通过代码路径确认，未建立真实连接验证消息格式。

## 七、本轮修复记录（2026-11-16）

### 7.1 已完成

| 项目 | 结果 |
| --- | --- |
| 无效兼容回退 | 删除 12 个 v2.5.1 不存在的地址，保留主调用 |
| 容器卷创建 | 新增 `POST /api/v2/containers/volume`、仓库方法和创建表单 |
| 面板菜单编辑 | 新增 `POST /api/v2/core/settings/menu/update`，支持分组显隐、子项联动、保存和恢复默认 |
| 主 SSL 导入 | 新增 `POST /api/v2/websites/ssl/import`，证书页增加导入入口 |
| 命令库 CSV 上传 | 改为调用 `POST /api/v2/core/commands/upload`，由面板解析 CSV 后再导入 |
| 备份客户端信息 | 新增 `GET /api/v2/core/backups/client/:clientType`，OneDrive 账号自动填充 `vars` |
| AI 通道配置 | 原 JSON 编辑器改为结构化表单，覆盖 Telegram、Discord、WeCom、DingTalk、QQBot 及机器人列表 |
| VM 网络桥接 | 创建 bridge 网络时读取主机网桥并选择 `bridgeName` |
| 路由对照脚本 | 新增 `scripts/check_1panel_api_coverage.py` 和 `.github/workflows/api-coverage.yml`，支持本地源码树、JSON 输出和 strict 模式 |
| Passkey 登录/注册 | 新增 4 条接口、Android Credential Manager 原生通道、登录入口和设置页注册入口；依赖面板域名的 `assetlinks.json`，见 `docs/qa/passkey-android.md` |
| 测试 APK | arm64-v8a 单 ABI 构建，29MB，SHA-256 `f476c9d8e208f92acef938580189f54021d759ba8e516c20d37ae2b0a31ddefe` |
| 回归测试 | 新增 API 契约、菜单 DTO、菜单页和 AI 通道表单测试；244 项 unit 测试通过，定向 widget 测试通过 |

### 7.2 Passkey 前提条件

Passkey 的 RP ID 必须与面板 `BindDomain` 一致。Android 端通过 Credential Manager 原生调用，要求面板域名在 `https://<BindDomain>/.well-known/assetlinks.json` 声明 `dev.onedash.app` 与签名证书 SHA-256 指纹。App 只有在该域名、HTTPS 和主机名匹配时才显示 Passkey 入口；否则继续使用密码 + MFA。配置模板、当前测试证书指纹和验证步骤见 `docs/qa/passkey-android.md`。

### 7.3 后续建议

1. 在真实 1Panel 面板配置 `assetlinks.json`，完成一次 Passkey 注册、登录和删除回归。
2. 在 1Panel 版本升级时同步更新 CI 中固定的标签。
3. 正式签名后把 release 证书指纹加入各面板的 `assetlinks.json`。

## 附录 A：核对命令

服务端：

```bash
git clone --depth 1 --branch v2.5.1 https://github.com/1Panel-dev/1Panel.git /tmp/1panel-latest
```

客户端调用提取范围：

```text
lib/data/api/*.dart
```

服务端路由提取范围：

```text
agent/router/*.go
core/router/*.go
```

路由对照脚本：

```bash
python3 scripts/check_1panel_api_coverage.py --panel-root /tmp/1panel-latest
```

JSON 输出：

```bash
python3 scripts/check_1panel_api_coverage.py --panel-root /tmp/1panel-latest --json
```

## 附录 B：相关文档

- `docs/1panel-api-gap-progress.md`
- `docs/qa/P1.md`
- `docs/qa/P2.md`
- `docs/qa/D.md`
- `docs/qa/ui-review-2026-11-16.md`

## 附录 C：变更记录

- 2026-11-17：新增应用内语言选择，将请求头 `Accept-Language` 与应用语言同步，并把证书名兜底与内部诊断文案移出中文硬编码；API 路径、方法与覆盖率结论不变。
