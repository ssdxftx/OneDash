# OneDash 可控能力补全回执（第八批：证书账号、取消忽略）

## 网站证书账号

- 网站详情右上角新增“证书账号”入口。
- 页面分 ACME / DNS / CA 三个页签：
  - ACME：账号列表、新建、删除；支持 Let's Encrypt、ZeroSSL、自定义 CA、代理和 EAB 开关。
  - DNS：账号列表、新建、删除；授权 JSON 直接提交。
  - CA：自签 CA 列表、新建、签发证书、续签、删除。
- 原有 SSL 证书申请/上传/删除与绑定流程保留。

## 应用

- 已安装应用菜单新增“取消忽略更新”：
  - 读取忽略列表。
  - 匹配当前安装 ID 后取消忽略。
  - 未找到时给出明确提示。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85 通过
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：77，exit 0；阈值从 89 下调到 77
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 未覆盖

- ACME/DNS 编辑、CA 下载。
- 网站 PHP 版本切换、代理原始文件、自定义伪静态模板管理、重定向源文件。
- 应用商店配置、安装检查、端口读取。
- 数据库远程库编辑/删除/连通性测试、PG/Mongo 专用删除。
- 主机 SSH 配置文件、连接测试、磁盘挂载/分区、进程终止。
- 运行时创建/编辑、PHP 扩展、Node scripts。
- 面板 SSL/MFA/Passkey、API 开关、快照恢复/回滚/导入。
- 无 Android 真机或模拟器，未执行真实点击与真面板写操作验收。

## 构建产物

`flutter build apk --release --target-platform android-arm64 --split-per-abi` 成功，
产物大小 25,056,074 字节，SHA-256
`cca3ce5e41df02cd4adcc3c9a1ea21cf507d8a09f981ab07dc5803aae20d3fed`。
预览地址：
`https://8000-5f085df3015621c9.monkeycode-ai.online/OneDash-v1.0.0-arm64-v8a.apk`
