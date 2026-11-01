# v6 验收报告回执

日期：2026-11-01
基线：`ced7f1c`
范围：v6 验收报告的 P1、P2、P3 低风险项与 UI 可用性修正

## P1

### P1-1 容器创建等待后台任务

- 新增 `lib/data/api/task_waiter.dart`，统一轮询 `/logs/tasks/read`，区分
  `Success`、`Failed/Error/Canceled` 和超时。
- 防火墙原有等待逻辑改为复用 `TaskWaiter`。
- `ContainerApi.createContainer` 返回请求体里的 `taskID`。v2.4.2 的
  `POST /containers` 由 Go 端立即返回并在后台执行，任务 ID 来自
  `dto.ContainerOperate.taskID`，响应体本身没有可用的任务 ID。
- `ContainerRepository.waitForTask` 等待任务结束。只有成功才提示并退出页面；
  失败时停留在表单，用任务日志最后一行经 `showErrorToast` 展示。
- 提交期间按钮显示“正在创建容器…”。
- 新增 `test/unit/task_waiter_test.dart`，覆盖成功与失败日志回传。

### P1-2 横向页签与筛选芯片

- `SegmentedTabs` 改为 StatefulWidget，持有 `ScrollController` 与每项
  `GlobalKey`；选中项变化后在下一帧调用 `Scrollable.ensureVisible`，将选中项
  滚到中间。
- 页签左右边缘按可滚动方向显示渐隐，滚到头时对应侧恢复实色。
- `AppFilterChips` 使用同一套滚动边缘渐隐逻辑。
- 新增 `test/widget/segmented_tabs_test.dart`，验证 320dp 下最后一个页签会在
  首次布局后滚入视口。

## P2

| 项 | 处理 |
|---|---|
| P2-1 | 防火墙规则行改为第一行地址、第二行端口/协议与元信息，端口不再被地址挤掉 |
| P2-2 | FAB 改为 `small`，列表向下滚动时隐藏、向上滚动时恢复 |
| P2-3 | SSH 值映射为开启/关闭/仅密钥/禁止密码；未知值原样显示并使用等宽字体 |
| P2-4 | 工具箱状态改为已安装/运行中/已停止/未安装；Fail2ban 关闭时显示已停止 |
| P2-5 | Fail2ban 先落地基础信息再单独取封禁列表；未安装时只显示说明，不显示开关 |
| P2-6 | 网络图表标题改为“网络趋势（近 5 分钟）”；少于 3 个采样点时显示 72dp 骨架与采集提示 |
| P2-7 | 磁盘分区增加用量条（80% 警告色、90% 危险色）；顺序改为系统→数据→未分区；卸载改为危险按钮样式 |
| P2-8 | 非选择态显示“共 N 项”；选择态显示“已选 N 项”和全选入口 |
| P2-9 | 模板卡压缩为标题 + 类型 chip + 两行描述 + 底部生成按钮，编辑/删除收进 ⋮ |
| P2-10 | 负载均衡服务器行补充权重、失败次数、超时、最大连接摘要 |

模板 DTO 没有版本号字段，卡片上的 chip 使用模板类型（单页/多文件），避免展示
不存在的版本信息。

## P3

- 防火墙规则删除确认补 `danger: true`。
- 网站打开失败改用本地化文案，不再弹出英文 `open website failed`。
- 监控设置未加载时隐藏副标题，不再显示 `-s · -d`。
- 防火墙转发规则 family 显示为 `IPv4`/`IPv6`。
- 防火墙后端切换要求输入当前后端名，与关机同级。
- 终端错误条改为带圆角和图标的卡片，不再全宽红底。
- 网站删除在选项页之后追加域名输入确认。

## 自动检查

```text
flutter gen-l10n
flutter analyze --fatal-infos
flutter test test/unit test/widget test/app_smoke_test.dart
bash tool/check_error_leaks.sh
git diff --check
```

结果：

- `gen-l10n`：成功生成中英文资源
- `analyze`：`No issues found!`
- 测试：75 项全部通过（新增任务等待 2 项、页签滚动 1 项）
- `check_error_leaks.sh`：exit 0
- `git diff --check`：无输出

## 未闭环

以下路径仍受实验面板能力或设备限制，本轮未做端到端实测：

- firewalld/ufw 原生规则详情：实验面板是 iptables。
- 磁盘分区/挂载/卸载：未对共享面板执行写操作。
- PostgreSQL/MongoDB：面板未安装对应应用。
- ClamAV/Fail2ban 安装与真实封禁：面板未安装。
- 终端 WebSocket 全链路：无 Android 真机或模拟器。
- 容器创建失败与成功的真面板 UI 回归：本轮用 `TaskWaiter` 单测覆盖状态判定，
  未在真面板创建容器。
- 320dp + 1.3× 字体的截图回归：当前环境无设备渲染能力。

## 构建产物

`flutter build apk --release --target-platform android-arm64 --split-per-abi`
成功，产物 `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`，
SHA-256 `7f02a3e8cbd88ea8d588e2461d6f677aa5ef2269d123fbd3404b118334f88207`。
