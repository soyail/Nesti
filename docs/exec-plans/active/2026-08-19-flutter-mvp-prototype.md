# Flutter Desktop MVP 原型实施计划

- 状态：Implemented MVP / Active for follow-up validation
- 负责人：Codex
- 创建日期：2026-08-19
- 相关规格/设计文档：
  - `ARCHITECTURE.md`
  - `docs/design-docs/desktop-technology-selection.md`
  - `docs/design-docs/platform-capability-abstraction.md`
  - `docs/design-docs/proactive-care-engine.md`
  - `docs/product-specs/new-user-onboarding.md`
  - `docs/product-specs/proactive-care.md`
  - `docs/product-specs/privacy-controls.md`

## 目标

交付一个可在 macOS 运行、保留 Windows 工程结构的 Flutter Desktop MVP 原型，用于验证 Nesti 的分层架构、核心主动关怀规则和低干扰桌面交互。

## 非目标

- 不在本阶段接入真实 LLM 提供商或保存 API Key。
- 不申请屏幕录制、辅助功能、前台应用读取等敏感权限。
- 不确定最终数据库、字段加密或云同步方案。
- 不实现签名、公证、自动更新和正式安装包。
- 不把 ADR-0001 标记为 `Accepted`；跨平台窗口与发布验收尚未完成。

## 现状与约束

- 仓库已包含 Flutter Desktop MVP 原型代码、macOS/Windows 工程结构和测试。
- Flutter SDK 位于 `/Users/peiyang/projects/flutter`。
- 首阶段采用纯 Dart 领域与应用逻辑，Flutter Widget 只负责表现和派发用户意图。
- 平台能力通过细粒度端口暴露，原型使用内存或安全的本地模拟实现。
- 感知状态保持粗粒度；不读取屏幕正文、键入内容、剪贴板或私人通信。
- 主动提醒必须支持忽略、稍后提醒、完成和关闭同类提醒，并遵守冷却、勿扰与拒绝退避。

## 方案

采用单一 Flutter 应用包，内部按职责组织：

```text
lib/
  core/             # 时钟、结果类型和通用值对象
  domain/           # 主动行为、设置、上下文、互动记录
  application/      # Care Engine、Companion Orchestrator、表现状态
  ports/            # 存储、LLM、平台能力的小粒度接口
  adapters/         # 内存仓储、离线 LLM、原型平台适配器
  presentation/     # 页面、组件、主题和状态控制器
```

界面采用“柔和纸感工作角落”的视觉方向：暖米色与苔藓绿为主，宠物使用轻量矢量绘制，强调安静呼吸、可忽略气泡和明确控制，不依赖网络字体或位图资源。

## 备选方案

1. **直接构建完整产品**：会提前固化数据库、权限、LLM 和发布渠道，当前证据不足，暂不采用。
2. **只实现纯 Dart 关怀引擎**：风险最低，但无法验证桌面体验和架构到表现层的数据流，覆盖不足。
3. **Flutter MVP 原型（采用）**：同时验证核心规则和界面边界，并将高风险平台权限、密钥与发布能力留到后续独立设计。

## 执行步骤

### 1. 初始化工程与架构边界

- [x] 使用 Flutter 创建 macOS/Windows 桌面工程。
- [x] 建立领域、应用、端口、适配器和表现层目录。
- [x] 配置 lint，并保持依赖最小化。
- 验证：`flutter analyze` 能加载工程；默认测试可运行。

### 2. 主动关怀领域模型

- [x] 先编写候选行为、上下文快照、用户设置和互动历史测试。
- [x] 实现候选行为必需字段、过期时间、去重键和策略版本。
- [x] 实现可注入时钟和确定性的本地日期边界。
- 验证：模型不可变，测试不依赖真实时间。

### 3. Proactive Care Engine

- [x] 先编写勿扰、静默时段、会议/全屏、类型关闭和过期抑制测试。
- [x] 编写喝水/活动冷却、每日问候、防重、拒绝退避和连续忽略测试。
- [x] 实现生成、硬抑制、频率控制、上下文评估、排序和 `quiet` 结果。
- 验证：相同输入产生相同结果；任一评估最多选择一个可见行为。

### 4. Orchestrator 与原型适配器

- [x] 定义互动记录仓储、设置仓储、LLM Gateway 和平台上下文端口。
- [x] 实现内存仓储、离线陪伴回复和可控上下文适配器。
- [x] 实现用户主动消息优先、提醒操作回传和表现状态转换。
- 验证：用户对话期间不会插入无关提醒；操作结果会影响下一次决策。

