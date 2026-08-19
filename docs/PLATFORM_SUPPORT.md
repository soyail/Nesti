# 平台支持策略

## 文档状态

- 状态：Proposed
- 目标：定义 Nesti 在 macOS 和 Windows 上的首发范围、能力差异与降级原则

## 建议首发范围

| 平台 | 建议首发 | 后续评估 |
| --- | --- | --- |
| macOS | 最新主要版本及前一个主要版本；Apple Silicon | Intel Mac，视构建、签名和测试成本决定 |
| Windows | Windows 11 x64 | Windows 10、Windows on ARM |

正式承诺前，必须在真实设备上验证透明窗口、点击穿透、缩放、托盘、唤醒和签名安装。

## 能力矩阵

| 能力 | macOS | Windows | 降级策略 |
| --- | --- | --- | --- |
| 透明置顶窗口 | 支持，需验证 Spaces/全屏 | 支持，需验证虚拟桌面/全屏 | 改为普通可移动窗口 |
| 点击穿透 | 需原生窗口能力 | 需 Win32 窗口能力 | 限制宠物交互区域，不阻挡桌面 |
| 托盘/菜单栏 | 菜单栏 | 系统托盘 | 保留主窗口设置和退出入口 |
| 全局快捷键 | 系统注册 | 系统注册 | 禁用快捷键，不影响核心交互 |
| 系统通知 | UserNotifications | Windows App Notifications | 仅使用应用内可忽略气泡 |
| 开机启动 | Login Item | Startup Task/启动项 | 展示手动开启说明 |
| 安全存储 | Keychain | DPAPI/Credential Manager | 敏感功能不可用，不回退到明文 |
| 粗粒度空闲状态 | 系统 API | `GetLastInputInfo` 等系统 API | 只使用时间和用户明示状态 |
| 前台应用/全屏 | 可能涉及额外权限 | Win32 API，版本行为需验证 | 不请求高敏感权限，主动行为更保守 |
| 系统勿扰 | 公开能力可能受限 | Windows 版本差异 | 使用 Nesti 内部勿扰和全屏信号 |

## 兼容性原则

- 平台适配器必须显式报告 `supported`、`unsupported`、`permissionRequired`、`permissionDenied` 或 `temporarilyUnavailable`。
- 未知平台状态不得被当作“用户正在休息”或“可以打扰”。
- 不要为了实现两端完全一致而申请更高权限；允许能力不同，但保持用户承诺一致。
- 未列入支持矩阵的平台不得出现在市场文案或发布页中。

## 待决策项

- macOS Intel 和 Windows ARM64 是否进入首发。
- Windows 10 是否需要支持。
- 首发是否支持 Mac App Store 或 Microsoft Store。
- 用于系统感知的最高可接受权限级别。
