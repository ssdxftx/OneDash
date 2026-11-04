# Mono Dash 操作逻辑对齐 — 第一批（P0 + P1 片段）

基线：`ead7c11`（v20 验收通过）

## 已完成

### P0 地基组件

| 组件 | 落点 | 说明 |
|---|---|---|
| `SimpleFormPage` | `lib/presentation/common/components/simple_form_page.dart` | 全屏表单模板：`AppBarLarge` + 可滚动字段 + 固定 `FormFooter` 保存栏；键盘拖动收起 |
| `AppIcon` | `lib/presentation/common/components/app_icon.dart` | base64 / data URI / URL 三路解析，失败回落首字母 |
| `LogPreviewPage` / `LogSourceOption` | `lib/presentation/features/log/screens/log_preview_page.dart` | 全屏日志：多来源切换、搜索、原文 / 结构化、级别着色、跟随、分页窗口、导出、错误重试 |
| 确认弹层 | `bottom_sheet_surface.dart` | `showConfirmSheet` 由底部悬窗改为居中 Dialog，仅标题、说明、两个按钮（保留危险操作输入资源名的二次校验） |

### 表单悬窗升全屏页

| 原悬窗 | 现落点 | 入口 |
|---|---|---|
| `database_create_sheet.dart` | `SimpleFormPage` 页面 | 数据库创建类型选择后 `pushFormPage` |
| `file_permission_sheet.dart` | `SimpleFormPage` 页面 | 文件权限入口 `pushFormPage`；所有者选择保留为选择菜单 |
| `app_install_sheet.dart` | `SimpleFormPage` 页面 | 应用详情安装按钮 `showAppInstallPage` |

### P1 入口改造

| 模块 | 变化 |
|---|---|
| 网站列表 | 整卡点击改为动作菜单；移除卡片 `⋮`；菜单分「运行 / 配置 / 日志 / 危险」；配置行动作打开 `website_detail` 对应 tab；日志行进入 `LogPreviewPage` |
| 网站详情 | 支持 `?tab=` 初始页；日志 4 行合并为 1 行，跳全屏日志页，不再跳文件管理器 |
| 容器列表 | 整卡点击改为动作面板；移除卡片 `⋮`；卡片内保留启停快捷按钮；菜单新增「详情」入口 |
| 容器日志 | 动作行统一进入 `LogPreviewPage`，不再使用 sheet 内只读纯文本 |
| 应用商店 | 两列网格改单列行；真实应用图标；`全部 / 已安装 / 可升级` 三 tab；标签与版本 chip |
| 已安装应用 | 卡片使用真实图标 |

## 验证

- `flutter analyze --fatal-infos`：0 issue
- `flutter test`：122 通过（新增 8 个：日志页 3、表单页 2、应用图标 3）
- `dart format --set-exit-if-changed lib test`：0 changed
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：write 382 / unwired 0 / allowlist 24
- `python3 tool/check_ui_consistency.py`：passed
- ARB 中英各 1670 键，无差集
- 直接 `showModalBottomSheet` 调用仅剩 `bottom_sheet_surface.dart` 一处封装

## 仍待进行

- 容器 15 项动作改全屏动作页（当前仍为可滚动动作菜单）
- 网站详情 6 个 tab 拆为独立全屏页
- 已安装应用列表卡片动作菜单化
- 数据库 / 运行时详情拆页
- 其余 `⋮` 收敛到顶部工具或动作菜单
- 其余 8 类日志入口（Compose、Supervisor、慢日志、系统日志）接入 `LogPreviewPage`
- README Markdown 渲染、平板边距与全局 golden 基线

## 构建产物

- `--release --split-per-abi --target-platform android-arm64`
- `/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 25,387,134 字节
- SHA-256 `c73635ba642a070c8f2a2a189858b9d1792c2339775b983f2e03a2604f6a3499`
- 预览：`https://8000-5f085df3015621c9.monkeycode-ai.online/OneDash-v1.0.0-arm64-v8a.apk`（HTTP 200）

## 第二批补充

