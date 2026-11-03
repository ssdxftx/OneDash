# OneDash 验收报告 v13 修复回执

基线：`14485ff`（v13 验收对象）。本轮处理 R1-R5、D1-D5、C1/C7 收口项与守卫脚本缺口。

> 后续修正：R4 的 `_CopyRow` 同时传 `value` 与 `trailing` 导致值被覆盖，已在 `docs/qa/v14-acceptance-fixes.md` 修复并补回归。

## 应修项

- R1 运行环境双刷新：同步运行环境改用 `TablerIcons.cloud_download`，列表刷新保持首位，两个动作语义可区分。
- R2 端口提示截断：`server_edit_portHelper` 改为「默认 9999 / Default 9999」，窄屏不再省略。
- R3 告警 meta 断行：拆为 `alerts_metaType` / `alerts_metaMethod`；窄屏或 1.3x 时类型、方式各占一行，常规宽度用单行分段并只在段内省略，冒号与值不再被拆开。
- R4 数据库详情：`_CopyRow` 改用 `SplitListTile.value` 左标签右值；地址、端口、用户名、密码为空时整行隐藏，不再输出孤立 `-`；数据库状态空态改用 `EmptyState`。
- R5 时间格式：告警日志、终端会话、病毒扫描记录统一 `formatListTime`；解析失败保留原字符串。`formatListTime` 的 null 默认值改为空串，调用方按需传 fallback。

## 审阅细节

- D1 备份页新增 AppBar 刷新并置于首位，一次刷新 5 个备份类型；网站列表刷新从 `⋯` 移到 AppBar 首位。
- D2 删除服务器页「添加面板」大卡片，保留 AppBar `+` 与空态按钮，消除非空列表的双入口。
- D3 容器动作面板颜色收敛为语义色：常规操作 `info`、停止/清理/暂停 `warning`、启动/恢复 `success`、删除/强杀 `danger`。
- D4 告警卡片调整为标题行右侧 `⋯`、meta 行右侧开关，与计划任务「末行右侧状态」的阅读顺序一致。
- D5 带 `value` 的信息行标签降为 `bodyS + onSurfaceVariant`，值保持 `bodyL + w500`，主次层级明确。

## 一致性与空态收口

- C1 再替换 29 处列表根节点为 `AppTokens.pagePadding`，剩余 13 处为选择栏、加载骨架与页内嵌套容器。
- C7 清零裸 `Text(l10n.state_empty)`：检查文件、运行时预设/脚本、远程数据库、网站日志、DNS、容器用户、备份 Bucket、Compose 模板、镜像容器、镜像仓库、数据库状态、病毒记录共 13 处改为 `EmptyState(compact: true)`。

## 守卫与 CI

- `check_ui_consistency.py` 新增同一 `actions` 图标去重、`PopupMenuButton` 内刷新检测；刷新进菜单不再漏检。
- `.github/workflows/ci.yml` 接入 `check_action_reachability.sh` 与 `check_ui_consistency.py`，三项守卫随 CI 执行。
- 新增 `SplitListTile` 值层级回归用例；时间测试覆盖 null 空串与自定义 fallback。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test`：105 / 105 通过
- `dart format --set-exit-if-changed lib test`：0 changed
- `check_error_leaks.sh`：exit 0
- `check_action_reachability.sh`：exit 0（write 382，unwired 0，allowlist 23）
- `check_ui_consistency.py`：exit 0
- ARB：中英各 1652 条，key 差集 0
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,386,954 字节
- SHA-256：`ca936994260951270b947569abe5c80d0cbd4a75e5833f8b9932f37d0e5578cb`
- 预览地址返回 HTTP 200

## 保留项

- 无 Android 真机/模拟器，截图仍需 widget 渲染替代。
- 数据库详情之外仍有 31 处 `'-'` 占位，分布在设备、防火墙、主机、工具箱等只读信息行，尚未全部改为空值隐藏。
- `pagePaddingWide` 未做平板媒体查询切换，宽屏继续使用 16dp 边距与 640dp 内容上限。
- 加号图标字重仍由字体本身决定。
