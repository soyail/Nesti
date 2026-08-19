# 前端与桌面表现

## 当前状态

桌面技术栈尚未最终确定。[ADR-0001](adr/0001-desktop-technology-stack.md) 建议先用 Flutter Desktop 进行原型验证，在验收通过前仍为 `Proposed`。本文档继续定义与框架无关的表现层边界。

## 界面分层

1. **Shell Adapter**：封装窗口、托盘、通知、快捷键和系统权限。
2. **Platform Capability Client**：调用窗口、托盘和系统能力端口，不直接依赖具体插件。
3. **Presentation State**：将领域事件转换为宠物动画、气泡和卡片状态。
4. **Components**：只渲染数据和派发用户意图，不承载提醒决策、记忆写入或 LLM 调用。

## 建议状态模型

表现层至少区分：

- 宠物基础状态：`idle` / `focused` / `sleeping` / `celebrating`
- 互动容器：`hidden` / `bubble` / `conversation` / `settings`
- 系统状态：`ready` / `offline` / `permissionRequired` / `degraded`
- 用户模式：`normal` / `doNotDisturb` / `carePaused` / `sensingPaused`

动画状态不应被用作业务事实的唯一来源。

## 桌面约束

- 透明窗口不应阻挡无关区域的鼠标操作。
- 用户可随时拖动、隐藏或退出宠物。
- 全屏、演示或会议状态下默认不展示主动气泡。
- 重启后可恢复安全的窗口位置，但不因多显示器变化而丢失在可见区域外。
- macOS Spaces、Windows 虚拟桌面、DPI/缩放变化和显示器热插拔必须作为一等窗口事件处理。

## 组件开发约定

- 组件优先接收显式 props/状态，避免隐式读取全局存储。
- 将持久化、权限请求和系统 API 放在适配器内。
- 交互事件用用户意图命名，如 `snoozeReminder`，而不是 `clickSecondaryButton`。
- 将文案与决策结果分离，以便本地化和个性化。

## 性能与电量

- 宠物隐藏、系统休眠或表现状态为 `quiet` 时，停止或显著降低动画刷新。
- 动画资源解码、LLM 请求、数据库与平台调用不在 UI 线程执行长耗时工作。
- 低电量或系统节能模式可以降低帧率、非必要动效和感知频率。
- 性能预算和测试环境由 [TEST_MATRIX.md](TEST_MATRIX.md) 维护。

## 测试重点

- 状态到视图的确定性映射。
- 勿扰、减少动效、键盘导航和多显示器。
- 气泡被忽略、延后、关闭后的状态回传。
- 离线、LLM 超时、权限拒绝时的可恢复界面。
- 同一套平台端口契约在 macOS 和 Windows 适配器上的语义一致性。
