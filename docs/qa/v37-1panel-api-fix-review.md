# v37 1Panel API 修复核验报告

## 1. 核验范围

- 修复提交：`ecbe103 fix(ui): align 1Panel v2.5.1 API contracts`
- 基线提交：`ca53eb2 fix(ui): bound subtitle shrink and align server address format`
- 服务端基准：`/tmp/1panel-v2.5.1`，commit `806de63`（v2.5.1）
- 原始审计报告：`docs/qa/v37-1panel-api-audit.md`
- 核验方式：
  - 逐项对照客户端改动、服务端 DTO/Service/API 和官方前端实现
  - 检查新增契约测试是否使用服务端真实字段
  - 运行 `flutter analyze --fatal-infos`
  - 运行全量 `flutter test`

## 2. 总体结论

修复方向正确，大部分字段名、路由和调用链已经对齐，编译和现有测试均通过。

核验时仍有 4 个高优先级问题、4 个中风险问题。高优先级问题会直接影响实际功能，其中 P0-07 存在误删风险。本轮已按本报告完成修复，结果见第 9 节。

| 等级 | 数量 | 说明 |
|------|------|------|
| 高 | 4 | 功能不可用或存在数据风险 |
| 中 | 4 | 特定场景失败、状态不一致或边界错误 |
| 低 | 1 | 契约不完整，但当前调用未使用相关字段 |

## 3. 高优先级问题

以下记录核验时的状态，修复结果见第 9 节。

### 3.1 P0-24 告警 revision 核验时仍未修复

**涉及文件**

- `lib/data/dto/alert/alert_dto.dart:135-158`
- `lib/data/dto/alert/alert_dto.g.dart:120-130`
- `lib/presentation/features/alerts/screens/alerts_page.dart:791`
- `test/unit/api_request_contract_test.dart:2240`

**问题**

客户端新增了 `revision` 字段，但服务端列表返回的字段是 `updatedAt`。官方前端在编辑告警时使用 `row.updatedAt` 作为 revision：

- `/tmp/1panel-v2.5.1/frontend/src/views/setting/alert/setting/index.vue:501`

当前 `AlertConfigInfo.fromJson` 只读取 `json['revision']`，服务端响应中没有该字段，因此 `current?.revision` 为 `null`。编辑 custom webhook 或使用 mutation 的告警时，服务端仍会返回：

- `ALERT_CONFIG_REVISION_REQUIRED`
- 或 `ALERT_CONFIG_REVISION_CONFLICT`

新增测试使用人工构造的 `revision` 字段，没有使用服务端真实响应，因此属于假阳性。

**建议**

1. `AlertConfigInfo` 增加 `updatedAt` 字段，并在 `fromJson` 中把 `updatedAt` 映射到 `revision`。
2. 更新请求继续发送 `revision`，值为列表返回的 `updatedAt`。
3. 测试改用服务端真实 JSON 形态，至少覆盖 `updatedAt` 到 revision 的映射。
4. `displayName` 服务端模型当前没有持久化字段，可作为展示字段处理，不要依赖它作为更新必填项。

### 3.2 P0-07 系统清理核验时未校验 `isCheck`

**涉及文件**

- `lib/presentation/features/toolbox/screens/toolbox_device_page.dart:316-330`
- `/tmp/1panel-v2.5.1/agent/app/service/device_clean.go:291-296,678`
- `/tmp/1panel-v2.5.1/frontend/src/views/toolbox/clean/index.vue:406`

**问题**

客户端递归收集节点时只判断了 `canDelete`：

```dart
if (node['canDelete'] != true) return;
```

服务端会把部分节点的 `isCheck` 设为 `false`，例如：

- task log：`loadTreeWithDir(false, "task_log", ...)`
- 最近升级备份：`upgradeTree.Children[i].IsCheck = false`

这些节点的 `canDelete` 仍然为 `true`。当前实现会把用户未勾选的 task log 和升级备份一并提交删除，存在误删风险。

官方前端的收集条件是：

```ts
if (canDeleteNode(item) && item.isCheck) {
    submitCleans.value.push(...)
}
```

**建议**

1. 增加 `node['isCheck'] == true` 判断。
2. 递归逻辑保留，但只提交 `canDelete && isCheck` 的节点。
3. 增加单元测试或页面测试，覆盖 task log、升级备份和普通可删除节点。
4. 在测试数据中显式区分 `isCheck=true` 与 `isCheck=false`。

### 3.3 P0-09 SSH 口令被双重 Base64

**涉及文件**

- `lib/presentation/features/host/screens/host_page.dart:992`
- `lib/data/dto/host/ssh_cert_dto.dart:66-79`
- `/tmp/1panel-v2.5.1/agent/app/service/ssh.go:636`
- `/tmp/1panel-v2.5.1/agent/app/api/v2/ssh.go:288-308`

