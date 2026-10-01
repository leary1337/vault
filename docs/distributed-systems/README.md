---
title: Распределённые системы
description: Consistency, replication, sharding, consensus и failure handling.
tags: [distributed-systems]
updated: 2026-09-10
---

# Распределённые системы

Распределённая система состоит из компонентов, которые обмениваются сообщениями и могут отказывать независимо. Главная сложность — отличить медленный узел от потерянного, сохранить инварианты при частичной связи и восстановиться без скрытых duplicates/split brain.

Каждая guarantee имеет scope: один key или много, одна session или все clients, normal operation или partition, acknowledged write или eventual convergence. Формулируйте её вместе с failure assumptions.


## Темы

- [CAP и PACELC](cap-and-pacelc.md)
- [Consensus](consensus.md)
- [Consistent hashing](consistent-hashing.md)
- [Leader election](leader-election.md)
- [Quorums](quorums.md)
- [Sharding](sharding.md)
- [Идемпотентность](idempotency.md)
- [Модели отказов](failure-models.md)
- [Модели согласованности](consistency-models.md)
- [Распределённые транзакции](distributed-transactions.md)
- [Репликация](replication.md)
- [Часы и порядок событий](clocks-and-ordering.md)

## Источники

- [Designing Data-Intensive Applications — references](https://dataintensive.net/)
- [Jepsen consistency models](https://jepsen.io/consistency)