- 容器动作改为全屏动作页（`showContainerActionsPage`），动作菜单保留同源 `_ContainerActionsBody`；列表整卡进入全屏动作页。
- Compose 日志、Supervisor `out.log` / `err.log`、数据库慢日志接入 `LogPreviewPage`。
- 应用详情 README 改为 `SimpleMarkdown` 渲染：标题、列表、代码块、引用、分隔线、行内代码、加粗、链接；未知语法按原文展示。
- 新增 `simple_markdown_test.dart` 3 项。
- `flutter test`：125 通过。

### 第二批构建

- 25,452,670 字节
- SHA-256 `f7186cbda3312c22f556eca138ab8bea268d444c39d8f687ebb7c90e6b1c1d12`

## 第三批补充

- 网站 tab 拆为独立全屏页：`WebsiteTabPage`（基础配置 / 域名 / 反向代理 / 负载均衡 / 日志）+ `WebsiteLogsPage`。
- 新路由：`/s/:id/websites/:siteId/config`、`/domains`、`/proxy`、`/load-balance`、`/logs`；动作菜单全部改为路由跳转，日志入口落在 `/logs`。
- 已安装应用卡片改为动作菜单：详情、终端、日志、启动/停止/重启、卸载；详情跳转携带 `detailId`，修复列表进入详情后无法卸载/启停的问题。

### 第三批构建

- 25,452,670 字节
- SHA-256 `d17e5bbae67cc8b0a274535f58aeb034a1da8a068c181154e1607de7b7566350`

## 第四批补充

- 数据库列表整卡进入动作菜单；新增「详情 / 用户与权限 / 高级设置 / 复制 / 删除」。
- 数据库用户与权限、高级设置拆为独立全屏页：`DatabaseTabPage`，路由 `/more/databases/:name/users`、`/advanced`。
- 运行时列表整卡进入动作菜单，移除卡片 `⋮`，菜单新增「详情」。

### 第四批构建

- 25,452,670 字节
- SHA-256 `e20d764944c78790e3d42e86f7eec94ffdf01b4dc5a967bc8488faf92b7e27fb`

## 第五批补充

- 告警卡片整卡进入动作菜单（编辑 / 启停 / 删除），移除卡片 `⋮`，状态开关保留在卡面。
- 备份卡片整卡进入动作菜单（下载 / 恢复 / 删除），移除卡片 `⋮`。
- 进程卡片整卡进入动作菜单（结束进程），移除卡片 `⋮`。
- 快照卡片移除 `⋮`，编辑描述与删除改为卡面文字按钮，保留重建 / 恢复 / 回滚。
- 告警卡测试更新：新增「卡片点击打开动作菜单」用例。

### 第五批构建

- 25,452,670 字节
- SHA-256 `b44b556a69c43ff9ae643891ed7dbfb6de30afc1747b9d4cd37855a3205f0cf6`

## 第六批补充

- 防火墙规则行改为整行进入动作菜单（编辑 / 上移 / 下移 / 删除），转发规则行改为动作菜单（编辑 / 删除）；移除两处 `⋮`。
- 网站模板卡片整卡进入编辑页，删除改为卡面图标按钮，移除 `⋮`。
- 网站证书卡片整卡进入动作菜单（下载 / 检测 DNS / 编辑 / 删除），移除 `⋮`。

### 第六批构建

- 25,453,090 字节
- SHA-256 `7a4f2af31fee3675dcc49fc4ddb930d215275d6ff8eb6420206b3c9a6e3300ab`

## 第七批补充

- 新增 `showSelectionMenu`，统一底部选择菜单（应用商店同步/设置、已安装应用操作、网站详情、运行时版本、主机密钥、终端字号、备份/账号、网站与容器列表工具菜单等）。
- 移除除文件工具栏外的全部 `PopupMenuButton`；剩余只允许在 `files_page.dart`、`file_history_page.dart`。
- 新增守卫 `tool/check_sheet_whitelist.sh`：直接 `showModalBottomSheet` 只允许公共封装，`PopupMenuButton` 只允许文件工具栏。

