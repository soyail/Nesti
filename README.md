# 栖伴 Nesti

> 栖于桌边，伴你工作。
> Your little companion through the workday.

栖伴是一只住在桌面上的工作陪伴型数字生命。它通过桌面宠物、LLM 对话、长期记忆、主动关怀和粗粒度工作状态感知，提供低干扰、有温度、可持续的陪伴。

## 当前状态

当前仓库已经包含一个 Flutter Desktop MVP 原型，优先在 macOS 上验证，保留 Windows 工程结构。原型聚焦于 Nesti 的分层架构、低干扰主动关怀规则、首次引导、桌面陪伴主界面、离线聊天和基础设置控制。

当前实现保持隐私优先：

- 不接入真实 LLM，不保存 API Key。
- 使用离线陪伴回复和内存仓储，重启后不保留对话、提醒历史或设置。
- 不默认请求屏幕录制、辅助功能、剪贴板、私人通信或前台应用读取等敏感权限。
- 桌面感知为原型模拟状态，不读取屏幕正文或键入内容。

已验证：

- `flutter analyze` 无问题。
- `flutter test` 全部通过。
- `flutter build macos --debug` 可生成 macOS Debug 应用：`build/macos/Build/Products/Debug/nesti.app`。

仍未实现或未验收：

- 真实透明桌面窗口、点击穿透、托盘/菜单栏、全局快捷键和系统通知。
- 真实系统感知、权限申请说明流和原生窗口插件适配。
- 持久化、本地加密、数据导出/删除和长期记忆。
- 真实 LLM Gateway、脱敏上传策略和密钥管理。
- 签名、公证、自动更新、正式安装包和 Windows 设备构建验证。

## 本地运行

Flutter SDK 当前位于 `/Users/peiyang/projects/flutter`。在仓库根目录运行：

```bash
/Users/peiyang/projects/flutter/bin/flutter pub get
/Users/peiyang/projects/flutter/bin/flutter analyze
/Users/peiyang/projects/flutter/bin/flutter test
/Users/peiyang/projects/flutter/bin/flutter run -d macos
```

如需只验证 macOS Debug 构建：

```bash
/Users/peiyang/projects/flutter/bin/flutter build macos --debug
```

## 文档导航

- [AGENTS.md](AGENTS.md)：产品定位、Agent 行为和开发约束。
- [ARCHITECTURE.md](ARCHITECTURE.md)：系统分层、依赖方向和关键数据流。
- [docs/index.md](docs/index.md)：文档总索引。
- [docs/PRODUCT_SENSE.md](docs/PRODUCT_SENSE.md)：产品判断标准与体验底线。
- [docs/PLATFORM_SUPPORT.md](docs/PLATFORM_SUPPORT.md)：macOS/Windows 支持范围与能力差异。
- [docs/BUILD_AND_RELEASE.md](docs/BUILD_AND_RELEASE.md)：签名、打包、更新和发布门禁。
- [docs/PLANS.md](docs/PLANS.md)：计划的编写、执行和归档规则。

## 贡献约定

开始实现前，请先阅读 `AGENTS.md` 和相关产品规格。任何涉及架构、数据模型、权限、隐私或用户交互流程的变更，都应先提交设计文档或执行计划。
