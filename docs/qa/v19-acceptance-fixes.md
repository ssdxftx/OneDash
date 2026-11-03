# OneDash 验收报告 v19 修复回执

基线：`c1da3d6`（v19 验收对象，结论通过：0 必修 + 2 应修 + 1 可选）。本轮处理 S1、S2。

## S1 · 英文常规宽度 meta 被拆成左右两栏

- 非 compact 的 meta 改为单个 `Text`，类型与方式在同一段文本流里，`·` 随句子折行。
- 保留 `maxLines: 2` 与省略保护。
- 390dp / 1.0x 英文从「左右两栏」回到「整句第二行顶格续写」；中文常规宽度仍单行。
- 删除不再使用的 `_metaText`。

## S2 · 英文回归测试阈值

- 断言对象改为完整 meta 句子 `Type: CPU · Method: Telegram`。
- 校验该句子是单个 `Text`（`find.text('Type: CPU')`、`find.text('Method: Telegram')` 均为空），直接抓「左右分栏」形态。
- 保留 `didExceedMaxLines == false`，确保没有省略号。

## N3 · 英文标题与 tab 截断

- 报告标为可选，涉及英文文案统一收口；本轮未改，避免影响其它复用同一 key 的页面。

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
- SHA-256：`74863de45d3e739fb33e153a71b7d078ebe85906199f1075297d8c0226506eba`
- 预览地址返回 HTTP 200
