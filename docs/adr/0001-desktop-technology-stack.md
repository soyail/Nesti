# ADR-0001: 桌面客户端技术栈

## Status

Proposed

## Context

Nesti 需要在 macOS 和 Windows 上提供透明置顶窗口、动画宠物、气泡、托盘/菜单栏、系统感知与签名分发。作为长期驻留应用，它还需要可控的 CPU、内存和电量成本。

## Decision

使用 Flutter Desktop 建立跨平台原型，以纯 Dart 实现平台无关的领域和应用逻辑，桌面能力通过小粒度平台端口与原生适配器实现。

本决定只在 [技术原型验收](../design-docs/desktop-technology-selection.md#原型验收) 通过后转为 Accepted。

## Consequences

### Positive

- 共享 UI 与动画实现，降低两套客户端的重复成本。
- 领域逻辑可使用纯 Dart 测试，不依赖 UI 和操作系统。
- 适合宠物动画、气泡和设置界面的统一表现。

### Negative

- 点击穿透、窗口层级、托盘、自启动和感知仍需要原生适配。
- 依赖的桌面插件可能维护不足或无法通过发布验证。
- 团队需要维护 Dart/Flutter 与部分 Swift/Objective-C、C++/C# 边界。

### Neutral

- 技术原型是转为 Accepted 前的强制门禁。

## Alternatives Considered

- **Tauri**：运行时较轻，但引入 Web/Rust 双技术栈，特殊窗口能力仍需平台代码。
- **Electron**：生态成熟，但长期驻留资源和产物体积代价较高。
- **完全原生**：平台能力最强，但两套 UI 和更高长期成本不符合 MVP 约束。

## References

- [桌面技术选型](../design-docs/desktop-technology-selection.md)
- [平台能力抽象](../design-docs/platform-capability-abstraction.md)
