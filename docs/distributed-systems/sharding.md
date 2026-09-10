---
title: Sharding
description: Partition keys, routing, hotspots и online resharding.
tags: [distributed-systems, sharding]
updated: 2026-09-10
---

# Sharding

Sharding делит dataset между nodes, чтобы storage/write throughput не ограничивались одной машиной. Цена — distributed queries, cross-shard invariants, resharding и новый routing layer.

## Стратегии

- Hash sharding равномерно распределяет случайные keys, но плохо поддерживает range scan и меняет много mappings при простом modulo.
- Range sharding сохраняет locality/ranges, но монотонный key создаёт write hotspot на последнем range.
- Directory-based routing хранит явную map key/range → shard и гибко перемещает данные, но metadata service становится critical control plane.
- Geo/tenant sharding соответствует ownership/compliance, но load между tenants/regions неравномерен.

Partition key должен присутствовать в frequent queries, иметь достаточную cardinality и распределять bytes/QPS, а не только row count. Один celebrity tenant/key способен перегрузить shard при формально равномерном количестве keys.

## Cross-shard cost

Scatter-gather отправляет запрос всем shards: tail latency равна медленной стороне, а fan-out умножает traffic. Global secondary index сам становится distributed replicated system. Unique constraint, foreign key, join и transaction проще, когда связанные данные colocated.

Не выдавайте globally unique auto-increment с каждого shard без схемы. UUID, Snowflake-like ID или выделитель диапазонов имеют разные ordering/coordination trade-offs.

## Resharding

Online move требует согласованного protocol:

1. зафиксировать source/target и movement epoch;
2. скопировать snapshot;
3. догнать concurrent writes через log/dual routing;
4. атомарно переключить routing metadata;
5. выдержать старые clients/requests;
6. проверить и удалить source после safety window.

Наивный dual write создаёт divergence. Routing responses должны содержать version/redirect, а operations быть idempotent. Capacity держит headroom на потерю shard и migration traffic.

## Источники

- [Amazon Dynamo paper](https://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf)
- [Spanner paper](https://research.google/pubs/spanner-googles-globally-distributed-database/)
