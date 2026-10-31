# A2 网站删除与启停验收

日期：2026-10-31
环境：`docs/lab.md` 记录的 2.4.x 面板

## 已完成

- `WebsiteApi.operateWebsite` → `POST /websites/operate`
- `WebsiteApi.deleteWebsite` → `POST /websites/del`
- 列表长按弹层：启动/停止、复制域名、打开网页、删除
- 详情页 `⋮`：启动/停止、打开网页、删除
- 删除弹层支持删除关联数据库、删除备份、强制删除
- 删除成功后详情页先返回列表再刷新，避免回到已删除站点

## 真实面板结果

测试站点：`onedash-a2-1793454041.example.com`

| 操作 | 结果 |
|---|---|
| 创建 static 站点 | 成功，状态 Running |
| 停止 | 状态 Stopped |
| 启动 | 状态 Running |
| 删除 | 成功，按域名搜索 total=0 |

测试站点已清理。

## 自动检查

- `flutter analyze --fatal-infos`：0 issues
- 测试套件与错误泄漏守卫通过

## 未覆盖

- 当前环境无 Android 真机/模拟器，长按弹层与详情菜单未做设备点击验证
- 未勾选“删除关联数据库/备份”的破坏性分支，避免影响现有资源
