# OneDash 验收报告 v14 修复回执

基线：`8c42b4b`（v14 验收对象）。本轮修复数据库详情回归，并处理 D1-D3 三项细节。

## 必修：数据库详情的值不再渲染

- `SplitListTile` 支持 `value` 与 `trailing` 共存：常规宽度把值文本放在 trailing 左侧，两者同处右端。
- 窄屏或 1.3x 时标题与 trailing 同排，值文本落到标题下方并占满整行，避免复制按钮挤掉内容。
- 溢出判定改为「标题 + 值 + trailing」三者宽度之和；仅值超宽时也会触发下移。
- 新增 `test/widget/split_list_group_test.dart` 两条回归：`value survives when trailing is present`、`long value stays complete beside trailing at 320dp/1.3x`。

## 细节

- D1 告警标题末字成行：compact 时 `⋯` 与开关同处 meta 行，标题独占整行；常规宽度保持标题行右侧`⋯`。
- D2 告警日志丢失时分：`formatListTime` 对 24 小时以上、7 天以内输出 `MM-dd HH:mm`，24 小时内仍用相对时间，更早仍用绝对日期。
- D3 动作顺序：统一为「刷新 → 次要动作 → ＋」；网站、容器、运行环境把 `＋` 移到末尾，备份页保持 `刷新 / ⋯ / ＋`。

## 守卫

- `check_ui_consistency.py` 新增「创建动作必须是最后一个 action」，防止 `＋` 再被放回菜单前。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test`：108 / 108 通过
- `dart format --set-exit-if-changed lib test`：0 changed
- `check_error_leaks.sh`：exit 0
- `check_action_reachability.sh`：exit 0（write 382，unwired 0，allowlist 23）
- `check_ui_consistency.py`：exit 0
- ARB：中英各 1652 条，key 差集 0
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,386,954 字节
- SHA-256：`af47ee9704fb320a5ccea6c785578415623618aff602f20c599e2c5b6fb3c6ab`
- 预览地址返回 HTTP 200
