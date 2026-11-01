# A1 防火墙 v2.4.2 验收

日期：2026-10-31
环境：`docs/lab.md` 记录的 2.4.x 面板

## 已完成

- 只保留 `hosts/firewall/*` v2.4 路由，删除 `unified_firewall_api.dart` 与 `unified_firewall_dto.dart`
- `rules/search` 使用完整 scopes，不再请求旧 `/firewall/search`
- 规则新增、删除、改备注通过真实面板验证
- 页面改为 规则 / 转发 / Docker / 设置 四段
- 规则支持 IPv4/IPv6、允许/拒绝筛选、搜索、编辑、删除、上移/下移
- 转发支持新增、编辑、删除、启用
- Docker 页展示端口守卫状态与已发布端口
- 设置页展示后端、版本、面板/SSH 端口、IPv6 开关与端口白名单
- 设置页支持后端切换、白名单编辑、规则备份恢复/重置、原生 firewalld/ufw 详情读取

## 真实面板结果

| 操作 | 结果 |
|---|---|
| `FirewallApi.getBaseInfo` | `iptables`，版本 1.8.10 |
| `FirewallApi.getSettings` | `panelPort=2006` |
| `searchRules` | 14 条，含受保护规则 |
| `createRules` 8081 | task Success，列表可见 |
| `deleteRules` 8081 | task Success，列表消失 |
| `updateRule` 8082 备注 | 成功，备注即时更新 |
| `deleteRules` 8082 | task Success |

## 自动检查

- `flutter analyze --fatal-infos`：0 issues
- `flutter test test/unit test/widget test/app_smoke_test.dart`：61 项通过
- `tool/check_error_leaks.sh`：exit 0

## 未覆盖

- 当前环境无 Android 真机/模拟器，四段页面未做设备截图；布局按 `AppTokens` 与既有列表页结构实现
- 关闭/开启防火墙服务未在验收中执行，避免中断当前面板会话
- 后端切换、规则重置/恢复、原生详情读取未执行，避免改动共享面板的防火墙后端
- 白名单编辑未执行，避免修改共享面板的放行端口
