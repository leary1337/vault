---
title: Распределённые системы
description: Consistency, replication, sharding, consensus и failure handling.
tags: [distributed-systems]
updated: 2026-09-10
---

# Распределённые системы

Распределённая система состоит из компонентов, которые обмениваются сообщениями и могут отказывать независимо. Главная сложность — отличить медленный узел от потерянного, сохранить инварианты при частичной связи и восстановиться без скрытых duplicates/split brain.

Рекомендуемый порядок:

1. [failure models](failure-models.md), [clocks](clocks-and-ordering.md) и [consistency](consistency-models.md);
2. [replication](replication.md), [quorums](quorums.md) и [CAP/PACELC](cap-and-pacelc.md);
3. [consensus](consensus.md) и [leader election](leader-election.md);
4. [sharding](sharding.md), [consistent hashing](consistent-hashing.md), transactions и idempotency.

Каждая guarantee имеет scope: один key или много, одна session или все clients, normal operation или partition, acknowledged write или eventual convergence. Формулируйте её вместе с failure assumptions.

## Источники

- [Designing Data-Intensive Applications — references](https://dataintensive.net/)
- [Jepsen consistency models](https://jepsen.io/consistency)