**问题**

编辑 SSH 密钥时：

```dart
passPhrase: cert.passPhrase,
publicKey: _decodeCertField(cert.publicKey),
privateKey: _decodeCertField(cert.privateKey),
```

公钥和私钥先解码再提交，`toJson` 再编码一次，链路正确。

口令没有解码。服务端列表通过 `StringDecryptWithBase64` 返回 Base64 明文口令，`SshCertOperateReq.toJson` 又执行一次 Base64 编码。服务端 API 只解码一次，最终拿到的仍是 Base64 字符串，而不是真实口令。

影响：

- 无口令私钥可以正常编辑。
- 带口令的私钥在 `validateSSHKeyPair` 阶段解析失败，编辑仍然不可用。

**建议**

1. `passPhrase` 同样使用 `_decodeCertField` 解码后再交给 DTO。
2. 或者调整 DTO：口令字段接收已解码明文，由 `toJson` 统一编码。
3. 增加带口令私钥的编辑测试，断言最终请求体中的口令只编码一次。

### 3.4 P1-02 镜像导出默认 path 仍是镜像 tag

**涉及文件**

- `lib/presentation/features/containers/screens/container_resources_page.dart:590-592,608-615,671`
- `/tmp/1panel-v2.5.1/agent/app/service/image.go:401`
- `/tmp/1panel-v2.5.1/frontend/src/views/container/image/save/index.vue:20-30`

**问题**

本次修复增加了独立的归档文件名，但导出表单的第一个字段仍默认使用镜像 tag：

```dart
final target = TextEditingController(text: name);
final archive = TextEditingController(
  text: operation == 'save' ? _archiveFileName(name) : '',
);
```

提交时：

```dart
path: value,
name: archiveValue...
```

服务端写入路径为：

```go
fmt.Sprintf("%s/%s.tar", req.Path, req.Name)
```

`Path` 应该是目录。默认值 `nginx:1.27-alpine` 不是目录，导出会失败。官方前端的 `path` 初始值为空，并单独提供目录选择器。

**建议**

1. 导出时 path 默认留空，或默认使用一个可写目录。
2. 增加目录选择器或至少校验 path 是目录。
3. 保持 `tagName` 为镜像 tag，`name` 为文件名。
4. 增加导出请求测试，断言 `path` 和 `name` 分离。

## 4. 中风险问题

以下记录核验时的状态，修复结果见第 9 节。

### 4.1 P0-06 防火墙恢复固定 `initialize:false`

**涉及文件**

- `lib/data/api/firewall_api.dart:367-375`
- `test/unit/api_request_contract_test.dart:2182-2189`
- `/tmp/1panel-v2.5.1/frontend/src/views/host/firewall/components/rule-initialize.vue:201`

当前恢复请求固定发送：

```dart
'initialize': false
```

官方前端默认 `initialize = true`。服务端在 `initialize=false` 时会跳过链初始化和白名单同步，恢复备份可能只创建规则，没有完成完整初始化。

建议恢复操作默认发送 `initialize: true`，或提供明确选项；同时更新当前测试中的 `false` 断言。

### 4.2 P0-19 改密后页面状态没有刷新

**涉及文件**

- `lib/data/repositories_impl/setting_repository_impl.dart:275-285`
- `lib/presentation/features/panel_settings/screens/panel_settings_page.dart:1988-2010`
- `/tmp/1panel-v2.5.1/core/app/auth/auth.go:334-336`

Repository 已经清除内存会话和持久化会话，服务端也会删除当前会话。

页面成功后只显示提示，没有 invalidate `_panelSettingsProvider`，也没有跳转登录。当前页面会继续显示“已登录”，后续请求返回 401，用户需要手动刷新或重新进入页面。

建议在改密成功后：

1. `ref.invalidate(_panelSettingsProvider)`。
2. 清理面板页面状态并跳转登录。
3. 补充改密成功后的页面行为测试。

### 4.3 P1-08 运行时多端口会被改成同一个端口

**涉及文件**

- `lib/presentation/features/runtimes/screens/runtimes_page.dart:450-452`
- `lib/data/dto/runtime/runtime_dto.dart:159-190`

当前实现把所有暴露端口的 hostPort 都改成同一个新端口：

```dart
final updatedPorts = detail.exposedPorts
    .map((item) => item.copyWith(hostPort: portValue))
    .toList(growable: false);
```

多端口运行时会生成重复 hostPort，服务端端口检查可能失败。

另外 `ExposedPort` DTO 没有 `protocol` 字段，更新后会丢失 UDP 等协议信息。

建议：

