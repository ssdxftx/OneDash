# OneDash 验收修复任务书 v11 回执（v31）

## P1 备份账号类型

- 常量表：`backupAccountTypes`（11 项面板大写常量）+ `backupAccountLocal`，并新增 `canonicalBackupAccountType` 做大小写归一。
- 文件：`backup_accounts_page.dart`、`enum_labels.dart`、`app_en.arb`、`app_zh.arb`。
- 新建下拉：11 种非本地类型，值使用面板大写常量，文案走 `backupAccountTypeLabel`。
- 编辑：服务端大小写先归一，`LOCAL` 以只读「本地」展示，不再出现 Dropdown 断言；未知类型回落到 S3。
- 提交：payload 的 `type` 始终为面板契约值，新建不再提交 `local`。
- 补齐映射：KODO、UPYUN、ALIYUN、GoogleDrive。
- 副标题：名称已包含类型时不再重复类型，只显示 bucket/路径。
- 测试：
  - `test/widget/backup_accounts_page_test.dart`：`type: LOCAL` 打开编辑弹层无异常、无下拉、显示「本地」；新建保存 payload 类型在契约表内。
  - `test/unit/enum_labels_test.dart`：11 项契约、唯一性、四种新增映射、大小写归一。

## P2 窄屏双截断

- `SplitListTile` 在文本尾值与标题无法同排放下时，将尾值移到标题下方的第二行。
- 判断依据为 `TextPainter` 实测标题与尾值的自然宽度，未使用固定宽度阈值。
- 非文本尾值（Switch、IconButton、Row）保持右侧布局。
- 第二行允许两行换行，避免 320dp/1.3x 下尾值继续省略。
- 宽屏可容纳时仍保持单行右对齐，并取消文本尾值的 60% 宽度上限，避免刚好卡在边界时被截断。
- 测试：
  - 夹具补齐 `TonalCard → SplitListGroup → SplitListTile` 真实层级。
  - 320dp/1.3x 断言标题与尾值 `didExceedMaxLines` 均为 false，且尾值位于标题下方。
  - 390dp/1.0x 断言两者同排、右对齐且不截断。

## 可选项

- C1：备份账号副标题去掉重复类型名称。
- C2：运行时详情弹层的 `type · version` 复用 `_joinNonEmpty`，空值不产生多余分隔符。
- C3：防火墙转发列表底部增加 FAB 避让间距。
- C4：文件面包屑根节点改为「主目录 / Home」，与页面标题「根目录 / Root」区分。
- C5：已安装应用的 Compose 路径为空时整行隐藏。

## 附带修复

- `BottomSheetSurface` 在内容外增加透明 `Material`，消除 `SwitchListTile` 位于装饰容器内时的调试断言。

## 回归

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：98 / 98
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0（write 382，unwired 0，allowlist 23）
- ARB：中英各 1639 条，key 差集 0
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,386,558 字节
- SHA-256：`40e2b24cbfaae29e2876dd2437763fb54bb59342b41717a4bfb55a5f62df4bcf`
- 预览地址返回 HTTP 200

## 未执行项

- 无 Android 真机或模拟器，本轮未生成 390/360/320 的真实截图，使用 widget 尺寸与 1.3x 文本缩放回归覆盖。
- 无 OSS/S3 凭据，未在真实面板创建云端账号并执行连接测试；payload 契约与编辑/新建流程已由测试覆盖。
