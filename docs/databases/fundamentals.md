---
title: Основы баз данных
description: Модели данных, constraints, transactions, indexes и выбор storage.
tags: [databases, fundamentals]
created: 2024-07-31
updated: 2026-10-06
---

# Основы баз данных

База данных хранит данные и помогает нескольким клиентам менять их по общим правилам. Для объявления важно не только быстрое чтение: цена не отрицательная, владелец существует, повтор запроса не создаёт дубль.

Database хранит state по определённой data model и предоставляет операции с конкретными consistency, durability и query guarantees. «SQL/NoSQL» недостаточно для выбора: сначала определите access patterns, invariants, scale, failure model и operations.

## Модели и нагрузки

- relational model: tables/relations, declarative queries, constraints и joins;
- key-value: lookup/update по key с ограниченной query model;
- document: aggregate-shaped records и secondary indexes по поддерживаемым paths;
- graph: vertices/edges и traversal как основной access pattern;
- columnar analytical storage: scan/aggregation большого числа rows по части columns;
- time-series/search/vector engines: специализированные indexing/query semantics.

Один продукт может сочетать engines, но каждое новое хранилище добавляет replication, backup, security, consistency и on-call cost. Начинайте с минимального набора, который выполняет требования.

## Инварианты и ограничения

Schema описывает допустимое состояние: types, `NOT NULL`, unique/check/foreign-key constraints. Application validation улучшает error UX, но concurrent correctness обычно требует authoritative constraint или atomic conditional update.

Normalization уменьшает update anomalies; denormalization/read model ускоряет конкретные reads ценой duplication и synchronization. Укажите owner/source of truth и reconciliation, а не просто «eventual consistency».

## Транзакции

ACID раскрывается только вместе с engine/config/failure boundary:

- Atomicity: изменения transaction commit-ятся как единица или abort-ятся;
- Consistency: если transaction и constraints корректны, commit сохраняет заданные invariants;
- Isolation: observable interleavings ограничены выбранным isolation level, не обязательно равны serial execution;
- Durability: acknowledged commit переживает заявленные failures при конкретных WAL/replication/storage settings.

Eventual consistency означает convergence replicas при прекращении новых updates и выполнении protocol assumptions; это не обещание deadline или availability при любых faults. BASE — исторический informal slogan, не точная альтернатива ACID.

## Индекс и план запроса

Index ускоряет поддерживаемые predicates/order, но занимает space, добавляет write/maintenance cost и не гарантирует выбор planner-ом. Проверяйте representative plans/data distribution. N+1, unbounded result и offset pagination часто остаются application problems.

## Масштабирование и восстановление

До sharding используйте query/index/schema improvements, caching, batching, connection bounds и vertical/read scaling, если они удовлетворяют SLO. Replication может повышать read capacity/availability, но создаёт lag/failover/conflict semantics. Sharding требует routing key, resharding, cross-shard operations и hotspot plan.

Backup не равен recovery: задайте RPO/RTO, храните independent copies и регулярно восстанавливайте. Наблюдайте query latency, locks, pool waits, CPU/I/O, storage/WAL, replication lag и maintenance debt.

Продолжение: [PostgreSQL](postgresql/README.md), [Redis](redis/README.md), [consistency models](../distributed-systems/consistency-models.md) и [CAP/PACELC](../distributed-systems/cap-and-pacelc.md).

## Пример: правило при записи

```sql
CREATE TABLE advertisements (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    seller_id bigint NOT NULL,
    external_id text NOT NULL,
    price numeric(12,2) NOT NULL CHECK (price >= 0),
    UNIQUE (seller_id, external_id)
);
INSERT INTO advertisements(seller_id,external_id,price)
VALUES (7,'request-123',1500)
ON CONFLICT (seller_id,external_id) DO NOTHING RETURNING id;
```

Первый запрос добавит строку; повтор ничего не добавит. Два одновременных SELECT проверки отсутствия могут оба пройти, а UNIQUE согласует конфликт при записи. Чтобы повтор возвращал прежний результат, приложение читает существующую строку и проверяет совпадение параметров.

Для денег используйте целые минимальные единицы или numeric выбранной точности. CHECK отклоняет false; NULL требует отдельного NOT NULL. Атомарная транзакция способна атомарно записать неправильную цену: ACID не определяет бизнес-правило. Для каждого хранилища называйте источник достоверных данных, допустимую потерю после аварии (RPO), время восстановления (RTO) и проверку восстановления.

## Источники

- [Constraints PostgreSQL 18](https://www.postgresql.org/docs/18/ddl-constraints.html)

## Проверь себя

1. **Почему SELECT перед INSERT не заменяет UNIQUE?**

   <details>
   <summary>Ответ</summary>

   Два клиента могут одновременно увидеть отсутствие; ограничение проверяется при записи.

   </details>

2. **Гарантирует ли ACID правильный баланс?**

   <details>
   <summary>Ответ</summary>

   Только вместе с правильной логикой, ограничениями и изоляцией.

   </details>