### 第七批构建

- 25,453,714 字节
- SHA-256 `39307bdc2722d9db50d8086d1243569209e0f181d8d4a1dc1d3714ded7810b6d`

## 第八批补充

- 日志 Hub 新增「系统日志」入口：读取系统日志文件列表，选择后进入 `LogPreviewPage`。
- 新增响应式页面边距 `context.pagePadding`：宽度 ≥ 600 时使用 24dp，否则 16dp；42 个页面文件已迁移。
- 新增 `logs_system` 中英文案，ARB 继续对齐。

### 第八批构建

- 25,453,714 字节
- SHA-256 `544d2de139001aab620a80058662c4272bd08a64a4a12206d947a81562a39fdb`

## 第九批补充

- 新增组件级 golden 基线：`test/golden/core_components_test.dart`，覆盖 320 / 390 / 600dp 三档宽度，包含 `TonalCard`、`SplitListGroup`、`SplitListTile`、`ActionSheetSection`、`ActionSheetRow`。
- golden 基线已生成到 `test/golden/goldens/`。

### 第九批构建

- 仅新增测试与 golden 基线，lib 无变更，APK 与第八批一致
- 25,453,714 字节
- SHA-256 `544d2de139001aab620a80058662c4272bd08a64a4a12206d947a81562a39fdb`

## 第十批补充

- 运行时 tab 拆为独立全屏页：`RuntimeTabPage`，新增 `/extensions`、`/ini`、`/fpm`、`/modules` 路由；运行时动作菜单按类型显示对应入口。
- 服务器卡片新增编辑按钮，保留长按动作菜单。
- 文件页统一单击行为：目录进入、文件打开动作面板（含编辑 / 图片预览 / 下载 / 重命名 / 删除等），移除行尾 `⋮`，保留长按多选。

### 第十批构建

- 25,453,714 字节
- SHA-256 `88311a482a6a16cd4992a76f96f445032364f068281c6ad7d73c7fd9994d5db9`

## 第十一批补充

- 已安装应用「修改参数」由底部悬窗升为 `SimpleFormPage` 全屏页，高级参数折叠保留。
- 数据库「修改密码」升为 `SimpleFormPage` 全屏页。

### 第十一批构建

- 25,453,714 字节
- SHA-256 `0cc567b6faaffc87926d779fc965fa0996c191df239749fdb4ccb894de068162`

## 第十二批补充

- 面板设置通用值编辑（`_editValue`）由底部悬窗升为 `SimpleFormPage` 全屏页，覆盖端口、绑定域名、各类文本设置。
- 面板登录密码修改升为全屏页。

### 第十二批构建

- 25,453,714 字节
- SHA-256 `107fc3e869c37aa38662aa4ca7bfe2e06c67ad51031ef6344a42dbc91eb598de`

## 第十三批补充

- 快照导入、恢复密钥输入、创建快照、编辑描述全部升为 `SimpleFormPage` 全屏页。
- 备份账号新增/编辑升为 `SimpleFormPage` 全屏页。

### 第十三批构建

- 25,453,714 字节
- SHA-256 `e956673ec21a9a9a51401c5a33f75c4b092f1fb1313308749c1e8ddf1780efb8`

## 第十四批补充

- 网站 SSL 上传、申请、编辑全部升为 `SimpleFormPage` 全屏页。

### 第十四批构建

- 25,453,714 字节
- SHA-256 `9ab226b7fd3c51e4c2091f77f7e3e4410765b13ab3360506db3b446a6181e4d8`

## 第十五批补充

- 网站账号页的 ACME 新增/编辑、DNS 新增/编辑、CA 新增/签发全部升为 `SimpleFormPage` 全屏页。

### 第十五批构建

- 25,453,714 字节
- SHA-256 `d268fb84a6be6640b67beef7e9c1922cb997ed3099306ec05dc4f72c40260460`

## 第十六批补充

- 防火墙白名单新增/编辑升为 `SimpleFormPage` 全屏页。
- 主机监控设置、SSH 端口、SSH 配置项编辑升为 `SimpleFormPage` 全屏页。

