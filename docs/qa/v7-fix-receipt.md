# OneDash v7 修复回执

- 基线：`70cf915`
- 依据：`OneDash-验收报告-v7.md`
- 范围：1 项必修 + 6 项可选优化

## 必修

### 任务失败原因被错误映射吞掉

- 新增 `TaskFailedException`，由 `TaskWaiter` 在任务失败或等待超时时抛出，携带面板日志最后一行与超时标记。
- `error_mapper.dart` 增加类型分支：失败标题走 `task_failedTitle`，超时标题走 `task_timeoutTitle`；消息优先展示面板原始日志，日志为空时用 `task_failedNoDetail`，超时用 `task_timeoutMessage`。英文界面标题为英文，面板日志保持原文。
- 防火墙任务轮询复用同一异常与映射，规则下发失败不再折叠成通用文案。
- 测试覆盖：任务失败日志透出、执行中等待超时、错误映射的中英文标题与日志保留。

## 可选优化

1. 文件页底部计数改用 `FilesState.total`，与目录真实总数一致。
2. 防火墙规则端口为空时只显示"所有端口"，不再拼接协议。
3. 规则副标题的白名单标记改用 `firewall_whitelist`，中英文均本地化。
4. 负载均衡服务器摘要之间增加分隔线，换行后不再与下一台服务器混淆。
5. 防火墙规则列表底部留白增加 `AppTokens.s48`，静止时也避开小号 FAB。
6. 创建容器等待期间增加"转到后台继续"次按钮，可离开页面并由服务端继续执行。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：78 / 78 通过
- `bash tool/check_error_leaks.sh`：exit 0
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 构建产物

`flutter build apk --release --target-platform android-arm64 --split-per-abi` 成功，
产物 SHA-256 `462f2b21de18bc969aff8a0e6a61e62be0ee73c7d2ad879dcfc1bdd2a7452ad5`。
