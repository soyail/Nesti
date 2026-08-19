# 栖伴 Nesti 架构

## 文档状态

- 状态：建议架构，尚未有代码实现
- 适用阶段：MVP 设计与技术选型
- 更新要求：模块边界、数据流或信任边界变更时同步修订

## 架构目标

1. 将桌面集成、宠物表现和业务决策分离。
2. 使主动关怀、记忆和上下文感知可独立测试。
3. 默认本地处理敏感上下文，对外部 LLM 建立明确的脱敏边界。
4. 保留替换 UI 技术、LLM 提供商和存储引擎的能力。
5. 使领域与应用逻辑可在 macOS 和 Windows 之间共享，平台差异集中在适配层。

## 分层与职责

```text
Pet Presentation / User Interaction
                 │
       Companion Orchestrator
          │        │
          │        ├──> Proactive Care Engine
          │        ├──> Memory System
          │        ├──> LLM Gateway
          │        └──> Persistence
          │
 Platform Capability API
       │            │
 macOS Adapters   Windows Adapters
       │            │
 Desktop Shell / Context Sensing / Secure Storage

Privacy & Permissions 横切所有层
```

### Desktop Shell

负责透明置顶窗口、拖拽、点击、右键菜单、托盘/菜单栏、系统通知和全局快捷键。它只转换操作系统事件，不决定是否应当提醒用户。

### Platform Capability API

在业务逻辑与 macOS/Windows 之间提供小粒度端口，覆盖窗口、托盘、通知、快捷键、自启动、感知、安全存储、文件路径、电源状态和自动更新。统一区分不支持、缺少权限、已拒绝和临时不可用，具体见 [平台能力抽象](docs/design-docs/platform-capability-abstraction.md)。

### Pet Presentation

负责宠物视觉、动画状态、情绪映射、气泡和对话卡片。它消费结构化的表现状态，不直接访问 LLM、数据库或系统感知 API。

### Companion Orchestrator

系统的应用层入口。协调用户消息、会话上下文、主动候选行为、记忆读写和 LLM 调用，并做出“回复、提醒或保持安静”的最终决定。

### Proactive Care Engine

纯业务决策模块。根据时间、用户偏好、拒绝/忽略历史、工作状态、静默时段和同类冷却时间生成候选行为。定时器只负责触发评估，不承载决策规则。

### Context Sensing

仅输出必要的粗粒度信号，如 `working`、`idle`、`meetingLikely`、`fullscreen`、`doNotDisturb`。默认不保存完整屏幕、键入内容、剪贴板或私人通信。

### Memory System

管理短期会话、用户明示偏好、日常事件和工作回顾。记忆写入需要来源、用途和可删除性；不得把模型推测当成用户事实。

### Persistence

通过仓储接口保存设置、提醒历史、对话、日记、记忆和关系状态。具体引擎待技术选型后确定，业务层不依赖引擎细节。

### Privacy & Permissions

横切所有分层：权限解释、同意状态、上传前脱敏、禁用范围、数据导出和一键删除。任何跨越本地信任边界的数据都必须通过该层的策略检查。

## 依赖规则

- UI 依赖应用层接口，不直接依赖存储和 LLM SDK。
- 业务规则依赖领域模型和抽象端口，不依赖操作系统或 UI 框架。
- 系统感知、存储、LLM 和通知均作为可替换适配器。
- 平台适配器不直接调用 Care Engine，也不根据系统事件自行显示 UI。
- 主动行为必须经过 Orchestrator 的冲突检查和最终抑制。

## 关键数据流

### 用户主动对话

`UI 事件 -> Orchestrator -> 隐私策略 -> 记忆检索 -> LLM Gateway -> 回复 -> 表现层`

用户主动消息的优先级高于预设提醒。对话与记忆写入是两个独立决策。

### 主动关怀

`调度触发 -> 上下文快照 -> Care Engine -> 候选行为 -> Orchestrator 抑制/排序 -> UI`

产生候选行为不等于必然展示。勿扰、全屏、会议、近期互动和忽略历史都可以使其转为 `quiet`。

### 休眠与唤醒

`系统休眠 -> 暂停动画/感知/调度 -> 系统唤醒 -> 刷新时间和能力 -> 丢弃过期候选 -> 保守冷却`

唤醒不是“补发所有错过任务”的触发点。详见 [桌面应用生命周期](docs/design-docs/application-lifecycle.md)。

## 非功能要求

- **性能**：隐藏、休眠或安静时停止满帧率动画与高频轮询；LLM 和存储不阻塞 UI。
- **可靠性**：单实例，启动、时区、唤醒和升级不产生提醒风暴。
- **安全**：使用操作系统安全存储，签名应用与更新，默认不要求管理员权限。
- **可维护性**：共享核心使用单元测试，平台适配器使用统一契约测试。
- **兼容性**：承诺的系统版本、CPU 架构与分发渠道必须有真实设备验证。

## 待决策项

- 桌面技术栈：当前建议 Flutter Desktop，待原型验证后接受 [ADR-0001](docs/adr/0001-desktop-technology-stack.md)。
- 首发系统版本、macOS Intel、Windows 10 和 ARM64 支持范围。
- 本地数据库、加密方式和密钥管理。
- LLM 提供商、本地模型能力与离线降级策略。
- 多设备同步是否进入 MVP。
- 具体数据保留周期与默认值。
