# A3 容器创建验收

日期：2026-10-31
环境：`docs/lab.md` 记录的 2.4.x 面板

## 已完成

- `ContainerApi.createContainer` → `POST /containers`
- 容器列表 AppBar 新增 `+`，进入 `/s/:id/containers/create`
- 全屏表单：镜像选择/手输、名称、重启策略、端口、目录、环境变量
- 高级区：命令、入口、工作目录、网络、CPU/内存、特权、自动删除
- 名称本地格式校验，镜像/名称为空时提交按钮禁用
- 创建成功后返回列表并 invalidate `containersProvider`

## 真实面板结果

测试容器：`onedash-a3-1793454217`

| 操作 | 结果 |
|---|---|
| 拉取 `nginx:alpine` | Success |
| 首次创建（networks 为空） | 失败：`please set up the network` |
| 加入 `1panel-network` 后创建 | Success，状态 running |
| 端口 | `0.0.0.0:18080->80/tcp` |
| 删除 | Success |

测试容器已清理；`nginx:alpine` 镜像保留。

## 自动检查

- `flutter analyze --fatal-infos`：0 issues
- `app_smoke_test` 已覆盖 `/s/1/containers/create` 路由与无异常
- 测试套件与错误泄漏守卫通过

## 未覆盖

- 当前环境无 Android 真机/模拟器，表单未做设备截图与点击验证
- 外网 18080 未放行，未通过浏览器访问 nginx 欢迎页