1. 只更新用户实际修改的端口，或只更新第一个匹配端口。
2. 为 `ExposedPort` 增加 `protocol` 并透传。
3. 补充多端口运行时测试。

### 4.4 P0-05 认证镜像仓库的密码仍无法保留

**涉及文件**

- `lib/data/dto/container/image_dtos.dart:35-85`
- `lib/presentation/features/containers/screens/container_resources_page.dart:1307-1314`
- `/tmp/1panel-v2.5.1/agent/app/service/image_repo.go:180-194`

列表接口返回的 `ImageRepoInfo` 不包含密码，客户端 `ImageRepoDto.password` 始终为空。编辑认证仓库时表单发送空密码，服务端在 `auth=true` 时执行 `CheckConn`，空密码会导致 docker login 失败。

本次修复已经保留 `auth`、`username`、`protocol` 和 `downloadUrl`，比之前有改善；密码仍然需要用户重新输入。

建议：

1. 编辑认证仓库时要求重新输入密码，并做必填校验。
2. 或服务端在密码为空时保留旧密码。
3. 在 UI 中明确提示“编辑认证仓库需要重新输入密码”。

## 5. 全量修复状态

### 5.1 P0

| 项目 | 状态 | 说明 |
|------|------|------|
| P0-01 容器 CPU/内存 | 已修复 | DTO 改为 double，页面按核/MB 提交和展示 |
| P0-02 Compose env | 已修复 | 改为字符串响应 |
| P0-03 Compose 测试 | 已修复 | 编辑测试使用 `from=path` |
| P0-04 多文件 Compose | 已修复 | 使用 `primaryConfigFile` |
| P0-05 镜像仓库 | 已修复 | 完整字段已接入，认证仓库编辑要求重新输入密码 |
| P0-06 防火墙恢复 | 已修复 | 恢复请求改为 `initialize=true` |
| P0-07 系统清理 | 已修复 | 只提交 `canDelete && isCheck` 的节点 |
| P0-08 VM 控制台 | 已修复 | 先调用 console 接口，再建立 WebSocket |
| P0-09 SSH 密钥编辑 | 已修复 | 编辑时先解码 `passPhrase` |
| P0-10 远程数据库新增 | 已修复 | 新增走 create，编辑走 update |
| P0-11 数据库删除 | 已修复 | 使用 `dbType`，远程走 `/db/del` |
| P0-12 MFA 安全入口 | 已修复 | 二次登录携带 `EntranceCode` |
| P0-13 代理设置来源 | 已修复 | 改用 Core 设置 |
| P0-14 代理枚举 | 已修复 | 使用 `Enable/Disable` |
| P0-15 API 配置 | 已修复 | 保留白名单、可信代理和有效期 |
| P0-16 API Key 默认白名单 | 已修复 | 默认 `0.0.0.0/0` 与 `::/0` |
| P0-17 API Key 编辑 | 已修复 | 回传 `allowAppBinding` |
| P0-18 Passkey 会话 | 已修复 | 登录成功后持久化会话 |
| P0-19 改密会话 | 已修复 | 改密后刷新页面并重新登录 |
| P0-20 公共备份账号 | 已修复 | 社区版隐藏公共账号入口 |
| P0-21 网站 SSL | 已修复 | 绑定时补拉 SSL 详情 |
| P0-22 默认文档 | 已修复 | 关闭时使用 delete 操作 |
| P0-23 更换数据库 | 已修复 | 使用 `site.dbID` 初始化 |
| P0-24 告警 revision | 已修复 | `revision` 回退读取服务端 `updatedAt` |

### 5.2 P1

| 项目 | 状态 | 说明 |
|------|------|------|
| P1-01 容器更新等待 | 已修复 | 使用请求 taskID 轮询 |
| P1-02 镜像导出 | 已修复 | path 默认留空并校验 |
| P1-03 镜像构建 | 已修复 | 使用 `from=edit` 和内联 Dockerfile |
| P1-04 飞书配置 | 已修复 | 补齐 scope、bot 密钥和策略字段 |
| P1-05 非 MySQL 状态 | 已修复 | 仅 MySQL/MariaDB 显示状态入口 |
| P1-06 计划任务 urlItems | 已修复 | DTO、UI 和请求体已接入 |
| P1-07 仪表盘枚举 | 已修复 | 使用 `Enable/Disable` |
| P1-08 运行时端口 | 已修复 | 只更新第一个目标端口，保留 `protocol` |
| P1-09 脚本分组 | 已修复 | 编辑时回填 `groupList` |
| P1-10 自定义告警测试 | 已修复 | 补 `id/type/config`，兼容对象响应 |
| P1-11 Docker 防护 | 已修复 | 非 initialize 分支只校验成功 |

