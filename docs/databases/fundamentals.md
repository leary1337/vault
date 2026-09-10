---
title: Основы баз данных
description: Модели данных, constraints, transactions, indexes и выбор storage.
tags: [databases, fundamentals]
created: 2024-07-31
updated: 2026-09-10
---

# Основы баз данных

Database хранит state по определённой data model и предоставляет операции с конкретными consistency, durability и query guarantees. «SQL/NoSQL» недостаточно для выбора: сначала определите access patterns, invariants, scale, failure model и operations.

## Модели и workloads

- relational model: tables/relations, declarative queries, constraints и joins;
- key-value: lookup/update по key с ограниченной query model;
- document: aggregate-shaped records и secondary indexes по поддерживаемым paths;
- graph: vertices/edges и traversal как основной access pattern;
- columnar analytical storage: scan/aggregation большого числа rows по части columns;
- time-series/search/vector engines: специализированные indexing/query semantics.

Один продукт может сочетать engines, но каждое новое хранилище добавляет replication, backup, security, consistency и on-call cost. Начинайте с минимального набора, который выполняет требования.

## Invariants и constraints

Schema описывает допустимое состояние: types, `NOT NULL`, unique/check/foreign-key constraints. Application validation улучшает error UX, но concurrent correctness обычно требует authoritative constraint или atomic conditional update.

Normalization уменьшает update anomalies; denormalization/read model ускоряет конкретные reads ценой duplication и synchronization. Укажите owner/source of truth и reconciliation, а не просто «eventual consistency».

## Transactions

ACID раскрывается только вместе с engine/config/failure boundary:

- Atomicity: изменения transaction commit-ятся как единица или abort-ятся;
- Consistency: если transaction и constraints корректны, commit сохраняет заданные invariants;
- Isolation: observable interleavings ограничены выбранным isolation level, не обязательно равны serial execution;
- Durability: acknowledged commit переживает заявленные failures при конкретных WAL/replication/storage settings.

Eventual consistency означает convergence replicas при прекращении новых updates и выполнении protocol assumptions; это не обещание deadline или availability при любых faults. BASE — исторический informal slogan, не точная альтернатива ACID.

## Index и query plan

Index ускоряет поддерживаемые predicates/order, но занимает space, добавляет write/maintenance cost и не гарантирует выбор planner-ом. Проверяйте representative plans/data distribution. N+1, unbounded result и offset pagination часто остаются application problems.

## Scaling и resilience

До sharding используйте query/index/schema improvements, caching, batching, connection bounds и vertical/read scaling, если они удовлетворяют SLO. Replication может повышать read capacity/availability, но создаёт lag/failover/conflict semantics. Sharding требует routing key, resharding, cross-shard operations и hotspot plan.

Backup не равен recovery: задайте RPO/RTO, храните independent copies и регулярно восстанавливайте. Наблюдайте query latency, locks, pool waits, CPU/I/O, storage/WAL, replication lag и maintenance debt.

Продолжение: [PostgreSQL](postgresql/README.md), [Redis](redis/README.md), [consistency models](../distributed-systems/consistency-models.md) и [CAP/PACELC](../distributed-systems/cap-and-pacelc.md).
