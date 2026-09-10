---
title: Sharding в System Design
description: Partition key, routing, cross-shard cost и resharding.
tags: [system-design, sharding]
updated: 2026-09-10
---

# Sharding в System Design

Sharding нужен, когда подтверждённый storage/write/working-set bottleneck не помещается на один node и simpler vertical scaling/partitioning исчерпаны.

## Partition key

Хороший key:

- присутствует в частых requests;
- распределяет QPS и bytes, а не только количество rows;
- colocate-ит данные одного transaction/aggregate;
- имеет route без scatter-gather;
- допускает split горячего tenant/key.

Hash даёт равномерность, range — range locality/retention, directory — гибкое placement. Tenant sharding упрощает isolation/migration, но большие tenants требуют отдельной стратегии.

## Цена

Cross-shard join, unique constraint, transaction, secondary index и aggregation становятся distributed workflows. Scatter-gather умножает load и наследует tail самого медленного shard. Global ID должен иметь отдельную scheme.

Online resharding — copy + change capture + versioned routing + cutover + verification; naive dual write расходится. Держите headroom для migration и потери node.

Сначала измерьте hot keys и skew. Иногда достаточно partitioned table, read replica, cache или переноса одного workload. Подробнее: [distributed sharding](../../distributed-systems/sharding.md).
