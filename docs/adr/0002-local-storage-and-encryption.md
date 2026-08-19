# ADR-0002: 本地存储与加密边界

## Status

Proposed

## Context

Nesti 将保存设置、提醒历史、对话、日记和长期记忆。其中 API Key、token 和用户内容属于敏感数据。macOS 和 Windows 的安全存储与数据目录不同，业务层不应依赖绝对路径或平台密钥 API。

## Decision

- 通过 `FileSystemPaths`、仓储接口和 `SecureStorage` 隔离平台差异。
- API Key、token 和加密密钥只存入 macOS Keychain 或 Windows DPAPI/Credential Manager 能力，不存入普通配置或日志。
- 对话、日记和长期记忆优先使用本地数据库；引擎与字段加密方案在原型和威胁模型完成后确定。
- schema 必须版本化，迁移、导出、分类删除和完整删除是存储接口的一等能力。
- `SecureStorage` 不可用时，相关敏感功能停用，不回退到明文。

## Consequences

### Positive

- 密钥与普通业务数据分离，降低误导出和日志泄露风险。
- 数据路径、密钥系统和数据库引擎可替换。
- 导出、删除和迁移可以用统一契约测试。

### Negative

- 跨平台密钥备份、系统重装和设备迁移会更复杂。
- 数据库加密、密钥轮换与迁移失败需要单独设计和测试。

### Neutral

- 本 ADR 不选定具体数据库，避免在数据模型之前过早锁定引擎。

## Alternatives Considered

- **单一 JSON/配置文件**：实现快，但难以支持事务、迁移、分类删除和安全边界。
- **所有数据放入系统密钥库**：密钥库不适合大量对话和日记数据。
- **优先云存储**：会改变本地优先的隐私承诺，不进入 MVP。

## References

- [安全与隐私](../SECURITY.md)
- [平台能力抽象](../design-docs/platform-capability-abstraction.md)
