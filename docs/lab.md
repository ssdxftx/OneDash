# 1Panel v2.4.2 实验室记录

- 日期：2026-10-31
- 面板：`https://1panel.06162636.xyz`（443，可信证书）
- 系统：Ubuntu 24.04，amd64
- 版本判定：通过 v2.4.2 端点探针确认，未依赖镜像 tag

## 探针结果

| 探针 | 请求 | 结果 |
|---|---|---|
| 新版防火墙设置 | `GET /api/v2/hosts/firewall/settings` | HTTP 200，`code=200` |
| 旧版防火墙搜索 | `POST /api/v2/hosts/firewall/search` | HTTP 404 |
| 网站删除 | `POST /api/v2/websites/del` | HTTP 200，`code=500 record not found`（路由存在） |

三条同时满足，判定为 2.4.x 契约。

## 契约验证

### 防火墙

- `POST /hosts/firewall/base` → `name=iptables`、`backend=iptables`、`version=1.8.10`
- `POST /hosts/firewall/rules/search` 必须携带完整 `scopes`；`all=true` 且空 scopes 会返回 `FW_SCOPE_UNSUPPORTED`
- 新建 `8080/tcp accept` → task `Success`，网页端规则数增加
- 修改规则备注 `8082` → 成功，列表即时更新
- 删除同一规则 → task `Success`，网页端规则数恢复
- 测试规则已清理

### 网站

- 新建 `onedash-a2-1793454041.example.com`（static）成功
- `POST /websites/operate {"id":40,"operate":"stop"}` → 状态 `Stopped`
- `POST /websites/operate {"id":40,"operate":"start"}` → 状态 `Running`
- `POST /websites/del` 成功，查询该域名 `total=0`
- 测试站点已删除

### 容器

- 拉取 `nginx:alpine` 成功
- `POST /containers` 首次因 `networks=[]` 失败：`please set up the network`
- 加入 `1panel-network` 后创建成功，状态 `running`，端口 `0.0.0.0:18080->80/tcp`
- 外网 18080 未放行，容器状态通过面板 API 验证
- `POST /containers/operate {"operation":"remove"}` 成功，测试容器已删除
- 测试镜像 `nginx:alpine` 保留在面板本地镜像列表

## 约束

- 所有写操作只使用 `onedash-*` 临时资源，完成后删除
- 未修改现有 12 个站点、11 个容器、防火墙白名单与面板设置
- API Key 不写入仓库
