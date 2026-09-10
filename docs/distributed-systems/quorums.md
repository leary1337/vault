---
title: Quorums
description: Majority, read/write intersection и ограничения формулы N/R/W.
tags: [distributed-systems, consensus]
updated: 2026-09-10
---

# Quorums

Quorum — достаточное подмножество участников для решения или операции. Majority quorum пересекается с любым другим majority, поэтому два disjoint большинства не могут одновременно выбрать разных leaders в одной configuration.

Для N replicas leaderless storage часто приводят условия:

```text
W + R > N
W > N / 2
```

Первое даёт пересечение read/write sets, второе — write/write sets. Но это не готовое доказательство strong consistency.

## Почему формулы недостаточно

- sloppy quorum может писать на временные nodes вне home replica set;
- concurrent writes требуют version/conflict resolution;
- read может получить stale responses и выбрать неправильную version;
- clock-based last-write-wins чувствителен к skew;
- membership/reconfiguration меняет множества;
- acknowledgement до durable storage ослабляет crash guarantees;
- repair/garbage collection может удалить нужную version.

Linearizable register требует protocol, который корректно определяет последнюю committed version и обрабатывает concurrency, а не только считает ответы.

## Consensus quorum

В Raft/Paxos quorum участвует в выборе leader и commit replicated log. Узел с устаревшим log не должен победить только потому, что собрал голоса; election rules учитывают log freshness. Joint consensus/совместимая reconfiguration обеспечивает пересечение старой и новой configurations.

## Operational implications

Quorum из 3 переносит один отказ, из 5 — два, если failures независимы. Добавление even voter обычно не повышает tolerated failures: 4 всё ещё требует 3 и переносит один. География voters задаёт minimum write/election latency и поведение при потере region.

Не путайте quorum настройки разных слоёв: Kafka controller quorum, topic ISR/`min.insync.replicas` и application acknowledgement решают разные задачи.

## Источники

- [Raft paper](https://raft.github.io/raft.pdf)
- [Amazon Dynamo paper](https://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf)
