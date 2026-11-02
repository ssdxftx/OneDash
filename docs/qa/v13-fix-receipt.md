# OneDash 可控能力补全回执（第六批：容器镜像仓库）

- 依据：`OneDash-可控能力补全任务书` 4.1 C 镜像能力

## 镜像

- 镜像动作面板新增：
  - 构建镜像（基础镜像、目标名称、Dockerfile）。
  - 导出镜像（归档路径）。
  - 导入镜像（支持逗号分隔的多个归档路径）。
  - 推送镜像（仓库 ID）。
- 四项均携带 taskID，通过 `/logs/tasks/read` 轮询，最后一行日志进入任务面板。
- 原有拉取、重设标签、删除保留。

## 镜像仓库

- 镜像与网络页新增“镜像仓库”页签。
- 支持列表、新建、编辑、删除、同步。
- 表单覆盖名称、仓库地址、协议、认证开关、用户名、密码。
- 内置仓库（id=1）不提供删除入口。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：85 / 85 通过
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：93，exit 0；阈值从 101 下调到 93
- `flutter gen-l10n`：通过
- `git diff --check`：通过

## 未覆盖

- 镜像构建暂未提供 tags/args 编辑。
- 编排模板导入/导出、模板删除。
- 数据库远程库、网站 ACME/DNS/CA、主机 SSH 配置文件、运行时 PHP/Node、面板 SSL/MFA、快照恢复/回滚。
- 无 Android 真机或模拟器，未执行真实点击与真面板写操作验收。

## 构建产物

`flutter build apk --release --target-platform android-arm64 --split-per-abi` 成功，
产物大小 24,990,170 字节，SHA-256
`cf694db8bc3e5698fbceef917366845d34e42f81d1aad3aa28e13cbef47c89dc`。
预览地址：
`https://8000-5f085df3015621c9.monkeycode-ai.online/OneDash-v1.0.0-arm64-v8a.apk`
