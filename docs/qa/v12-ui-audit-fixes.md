# OneDash UI 细节与一致性审查修复回执（v12）

基线：`44e6218`（报告审查对象）。本轮在工作区完成 v11 修复后继续处理 v12 报告。

## 必修

- P0-1 备份账号类型：`backupAccountTypes` 使用面板大写常量，新增大小写归一 `canonicalBackupAccountType`；编辑 `LOCAL` 只读展示，新建下拉不提供本地类型；提交值始终为契约常量。
- 回归测试：`backup_accounts_page_test.dart` 覆盖 `type=LOCAL` 编辑不抛异常与新建 payload 契约；`enum_labels_test.dart` 覆盖 11 种类型与归一。

## 系统性问题

- C1 页面边距：列表根节点改用 `AppTokens.pagePadding`（42 处引用）；`ServerShell` 对宽屏 body 加 `contentMaxWidth` 居中约束。
- C2 容器边框：`SplitListGroup` 增加与 `TonalCard` 一致的 `outlineVariant` 1px 边框。
- C3 信息行：`SplitListTile` 新增 `value`，详情主值改为左标签右值并提升到主色；环境变量、命令、入口点保留等宽多行样式，空值隐藏整行。
- C4 动作栏：刷新统一排首位；备份页 4 个动作收为「新建 + ⋯」；容器/网站批量选择移入 ⋯ 菜单。
- C5 新建入口：移除全部 `FloatingActionButton`，防火墙与文件管理的创建/上传入口移入 AppBar。
- C6 危险操作：告警卡片常驻红色垃圾桶改为 ⋯ 菜单；开关仍保留快速停用。
- C7 空态：容器、计划任务、备份、告警首屏空态补创建按钮；日志、进程、运行时使用模块专属文案。
- C8 时间：新增 `formatListTime`（7 天内相对，之后绝对），列表统一接入；详情时间统一 `formatLocalDateTime`；删除 `formatTimeAgo`、`formatFileModTime`。

## 细节问题

- D1：服务器区块改为「已连接面板」，进程守护改为「守护进程」，设备时间改为「时区与时间」。
- D2：删除服务器编辑页无信息副标题；端口 helper 改为「1Panel 默认端口为 9999」；删除测试连接重复占位文本。
- D3：中文统一「网站」，英文统一 `website`，筛选状态改为「已停止 / Stopped」。
- D4：告警 meta 改为 `类型：{type} · 方式：{method}`，词条改名 `alerts_cardMeta`。
- D5：面板、应用、数据库、计划任务、模板变量计数补量词。
- D6：计划任务卡片去掉左上孤立状态点，保留右下状态点与文字。
- D7：计划任务类型接入 `cronjobTypeLabel`，覆盖 shell/log/curl/website/database/directory/app/snapshot/clean/ntp。
- D8：容器详情空字段隐藏整行，不再渲染孤立 `-`。
- D9：更多页应用入口改用线性 `layout_grid`。
- D10：生成站点、清空日志、计算备份、批量选择图标改为语义匹配图标；加号字重未单独调整。
- D11：概览图表空态已使用 `SkeletonShimmer`，与加载中状态一致。
- D12：`MetricCard` 与进程 PID 的 `maxLines` 补 `TextOverflow.ellipsis`；其余未配项为多行输入框。

## 新增守卫与测试

- `tool/check_ui_consistency.py`：禁止 FAB、刷新必须首位、禁止时间死代码。
- `format_utils_test.dart`：7 天相对/绝对切换与 fallback。
- `enum_labels_test.dart`：计划任务类型本地化。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：102 / 102
- `check_error_leaks.sh`：exit 0
- `check_action_reachability.sh`：exit 0（write 382，unwired 0，allowlist 23）
- `check_ui_consistency.py`：exit 0
- ARB：中英各 1651 条，key 差集 0
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,385,686 字节
- SHA-256：`52c82ecefd86ec7d9e5fef1e91f7631d1bb1d70954f250dbd396c66ef263e97a`
- 预览地址返回 HTTP 200

## 保留项

- 无 Android 真机/模拟器，未生成 390/360/320 真机截图；以 widget 尺寸与 1.3x 文本回归覆盖。
- 首屏之外的 12 处裸 `Text` 空态仍为行内占位，未全部替换为 `EmptyState(compact: true)`。
- `pagePaddingWide` 尚未做平板媒体查询切换，当前统一 16dp 加 640dp 内容上限。
- 加号图标字重为字体本身属性，未统一校正。
