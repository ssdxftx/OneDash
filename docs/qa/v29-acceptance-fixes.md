# OneDash 验收报告 v9 修复回执（v29）

## 处理范围

- 来源：`OneDash 验收报告 v9`（基于 `3d82546`）。
- 必修项 2 项、应修项 8 项、可选 4 项全部处理。
- 额外补充 `FormFooter` 底部操作栏组件与窄屏告警卡片布局回归测试。

## 必修项

### P0-1 动作面板溢出

- `ActionSheetScaffold` 的信息卡保持固定，动作区改为 `Flexible + SingleChildScrollView`。
- 15 行动作在 390×844 与 320×640/1.3x 下可完整滚动，不再出现 `RenderFlex overflowed`。
- 影响容器动作、镜像与网络、Compose、计划任务共 4 个入口。
- 新增回归测试：20 行动作在 320×640 下不溢出，并可滚动到第 20 项。

### P0-2 320dp 告警标题被压缩

- `_AlertCard` 使用 `LayoutBuilder`：宽度不足或 textScale ≥ 1.3 时进入紧凑布局。
- 紧凑布局下删除收进 `⋯` 菜单，开关保留，标题允许 2 行。
- 常规宽度继续显示独立删除按钮。

## 应修项

1. 表单底部操作栏
   - 新增 `FormFooter`：顶部分隔线、surface 背景、安全区与非对称内边距。
   - 计划任务、告警、Compose 三个表单统一使用。
2. 横向筛选与页签右缘裁切
   - `AppFilterChips` 与 `SegmentedTabs` 右侧留白提升到 32dp，渐隐区从 8% 扩大到 12%。
3. SSL 管理页
   - 过期证书显示“已过期”危险色提示；30 天内显示剩余天数警告色。
   - 服务商枚举改为本地化标签：DNS 账号、手动 DNS、HTTP、自签名、手动上传、来自主节点。
   - 4 个常驻图标收进菜单，域名在窄屏有更多展示空间。
   - 空态补“上传证书”主行动按钮。
4. 快照页
   - 失败状态显示 `message`，并用危险色呈现。
   - 状态点旁补状态文字；编辑描述与删除收进菜单，底部保留重建、恢复、回滚三项。
5. 运行时列表
   - 镜像、版本、端口、路径统一过滤空值后再拼接，不再出现 `- ·` 残串。
6. 表单占位符
   - 全局 `hintStyle` 降低到 `onSurfaceVariant` 60% 透明度并固定常规字重，与输入值区分。
7. 应用商店卡片
   - 网格主高度从 118dp 提升到 150dp，并按字体缩放增加，简介获得稳定两行空间。
8. 空态文案
   - 主机监控：标题改为“暂无监控数据”，描述说明首次采集后出现。
   - 应用商店：区分“未找到应用”和“未安装应用”，不再把页名当标题、把操作当描述。
   - SSL：补主行动按钮。

## 可选项

1. `StateError` 文案两处改为 `ServerNotFoundException`，由错误映射统一显示本地化提示。
2. 备份记录与快照状态补文字标签，颜色不再是唯一状态信号。
3. 备份文件名为空时显示“未命名备份”；已安装应用标题为空时回退到“已安装”。
4. 备份账号本地目录使用文件夹图标，云端账号继续使用云图标。

## 验证

- `flutter analyze --fatal-infos`：No issues found
- `flutter test test/unit test/widget test/app_smoke_test.dart`：90 / 90
- `bash tool/check_error_leaks.sh`：exit 0
- `bash tool/check_action_reachability.sh`：exit 0（write 382，unwired 0，allowlist 23）
- `git diff --check`：通过

## 构建

- 文件：`/workspace/onedash-download/OneDash-v1.0.0-arm64-v8a.apk`
- 大小：25,386,558 字节
- SHA-256：`287962f98c1b85805a2fecad0f6677e5fb4c4bf15e99d4c5f961435cff870f6e`
- 预览地址返回 HTTP 200

## 环境限制

- 无 Android 真机或模拟器，未重新产出 390dp 与 320dp 截图；本轮以 widget 尺寸回归测试代替。
- 中文字库子集缺字问题仍未解决。
