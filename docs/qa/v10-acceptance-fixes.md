# OneDash 验收报告 v10 修复回执（v30）

## 处理范围

- 来源：`OneDash 验收报告 v10`（基于 `f96a0b7`）。
- R1、R2 两项应修全部处理。
- O1-O8 八项可选全部处理。
- 新增占位符对比度、尾值挤压标题、备份类型本地化三组回归测试。

## 应修项

### R1 尾值挤压标题

- `SplitListTile` 的 `trailing` 限制在行内可用宽度的 60% 以内，标题始终保有剩余空间。
- 直接传入的 `Text` 尾值统一改为单行省略，并右对齐。
- 图标、按钮、开关等非文本尾值继续按固有宽度布局。
- 390dp 与 320dp/1.3x 下「到期时间」标签完整可见，长日期值截断显示。
- 新增 320dp/1.3x 回归测试，断言标题宽度大于 60dp 且尾值单行省略。

### R2 占位符对比度

- 全局 `hintStyle` 透明度从 60% 调整为 80%，继续使用 `onSurfaceVariant` 与常规字重。
- 浅色主题下占位符与输入框填充色的对比度达到 4.5:1，输入值仍保持 `onSurface` 100%。
- 新增主题对比度测试，明暗主题同时校验。

## 可选修复

### O1 运行时列表孤立「-」

- `_joinNonEmpty` 空集返回空串，卡片按行隐藏空元信息，不再渲染孤立「-」。

### O2 运行时详情元信息

- 模块的 `version · description` 改为先过滤空值再拼接，避免前导或尾随分隔符。

### O3 创建容器页底栏

- 创建容器与编辑容器页底栏迁移到 `FormFooter`，补顶部分隔线、surface 背景与底部安全区。

### O4 备份账号类型

- 新增 `backupAccountTypeLabel`，覆盖 Local、SFTP、S3、OSS、COS、MinIO、OneDrive、WebDAV。
- 列表副标题与新增账号下拉框均使用本地化标签，未知类型保持原值。

### O5 计划任务与 Compose 状态

- 计划任务最近一次执行结果在状态点后补状态文字。
- Compose 卡片在状态点后补「运行中 / 已停止」文字。
- 状态文字复用 `taskStatusLabel`，与快照、备份保持一致。

### O6 告警卡片 meta

- 紧凑布局下 meta 行允许两行，1.3x 字号仍能显示完整通知方式。

### O7 栏目名空态

- 运行时、PHP 扩展、Node 模块、网站模板、模板生成结果、SSH 服务、磁盘、诊断、诊断快照、FTP、Fail2ban 封禁 IP、病毒扫描、通知方式、进程、终端会话、文件历史、AI 文件搜索、负载均衡上游共 18 处空态改为专用标题。
- 英文与中文 arb 均新增对应文案。

### O8 缺失记录异常

- 新增 `RecordNotFoundException`，数据库详情查不到记录时不再抛 `StateError`。
- 错误映射到统一的「内容不存在」视图，业务文案不会上屏。
- `dio_client_provider` 的服务器缺失分支同步改用 `ServerNotFoundException`，项目内已无 `StateError`。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：93 / 93
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0（write 382，unwired 0，allowlist 23）
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,386,558 字节
- SHA-256：`11aad3f0c5f52a7da5f19b7b47044c50f5c52ed0e03bcf2e0737c9c0c9c59d81`
- 预览地址返回 HTTP 200