### 第十六批构建

- 25,453,714 字节
- SHA-256 `3d9c2507902aa34f704bc3b2625b6fb161228b423f58c86f4e2d0c433a82caa1`

## 第十七批补充

- 网站高级配置的描述与置顶、默认首页、限流、目录权限四项表单升为 `SimpleFormPage` 全屏页。

### 第十七批构建

- 25,453,714 字节
- SHA-256 `2c08556076f887445aea51b283f1b18729a5fd8877a8cc4072f40c8772b79bf5`

## 第十八批补充

- 网站高级配置的访问认证、CORS、防盗链、真实 IP 四项表单升为 `SimpleFormPage` 全屏页。

### 第十八批构建

- 25,453,714 字节
- SHA-256 `33618f6e757aec50da8d258fe6be89e419218bda19d1f6fdf8f29e4322b443ee`

## 第十九批补充

- 工具箱：设备时区、DNS、Fail2ban 配置与拦截动作、FTP 新建、Clam 扫描新建全部升为 `SimpleFormPage` 全屏页。

### 第十九批构建

- 25,453,714 字节
- SHA-256 `3a685f8298a540c8db971a981b9b8efed998e99df30eabddea5c66ce205bdf8b`

## 第二十批补充

- 网站路径认证新增/编辑升为 `SimpleFormPage` 全屏页。
- 主机 SSH 连接测试、SSH 配置文件编辑、生成密钥、编辑密钥均升为全屏页。

### 第二十批构建

- 25,453,714 字节
- SHA-256 `198ce1369851ee650539b98b8b794139219ff3c92fc7bafbf11928d1aa54abe0`

## 第二十一批补充

- 网站高级配置：网站信息编辑、重定向源文件编辑、重定向规则新增/编辑升为 `SimpleFormPage` 全屏页。

### 第二十一批构建

- 25,453,714 字节
- SHA-256 `eee76595bb9f1cb8fb17739529eea3629cb075c7f111fae040b630f02fac2034`

## 第二十二批补充

- 网站详情：配置文件编辑、站点目录、添加域名、反向代理新增/编辑、代理源文件编辑均升为 `SimpleFormPage` 全屏页。

### 第二十二批构建

- 25,453,714 字节
- SHA-256 `60a319e42099d9aa78bc03048dbc54bbf6af82529e0bbf213fdf16e63b41f902`

## 第二十三批补充

- 数据库高级：变量、配置文件、Redis 配置 / 密码 / 持久化表单升为 `SimpleFormPage` 全屏页。
- 数据库用户：新建用户、绑定用户、改密、授权、回收权限表单升为全屏页。

### 第二十三批构建

- 25,453,714 字节
- SHA-256 `9e5a80371205df8d817feb79fcfe0a3d5464da2fe09e6ceae451cd3043035023`

## 第二十四批补充

- 文件页：新建文件/目录、压缩命名、重命名、移动/复制、批量权限全部升为 `SimpleFormPage` 全屏页。

### 第二十四批构建

- 25,453,714 字节
- SHA-256 `37badaaee074eb2bb1e8e59e41bb7385f4c9215d10dbabf9dd8d929423837b2c`

## 第二十五批补充

- 面板设置：面板端口、绑定域名升为 `SimpleFormPage` 全屏页。
- 备份：从文件恢复、新建备份、恢复记录三个表单升为全屏页；`SimpleFormPage` 新增 `danger` 危险确认样式。

## 第二十六批补充

- 完成剩余输入型悬窗迁移：容器资源/Compose/Docker、负载均衡、面板 SSL/MFA、远程数据库、已安装应用端口、设备 Swap、运行时创建/编辑、Node 脚本/安装、告警通知配置、磁盘分区、Supervisor 配置与进程配置。
- `check_sheet_whitelist.py` 新增规则：`showAppSheet` 块内出现 `TextField` 即失败，强制输入表单走 `SimpleFormPage`。
- 全仓输入型悬窗清零。
