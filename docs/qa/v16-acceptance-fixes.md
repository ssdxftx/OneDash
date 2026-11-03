# OneDash 验收报告 v16 修复回执

基线：`1dd0565`（v16 验收对象，1 必修 + 1 应修 + 2 细节）。本轮已逐项处理。

## P1 · 320dp / 1.3x 证书行标签消失

- `SplitListTile` 增加 `stackValueOnly`：有 `value`、无 `trailing` 且标题+值超宽时，同样走「值下堆」分支。
- 值下堆时标题使用整行宽度，不再被无约束值挤成 0。
- 新增 `long value stacks below the label instead of squeezing it`：320dp / 1.3x，断言无溢出、标签宽度 > 40dp、值位于标签下方。
- 未对短值加 60% 上限，避免 390dp 正常行被提前省略。

## R2 · 防火墙设置卡层级混排

- 原设置卡保留「后端 / 原生详情 / IPv6」三行，语义统一为 subtitle + trailing。
- 「版本 / 面板端口 / SSH 端口」拆到新 `SectionHeader('服务信息')` + 独立 `SplitListGroup`，整卡统一为 value 层级。
- 新增中英文案 `firewall_settingsService`。

## D1 · compact 告警 meta 冒号悬空

- compact 下 meta 改为两列：短标签（`类型` / `方式`）+ `Expanded` 值，标签与冒号固定在一起，值单独折行。
- 新增 `alerts_metaTypeLabel` / `alerts_metaMethodLabel` 双语 key。
- 常规宽度仍保持「类型：X · 方式：Y」单行。

## D2 · 组件检测结果卡值仍放 subtitle

- 「存在 / 版本 / 路径」三行全部从 `subtitle:` 改为 `value:`，与其它详情卡的值层级一致。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test`：110 / 110 通过
- `dart format --set-exit-if-changed lib test`：0 changed
- `check_error_leaks.sh`：exit 0
- `check_action_reachability.sh`：exit 0（write 382，unwired 0，allowlist 23）
- `check_ui_consistency.py`：exit 0
- ARB：中英各 1655 条，key 差集 0
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,386,954 字节
- SHA-256：`392535d6b1de9f9642a0a09e31db48c591307632f8f7cbd7ad9946002d3e3d7a`
- 预览地址返回 HTTP 200
