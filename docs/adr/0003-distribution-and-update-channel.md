# ADR-0003: 首发分发与更新渠道

## Status

Proposed

## Context

Nesti 需要快速验证桌面宠物的窗口、感知和更新能力。Mac App Store 与 Microsoft Store 可提供分发信任，但审核、沙箱、权限和更新规则可能限制桌面集成。官网直接分发提供更多控制，但团队必须承担签名、公证、更新安全和下载信任成本。

## Decision

首发建议使用官网直接分发：

- macOS：Developer ID 签名、Hardened Runtime、Notarization 的 DMG/PKG。
- Windows：Authenticode 签名的 EXE/MSIX 安装包。
- 使用自有签名更新元数据和产物的安全更新渠道。
- 应用商店作为后续独立评估，不在 MVP 同时维护多渠道。

在实现更新安全原型和签名发布演练前，状态保持 Proposed。

## Consequences

### Positive

- 对窗口、启动项、感知和更新时机有更高控制。
- MVP 无需同时满足两个应用商店的审核和分发差异。
- 可以统一实现低干扰更新时机。

### Negative

- 需要建立签名密钥保管、公证、产物托管和更新安全能力。
- Windows SmartScreen 信誉和用户下载信任需要时间建立。
- 商店用户暂时无法通过平台商店获取应用。

### Neutral

- 如后续进入应用商店，需要新 ADR 记录沙箱、权限和更新差异。

## Alternatives Considered

- **首发只上应用商店**：分发信任更高，但可能过早限制桌面能力。
- **同时官网与商店分发**：覆盖更广，但 MVP 打包、测试、更新和支持成本过高。
- **不提供自动更新**：简单，但高危安全修复和数据迁移难以及时交付。

## References

- [构建与发布](../BUILD_AND_RELEASE.md)
- [安装、启动与更新规格](../product-specs/installation-and-updates.md)
