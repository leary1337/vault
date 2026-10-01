---
title: PostgreSQL
description: Архитектура, транзакции, запросы и эксплуатация PostgreSQL.
tags:
  - databases
  - postgresql
updated: 2026-09-10
---

# PostgreSQL

Раздел описывает PostgreSQL 18: семантику запросов, конкурентный доступ и эксплуатацию конкретной СУБД.

Для прикладной работы особенно важны две связки:

- `MVCC → isolation → locks`: объясняет, что увидит запрос и где он будет ждать;
- `statistics → planner → EXPLAIN`: объясняет, почему сервер выбрал конкретный план.

Страницы не заменяют runbook конкретного кластера: параметры, расширения, topology и допустимый RPO/RTO должны быть зафиксированы отдельно.


## Темы

- [Connection pooling](connection-pooling.md)
- [EXPLAIN](explain.md)
- [Joins](joins.md)
- [MVCC](mvcc.md)
- [Query planner](query-planner.md)
- [SQL-задачи](sql-interview-tasks.md)
- [VACUUM и autovacuum](vacuum.md)
- [Write-Ahead Log](wal.md)
- [Архитектура PostgreSQL](architecture.md)
- [Блокировки PostgreSQL](locks.md)
- [Индексы PostgreSQL](indexes.md)
- [Пагинация](pagination.md)
- [Партиционирование](partitioning.md)
- [Репликация PostgreSQL](replication.md)
- [Транзакции](transactions.md)
- [Уровни изоляции PostgreSQL](isolation-levels.md)

## Источники

- [PostgreSQL 18 documentation](https://www.postgresql.org/docs/18/)
- [PostgreSQL versioning policy](https://www.postgresql.org/support/versioning/)
