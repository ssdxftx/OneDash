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
- 分段控件下划线宽度跟随标签宽度。
- `StatusPill` 成为唯一状态胶囊，支持圆点与最小宽度；网站卡片状态改为胶囊。
- 卡片描边改用 `onSurface` 16% 叠加，深浅主题下过 3:1。
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
- D-3 卡片填充提档：不做。保留 `surfaceContainerLow`，只维持批次 2 的 16% 描边对比度。
- D-4 视图切换与筛选条层级：采用底色带方案。防火墙筛选 chips 外加 `surfaceContainerLow` 通栏底带和 4dp 内边距，tab 与内容区层级分开，交互不变。
