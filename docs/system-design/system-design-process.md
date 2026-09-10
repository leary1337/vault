---
title: Процесс System Design
description: Пятнадцать шагов от requirements до explicit trade-offs.
tags: [system-design, architecture]
updated: 2026-09-10
---

# Процесс System Design

Framework полезен для нового сервиса, RFC, capacity review и интервью. Шаги итеративны: новая оценка bottleneck может изменить API или data model.

1. Functional requirements — actors, use cases, state transitions, edge cases и out of scope.
2. Non-functional requirements — измеримые SLO latency/availability, durability, consistency, privacy, cost, RPO/RTO.
3. Rough capacity estimation — average/peak QPS, payload, storage growth, bandwidth, concurrency и skew.
4. API — contracts, idempotency, pagination, errors, versioning и authorization boundary.
5. Data model — source of truth, keys, invariants, indexes, retention и migrations.
6. High-level architecture — минимальные components и ownership; синхронные/асинхронные boundaries.
7. Write path — validation → authoritative commit → events/cache/index; atomicity и duplicate handling.
8. Read path — routing, cache, fan-out, consistency и fallback.
9. Bottlenecks — hottest key/partition, shared pool, database, network, queue, control plane.
10. Scaling — vertical/horizontal, replication, sharding, batching, caching и rebalancing cost.
11. Consistency — model и scope, stale-read budget, conflict resolution и cross-resource invariants.
12. Failure scenarios — timeout ambiguity, dependency/zone loss, overload, split brain, data corruption, recovery.
13. Observability — SLI/SLO, golden signals, tracing/log fields, audit и actionable alerts.
14. Security — identity, authorization, encryption, secrets, abuse limits, data lifecycle и threat model.
15. Trade-offs — alternatives, rejected options, assumptions, risks, cost и trigger для пересмотра.

## Проверка путей

Для критичного use case нарисуйте отдельно write и read path, называя каждый durable/acknowledgement point. На каждой network boundary спросите: что будет при timeout, повторе, старом response и частичной записи?

## Deliverables

Хороший design document содержит decision log, schema/API examples, capacity table, failure matrix и rollout/rollback plan. Unknowns превращаются в spike/load test, а не маскируются точными на вид числами.

## Связанные темы

- [Requirements](fundamentals/requirements.md)
- [Capacity estimation](fundamentals/capacity-estimation.md)
- [Failure handling](fundamentals/failure-handling.md)
