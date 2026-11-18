# OneDash UI 修复回执（v30）

本回执记录批次 1–3 的修复项与批次 4 的决策，不再手写“全绿”结论。守卫、analyze 与 test 的原始输出以 CI run 的 `ui-guards` artifact 和 workflow 日志为准。

## 批次 1：编译与守卫

- 进程页 WebSocket 启动移动到 `didChangeDependencies`，避免 `initState` 读取本地化。
- 命令库 CSV 导入在异步操作后补 `context.mounted` 检查；服务器切换补齐 `unawaited`。
- UI 守卫只统计 actions 数组顶层的按钮图标，菜单内图标不再误报。
- 快捷入口目录的 4 个 CRUD 方法加入白名单：v1 客户端只提供只读快捷入口，不提供目录编辑。
- 英文守卫为 PID/RSS/VMS 等 Linux 指标缩写提供术语白名单。
- CI 上传三个守卫的原始日志，`v28` 回执中的手写结论已移除。

## 批次 2：结构问题

- `AppBarLarge` 增加 `compact` 变体，网站创建向导改用标准页头，`PillAppBar` 标记弃用。
- 页面动作超过 2 个时由 `AppBarActions` 收进「更多」菜单，刷新保持第一位，新建保持最后一位。
- 收起重复错误提示：复核结论，现有调用均为动作反馈或已有页内错误态，无需改代码。`showErrorToast` 注释明确只用于用户动作失败。终端页保留裸 `AppBar`，已注明控制台专属深色头部。
- 分段控件下划线宽度跟随标签宽度。
- `StatusPill` 成为唯一状态胶囊，支持圆点与最小宽度；网站卡片状态改为胶囊。
- 卡片描边改用 `scheme.outline`，浅色、深色与 OLED 三套主题下均过 3:1。
- Toast 移到底部导航栏上方，不再遮挡 tab 行。
- 服务器编辑页保存按钮固定在底栏，表单顶部/底部间距与 `SimpleFormPage` 一致。
- 弹窗容器宽度拉满；模板空态标题与说明拆分，空态图标改为 `template`。
- 容器停止动作从暂停图标改为停止图标。

## 批次 3：动效与打磨

- 弹窗改用单调减速曲线，移除欠阻尼回弹。
- 新增 `ListAnimationScope`，关闭列表动画不再关闭系统级页面转场、弹窗和骨架动画。
- 页面推入增加下层页面的左移与降透明度，返回对称。
- 骨架高光亮度从 6% 提到 13%，扫描范围覆盖完整周期。
- 导航栏在弹窗打开 280ms 后移除，关闭时以位移动画回归。
- 新增 `iconInline`/`iconSmall`/`iconMicro` 与 `mono`/`monoSmall` 字体样式；`lib/presentation` 内不再有 `fontSize:` 或 `fontFamily: 'monospace'` 硬编码。
- 网站状态文案收敛到 `websiteStatusLabel`，SSH 日志状态方法改名区分。
- 状态点脉冲与危险色映射同源，`unhealthy`/`offline` 等状态也会脉冲。

## 批次 4：设计决策

- D-1 形状语言：采用方案 A。输入框圆角从 `rSm`(10) 提到 `rMd`(14)，与卡片 18、弹窗 28 形成 14/18/28 阶梯；按钮保留 M3 全圆，补上两处裸 `OutlineInputBorder` 的 14dp 圆角；三档 golden 已按新圆角重生成。
- D-2 4dp 间距：完成。分段控件 9dp 改为 `AppTokens.s8`，其余候选值均为 2/6 的图标或细缝尺寸，保持现状。
- D-3 卡片填充提档：不做。保留 `surfaceContainerLow`，只维持批次 2 的 `outline` 描边对比度。
- D-4 视图切换与筛选条层级：采用底色带方案。防火墙筛选 chips 外加 `surfaceContainerLow` 通栏底带和 4dp 内边距，tab 与内容区层级分开，交互不变。

## v30 验收报告复修

- B-1 编译项：当前 HEAD 已包含 4 个 ARB 键与 `DioClient.languageCode` 透传，验收副本的报错源于基线差异，本轮无需改动。
- B-2 概览页动作：改用 `AppBarActions`，`maxInline: 1` 只保留刷新，监控设置与终端进入「更多」。
- 页头标题：长标题改为等比缩小而不是省略号，320dp、1.25 倍字体下服务器名完整显示；副标题仍按单行省略。
- C-1 容器状态：状态改用带点 `StatusPill`，Compose 标签改为中性胶囊，状态重新成为卡片第二行的视觉主项。
- C-2 骨架高光：扫描带宽从整块宽度收窄到半个容器宽，中心仍走完整周期。
- C-3 导航栏淡出：弹窗分支时长从 120ms 改为 `dEmphasis`(280ms)，与摘除时机一致。
- CI：`analysis_options.yaml` 暂时忽略 SDK 级 `deprecated_member_use`，等待全仓迁移到 `material_ui` 后移除。

## v31 验收报告复修

- V31-1/V31-2：页头标题撤销 `FittedBox` 缩放，改为 `headline`(24) → `titleL`(20) 单档降级加省略号，chevron 重新紧贴标题。
- V31-3：保留 `deprecated_member_use: ignore` 并补迁移 TODO 与追踪说明；CI 以 `--fatal-infos` 运行，切成 warning 会直接阻断流水线。
- V31-4：容器与网站卡片删除标题行的 `StatusDot`，状态只由第二行 `StatusPill` 表达。
- V31-5：状态胶囊底色 alpha 从 0.12 提到 0.16，浅色主题下与卡片底可区分。

## v32 验收报告复修

- P2-1：`StatusPill` 浅色模式下胶囊文字在 tone 上叠加 16% 黑色，深色模式保持 tone 原色；底色 16% 不变，圆点保持 tone。实测 success 4.88、warning 4.83、danger 5.81，均达到 4.5:1，深色模式保持 6.6 以上。
- P3-1：页头测试补回 compact 长路径降档到 14sp，以及长标题下 chevron 间距与无溢出的断言。
- P3-2：`_fitsOneLine` 加回 `maxWidth` 非有限或非正数时直接判定可容纳的防御。
- 新增 `test/widget/status_pill_test.dart`，读取组件实际文字色与底色计算对比度，覆盖浅色与深色下的 success、warning、danger。