## 6. P2 状态

| 项目 | 状态 | 说明 |
|------|------|------|
| P2-01 网站列表副标题 | 已修复 | 删除了不存在的 `dbType · dbID` 副标题 |
| P2-02 备份 size=0 | 已修复 | 显示 `common_unknown` |
| P2-03 数据库实例 DTO | 未修复 | 当前调用只使用 `type/from/database`，暂无实际行为影响 |
| P2-04 日志审计字段 | 已修复 | `user/apiKeyID/apiKeyName/authMethod` 已接入 |
| P2-05 VM 磁盘目标 | 已修复 | 改为读取 `disks[].target` |

## 7. 测试核验

### 7.1 已执行命令

```bash
export PATH=/opt/flutter-sdk/flutter/bin:$PATH
cd /workspace
flutter analyze --fatal-infos
flutter test
```

### 7.2 结果

- `flutter analyze --fatal-infos`：通过，0 issues
- `flutter test`：核验时 451 项全部通过；本轮修复后 454 项全部通过
- `pubspec.lock`：测试后已恢复，未纳入改动
- 工作区：只剩未跟踪的 APK 和 `tool/ui_audit/shots/`

### 7.3 测试覆盖问题

以下问题仍缺少页面级测试：

- P0-09：没有带口令私钥的编辑测试
- P1-02：没有镜像导出 path/name 分离测试
- P0-19：没有改密后页面状态测试
- P1-08：已补 `protocol` 解析测试，仍缺多端口页面行为测试
- P0-05：没有认证仓库编辑测试

本轮已补：

- P0-07：`test/unit/clean_items_test.dart` 覆盖 `canDelete`、`isCheck`、父节点和异常节点
- P1-08：契约测试覆盖 `ExposedPort.protocol` 的解析、序列化和 `copyWith`

核验时以下测试固化了错误或非真实契约，本轮已修正：

- `test/unit/api_request_contract_test.dart:2182-2189`：原断言恢复请求 `initialize=false`，已改为 `true`
- `test/unit/api_request_contract_test.dart:2240`：原使用人工构造的 `revision`，已改为服务端返回的 `updatedAt`

## 8. 建议修复顺序（本轮已执行）

1. P0-24：把 `updatedAt` 映射为 revision，修正测试数据。
2. P0-07：增加 `isCheck` 判断，补清理节点测试。
3. P0-09：解码 `passPhrase`，补带口令私钥测试。
4. P1-02：导出 path 默认空或目录选择，补导出契约测试。
5. P0-06：恢复默认 `initialize=true`，同步更新测试。
6. P0-19：改密后 invalidate 页面并跳转登录。
7. P1-08：只更新目标端口并保留协议。
8. P0-05：认证仓库要求重新输入密码，或服务端保留旧密码。

完成上述修复后，重新运行全量测试，并更新 `docs/qa/v37-1panel-api-audit.md` 中的修复状态。

## 9. 本轮修复结果（2026-11-20）

| 项目 | 结果 | 修复内容 |
|------|------|----------|
| P0-24 告警 revision | 已修复 | `AlertConfigInfo` 增加 `updatedAt`，`revision` 回退读取 `updatedAt`；编辑告警使用真实版本值 |
| P0-07 系统清理 | 已修复 | 提取 `collectCleanItems`，只提交 `canDelete && isCheck` 的节点，并保留父节点和子节点 |
| P0-09 SSH 口令 | 已修复 | 编辑密钥时先解码 `passPhrase`，避免二次 Base64 |
| P1-02 镜像导出 | 已修复 | 导出 path 默认留空，提交前校验路径，归档文件名与镜像 tag 分离 |
| P0-06 防火墙恢复 | 已修复 | 恢复请求改为 `initialize=true`，与官方默认行为一致 |
| P0-19 改密会话 | 已修复 | 改密后 invalidate 面板设置并重新打开登录 |
| P1-08 运行时端口 | 已修复 | 只更新第一个目标端口，`ExposedPort` 增加并透传 `protocol` |
| P0-05 认证仓库密码 | 已修复 | 编辑认证仓库要求重新输入密码，并显示提示 |

新增或调整的测试：

- `test/unit/clean_items_test.dart`：覆盖 `canDelete`、`isCheck`、父节点和异常节点
- `test/unit/api_request_contract_test.dart`：告警改用 `updatedAt` 真实字段，防火墙断言 `initialize=true`，新增运行时 `protocol` 测试

验证结果：

- `flutter analyze --fatal-infos`：通过，0 issues
- `flutter test`：454 个测试全部通过
- `python3 tool/check_hardcoded_english.py`：通过
- `pubspec.lock`：已恢复，未纳入改动
