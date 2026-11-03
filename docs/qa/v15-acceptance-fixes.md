# OneDash 验收报告 v15 优化回执

基线：`df867c0`（v15 验收对象，结论通过）。本轮处理 N1-N4 四项细节。

## N1 · 320dp / 1.3x 方式名截断

- compact 告警卡的 type / method 两行 meta 改为 `maxLines: 2`，渠道名可折行，不再只剩 `Tele…`。
- 常规宽度仍保持单行省略。

## N2 · 同一张卡两种标签层级

- 数据库详情 `_PasswordRow` 从 `subtitle:` 改为 `value:`，圆点串作为值走统一层级。
- `eye` 与 `copy` 仍在 trailing；visible 时值同样可被复制。

## N3 · 值走 trailing 文本的行

- `SplitListTile` 新增 `valueStyle`，默认值为 `bodyL + w500 + onSurface`，自定义样式与默认样式合并，仅覆盖颜色等差异。
- 迁移 7 个文件、24 处 `trailing: Text(...)` 到 `value:` / `valueStyle:`：防火墙 3、主机诊断 4、数据库详情 1、备份 2、容器动作 7、Docker 设置 4、证书管理 3。
- 证书到期颜色通过 `valueStyle` 保留，字号与字重回到详情行的统一层级。
- 新增 `valueStyle keeps the value layer with a custom color`：自定义颜色仍保持 bodyL 值层级与 bodyS 标签层级。

## N4 · compact 判定

- 改为 `maxWidth < 320 || (scale >= 1.3 && maxWidth < 430)`，平板横屏 1.3x 不再误入 compact。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test`：109 / 109 通过
- `dart format --set-exit-if-changed lib test`：0 changed
- `check_error_leaks.sh`：exit 0
- `check_action_reachability.sh`：exit 0（write 382，unwired 0，allowlist 23）
- `check_ui_consistency.py`：exit 0
- ARB：中英各 1652 条，key 差集 0
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,386,954 字节
- SHA-256：`5fc8e2062e0cd6a73e40780127e0e5df28f8f24e22bf551c2ddf7b64dac96ef3`
- 预览地址返回 HTTP 200

注：APK 与下载服务由本工作区生成，预览地址指向本机 `python3 -m http.server 8000`。
