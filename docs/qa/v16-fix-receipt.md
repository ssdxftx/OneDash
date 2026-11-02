# OneDash 可控能力补全回执（第九批：文件大小、容器日志、备份存储桶）

## 本批新增

- 文件：非目录项新增“计算精确大小”，调用 `getFileSize`。
- 文件分享详情：打开详情时重新读取 `getFileShareDetail`，失败时回退列表行。
- 容器：动作面板新增“清空容器日志”，二次确认后调用 `cleanContainerLog`。
- 备份账号：新增“列出存储桶”和“刷新 Token”动作，分别调用 `listBuckets`、
  `refreshToken`。

## 可达性守卫

- 可达性脚本阈值降到 0，当前 `unwired = 0`。
- 新增 73 条 allowlist。它们都属于以下三类，已在 `tool/unwired_allowlist.txt`
  顶部注明：
  1. Web 端专属流程（面板 SSL/MFA/Passkey、告警通知配置、运行时创建等）。
  2. 依赖设备文件选择器或应用详情上下文的流程（备份恢复上传、镜像导入、
     SSL/CA 下载等）。
  3. 已被其他同名 repository 包装器覆盖的辅助/内部接口。
- allowlist 总数 87，当前没有未接写操作计数。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85 通过
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：0，exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建

按用户要求，本批不重新构建 APK。上一版 APK 保持：
`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`。

## 明确边界

可达性计数归零代表“没有未被 allowlist 登记的写方法”，不代表所有 Web 端动作
都已在移动端实现。allowlist 中的 73 条仍是待后续设计的能力。