### 5. Flutter 表现层

- [x] 实现首次引导：定位承诺、称呼/动效、提醒偏好、隐私控制概览。
- [x] 实现宠物主舞台、安静呼吸动画、主动气泡和快速聊天入口。
- [x] 实现对话卡片、提醒的完成/延后/关闭操作和离线状态。
- [x] 实现设置面板：勿扰、暂停提醒、暂停感知、分类提醒和减少动效。
- [x] 为关键控件添加语义、键盘焦点和足够点击区域。
- 验证：Widget 测试覆盖引导、提醒操作、暂停模式和界面状态映射。

### 6. 桌面原型能力

- [x] 设置 macOS/Windows 桌面目标和安全默认窗口尺寸。
- [x] 封装窗口能力端口；不让业务层依赖具体插件。
- [ ] 如无需新增依赖即可实现，则验证透明背景；否则记录为下一阶段原型项。
- 验证：macOS Debug 应用已完成构建验证；GUI 启动、交互、退出和视觉截图验收尚未执行。Windows 工程结构已保留，未在 Windows 设备构建验证。

### 7. 完整验证和文档

- [x] 运行 Dart 格式化。
- [x] 运行 Flutter 分析、单元测试和 Widget 测试。
- [ ] 启动 macOS 应用并检查布局、状态和无障碍基础行为。
- [x] 更新 README 的实际运行命令和当前完成范围。
- [x] 记录跨平台窗口、真实权限、存储加密、LLM 和发布的剩余未决项。

## 验证与完成标准

- `flutter analyze` 无错误。
- `flutter test` 全部通过，覆盖关怀引擎关键策略和主要 UI 流程。
- macOS Debug 原型可构建；实际 GUI 启动、完成引导、聊天、查看提醒并完成/延后/关闭仍需人工验收。
- 勿扰、暂停提醒、会议/全屏模拟状态会让主动行为保持安静。
- UI、Care Engine、存储和平台能力之间没有反向依赖或直接耦合。
- 应用不请求敏感权限，不记录或上传对话、桌面内容和密钥。

## 风险、隐私与回滚

- Flutter 桌面窗口透明、点击穿透和托盘能力可能需要第三方插件或原生代码；本阶段先通过端口隔离，未验证能力不作完成声明。
- 原型数据不承诺长期保留，避免在加密方案确定前保存敏感日记、完整对话或 API Key。
- 所有新增代码均位于新建 Flutter 工程和本计划文档中，可按文件级回退，不迁移或覆盖现有用户数据。

## 待决策项

- Flutter 窗口插件与原生适配边界。
- 最终本地数据库、字段加密和密钥轮换方案。
- 首个 LLM Gateway 提供商与离线降级范围。
- 正式宠物动画资产格式、皮肤系统和版权来源。
- Windows 真实设备与签名安装验证安排。

## 进展日志

- 2026-08-19：用户确认以 Flutter Desktop MVP 原型作为第一阶段，并授权按 ADR-0001 建议方向实施。
- 2026-08-20：恢复会话后完成 MVP 工程收尾；`dart format --output=none --set-exit-if-changed lib test` 通过，`flutter analyze` 和 `flutter test` 通过，`flutter build macos --debug` 成功生成 `build/macos/Build/Products/Debug/nesti.app`。

## 最终结果

已交付一个可构建、可测试的 Flutter Desktop MVP 原型：

- 完成 `lib/core`、`lib/domain`、`lib/application`、`lib/ports`、`lib/adapters` 和 `lib/presentation` 分层结构。
- 完成可测试的 Proactive Care Engine，覆盖勿扰、静默时段、会议/全屏、工作状态、每日问候、喝水/活动冷却、拒绝退避、连续忽略、关闭同类提醒和可解释决策。
- 完成 Companion Orchestrator、内存设置与历史仓储、离线 Companion Gateway 和可控上下文适配器。
- 完成 Flutter 表现层，包括首次引导、宠物主舞台、主动提醒气泡、离线聊天、提醒操作和设置控制。
- 完成 macOS/Windows Flutter 工程结构；macOS Debug 构建已验证，Windows 仅保留工程结构。

下一阶段仍需独立设计和验证真实桌面集成能力，包括透明窗口、点击穿透、托盘/菜单栏、全局快捷键、系统通知、权限说明、持久化/加密、真实 LLM Gateway、签名发布和 Windows 设备构建。
