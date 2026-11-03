# OneDash 验收报告 v17 修复回执

基线：`c683fde`（v17 验收对象，结论通过；1 应修 + 2 细节 + 1 新发现）。本轮处理 R1、N1、N2。

## R1 / N1 · 320dp / 1.3x 告警卡右侧控件

- compact 下 `⋯` 与 `Switch` 收成右侧竖排一列：`⋯` 在上、开关在下，两者宽度合一列。
- meta 不再与 `⋯` 抢同一行，「方式：」和值列获得完整宽度。
- 标题行在 compact 下恢复整行宽度，`⋯` 不再夹在两条 meta 中间。
- 切换、删除等行为不变。

## N2 · 空值短横线收口

- 新增 `common_notAvailable`（中「未获取」/ 英「Not available」）与 `displayValue(context, value)`：空串、纯空白、null 统一返回可读占位。
- 替换 SplitListTile 及详情卡中的裸 `'-'`：应用设置、主机监控/登录用户、组件检测、运行时、Fail2Ban、工具箱、ClamAV、面板设置、工具箱设备、磁盘列表等。
- 非列表文本同步替换：应用商店版本、概览值、备份时间、进程地址、网站详情、模板路径、容器内存、定时任务 spec。
- 主机监控区间改为只拼接实际存在的项，不再产生「未获取s」这类畸形文案。
- `formatUptime` 的零值返回 `未获取`；防火墙协议 DTO 的缺省值改为空串。
- 保留语义性短横线：文件类型位、字符串切分、时间戳替换。

## N3 · 密码圆点字体假象

- 按报告确认这是截图夹具字体回退，不是布局缺陷，本轮未改业务代码。

## 新增测试

- `test/widget/alerts_card_test.dart`：320dp / 1.3x、`method: telegram`，断言无溢出、`Telegram` 不被截断、`⋯` 与开关同列且开关在下。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test`：111 / 111 通过
- `dart format --set-exit-if-changed lib test`：0 changed
- `check_error_leaks.sh`：exit 0
- `check_action_reachability.sh`：exit 0（write 382，unwired 0，allowlist 23）
- `check_ui_consistency.py`：exit 0
- ARB：中英各 1656 条，key 差集 0
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,386,954 字节
- SHA-256：`88f7e0279284c07a33237221f36ffeaa71a9e5b6e8d68aa2cb123833b03b8ea2`
- 预览地址返回 HTTP 200
