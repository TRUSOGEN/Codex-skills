---
name: agent-progress-board
description: 使用当并行派发 2 个及以上子代理，或用户要求查看后台代理的进度、状态、结果时
---

# Agent 进度看板

并行派发子代理时，输出流式纯文本看板，让用户实时看到每个代理在干什么、何时完成。无图标、无表格、极小占用。

## 规则

- 禁止使用 emoji / 图标 / 装饰字符，只用纯文本
- 派发前打印一次看板；每个代理完成时追加一行；全部完成时追加一行摘要
- 每行从短，只写结论，不贴代理完整记录
- 单个代理无需看板，直接报告结果即可

## 格式

派发时（只打印一次）：

    agents 3
      - sol   核对 DeepSeek 价格  [running]
      - ex    扫描代码结构        [running]
      - plan  设计实现方案        [waiting]

每个代理完成（流式追加一行）：

    sol done: 价格已核对

全部完成（最后一行）：

    agents 3/3 done | sol: 价格已核对; ex: 扫描完成; plan: 方案已出

## 状态词

[running] [waiting] [done] [failed]（failed 附一行原因）
