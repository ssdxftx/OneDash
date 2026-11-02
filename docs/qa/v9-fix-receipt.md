# OneDash 可控能力补全回执（第二批：网站 + 文件）

- 基线：第一批完成后工作树
- 依据：`OneDash-可控能力补全任务书` 4.2 与 4.4

## 网站

- 详情右上角新增“高级设置”，`/websites/:id/advanced` 提供 4 个页签。
- 基础配置：编辑备注/别名/收藏；默认文档；流量限制；目录运行用户与用户组。
- 安全：根路径访问认证、CORS、防盗链、真实 IP，均可读取当前值、修改并保存。
- 伪静态：读取模板列表、按模板加载内容、编辑并保存规则。
- 重定向：列表、创建、编辑；支持域名/路径类型、301/302、保留路径、重定向根路径。
- 反向代理：新增与编辑面板，支持名称、匹配路径、上游地址、Host、启用、SNI、
  上游证书校验；已有启停与删除保留。
- SSL：详情 SSL 页签新增“证书管理”，支持粘贴 PEM 上传、申请 ACME 证书、
  选择 ACME 账号、自动续签开关、删除证书。原绑定已有证书流程保留。
- 日志：访问日志/错误日志开关已接线。
- 数据库：可查看当前关联、选择新数据库或解除关联。

## 文件

- 新增文件工具页 `/files/tools`，包含 4 个页签：
  - 收藏：列表、打开路径、取消收藏。
  - 回收站：列表、还原、清空。
  - 分享：列表、详情、复制分享码、取消分享。
  - 远程下载：新建下载、任务 key 列表、停止下载。
- 文件操作面板新增“移动或复制”和“添加到收藏”。
- 批量选择新增“批量权限”，支持 mode、用户、用户组和递归。
- 子目录大小计算与原有权限面板保留。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85 通过
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：152，exit 0；阈值从 189 下调到 152
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 未覆盖

- 网站 PHP 版本切换、ACME/DNS/CA 账号 CRUD、路径级访问认证、SSL 下载与单独续签。
- 文件远程下载只有任务 key，没有服务端实时进度百分比。
- 报告中的应用、数据库、备份、主机、运行时、面板设置批次仍未接线。
- 无 Android 真机或模拟器，未执行真实点击与真面板写操作验收。

## 构建产物

`flutter build apk --release --target-platform android-arm64 --split-per-abi` 成功，
产物大小 24,791,450 字节，SHA-256
`51e5e16d4b10a9ba5d1865d197042cb8f34193499dca91578c35755de4e08c05`。
预览地址：
`https://8000-5f085df3015621c9.monkeycode-ai.online/OneDash-v1.0.0-arm64-v8a.apk`
