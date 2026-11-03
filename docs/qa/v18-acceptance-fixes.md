# OneDash 验收报告 v18 修复回执

基线：`75e1ef0`（v18 验收对象，结论不通过：1 必修 + 2 应修 + 2 可选）。本轮处理 R1、S1、S2，并顺手做 N1、N2。

## R1 · 控件竖排触发条件过宽

- 保留 `compact` 作为「meta 两列」判据：`maxWidth < 320 || (scale >= 1.3 && maxWidth < 430)`。
- 新增独立的 `stackControls`：按 1.0x 等效宽度判定 `constraints.maxWidth / scale < 210`，只有并排放不下时才竖排。
- 控件分支补全为三条：
  - `stackControls`：`⋯` 在上、开关在下的竖列；
  - compact 且放得下：`⋯` + 开关并排；
  - 非 compact：`⋯` 留在标题行，仅开关在 meta 行。
- 320dp / 1.0x、360dp / 1.0x 回到 v17 卡高；360dp / 1.3x、390dp / 1.3x 回到并排；320dp / 1.3x 继续竖排。

## S1 · 英文常规宽度 meta 截断

- 非 compact 的 type / method meta 从单行放宽到 `maxLines: 2`。
- 390dp / 1.0x 英文下 `Method: Telegram` 可完整显示，中文常规宽度仍为单行。

## S2 · 测试期望值

- `320dp / 1.3x` 用例改为按实际高度断言 `Telegram` 单行，不再依赖无效的 `didExceedMaxLines`。
- 保留 `320dp / 1.3x` 的竖排断言。
- 新增 `360dp / 1.0x` 与 `320dp / 1.0x` 反向回归：卡高 ≤ 108、`⋯` 与开关同一行、两者都存在。
- 新增 `390dp / 1.0x` 英文回归：`Method: Telegram` 不被省略。
- 四个用例统一加载 MiSans 实字体，避免测试默认方块字体造成假折行。

## N1 · 剩余空串上屏

- 防火墙备份名、ClamAV 任务名/路径、FTP 用户名/路径改用 `displayValue`。
- 终端会话标题已有 `.isEmpty` 兜底，保持不动。

## N2 · 占位视觉偏重

- `SplitListTile` 识别 `common_notAvailable` 占位值，值颜色退到 `onSurfaceVariant`，其它值保持原层级。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test`：114 / 114 通过
- `dart format --set-exit-if-changed lib test`：0 changed
- `check_error_leaks.sh`：exit 0
- `check_action_reachability.sh`：exit 0（write 382，unwired 0，allowlist 23）
- `check_ui_consistency.py`：exit 0
- ARB：中英各 1656 条，key 差集 0
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,386,954 字节
- SHA-256：`292e732c618a334de2f52974b762116d1219723396f7876b7e3337d0e2bbf2cb`
- 预览地址返回 HTTP 200
