# 平台能力抽象

## 状态

Proposed。

## 背景

macOS 和 Windows 在窗口、权限、勿扰、安全存储和应用生命周期方面存在差异。如果 UI 或业务逻辑直接调用插件/系统 API，会导致决策不可测试、平台分支扩散和隐私行为不一致。

## 决策

在领域/应用层与操作系统之间建立 Platform Capability API，由 macOS 和 Windows 适配器实现。

```text
Pet UI / Settings / Conversation
              │
     Companion Orchestrator
              │
     Platform Capability API
       │                   │
macOS Adapters       Windows Adapters
```

## 建议端口

- `WindowController`：窗口位置、透明、置顶、点击穿透和多显示器。
- `TrayController`：菜单栏/托盘、显示、隐藏和退出。
- `NotificationService`：系统通知及授权状态。
- `GlobalShortcutService`：快捷键注册、冲突和解除。
- `AutoStartService`：登录后启动。
- `DoNotDisturbProvider`：能力可用时返回粗粒度勿扰状态。
- `IdleStateProvider`：粗粒度活跃/空闲状态。
- `ForegroundContextProvider`：前台应用分类，不默认保存标题或内容。
- `FullscreenDetector`：全屏/演示可能性。
- `SecureStorage`：密钥、token 与敏感小数据。
- `FileSystemPaths`：平台标准数据、缓存、日志与临时目录。
- `AutoUpdateService`：检查、下载、校验、安装与回滚状态。
- `PowerStateProvider`：休眠、唤醒、电池与节能模式。

## 统一能力结果

能力不应只返回布尔值。建议使用：

```text
supported(value)
unsupported(reason)
permissionRequired(permission)
permissionDenied(permission)
temporarilyUnavailable(reason, retryHint?)
```

这些结果由 Orchestrator 转换为功能降级，UI 不得根据插件异常自行决定是否显示提醒。

## 安全边界

- 适配器只返回业务所需的最小数据。
- 感知返回值必须先通过隐私策略，再进入 Orchestrator 或日志。
- 原生异常不携带未脱敏窗口标题、文件路径或用户内容。
- `SecureStorage` 不可用时，敏感数据不得降级为明文文件。

## 契约测试

每个平台适配器必须运行同一组契约用例：

- 未授权、已拒绝与运行中撤销。
- 系统能力不支持和暂时不可用。
- 重复注册、重复释放和进程退出时资源清理。
- 系统事件连发时的幂等与顺序。
- 返回数据不超出契约中的隐私范围。

## 备选方案

- **UI 直接调用桌面插件**：初期快，但业务决策和平台差异会扩散，不采用。
- **一个全能 PlatformService**：接口少，但难以按权限、生命周期和测试范围隔离，不采用。
- **分能力小端口**：适配器数量更多，但边界和故障更容易控制，采用。
