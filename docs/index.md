# 栖伴文档中心

本目录是产品、设计、架构和工程决策的单一入口。文档中应区分三类信息：

- **已确认**：已经成为产品或工程约束。
- **建议**：当前推荐方案，实施前仍可调整。
- **待决策**：缺少证据或需要产品/技术确认。

## 核心文档

- [产品判断](PRODUCT_SENSE.md)
- [架构](../ARCHITECTURE.md)
- [交互与视觉原则](DESIGN.md)
- [前端与桌面表现](FRONTEND.md)
- [平台支持策略](PLATFORM_SUPPORT.md)
- [构建与发布](BUILD_AND_RELEASE.md)
- [跨平台测试矩阵](TEST_MATRIX.md)
- [安全与隐私](SECURITY.md)
- [可靠性](RELIABILITY.md)
- [质量评分](QUALITY_SCORE.md)
- [计划管理](PLANS.md)

## 专题目录

- [设计文档](design-docs/index.md)：跨模块、高影响决策。
- [架构决策记录](adr/README.md)：技术选型、存储和分发等长期决策。
- [产品规格](product-specs/index.md)：面向用户的行为与验收标准。
- [执行计划](exec-plans/README.md)：正在进行和已完成的实施记录。
- [生成文档](generated/README.md)：由工具生成、不应手工维护的资料。
- [外部参考](references/README.md)：第三方规范的索引与摘要。

## 维护规则

1. 代码与文档冲突时，先确认文档是目标设计还是现状记录。
2. 改变架构、数据、权限、隐私或交互流程前，先更新设计文档并完成评审。
3. 产品规格描述“用户得到什么”，执行计划描述“如何交付”。
4. 完成的计划移入 `exec-plans/completed/`，不要删除其决策背景。
