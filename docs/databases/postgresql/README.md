---
title: PostgreSQL
description: Архитектура, транзакции, запросы и эксплуатация PostgreSQL.
tags:
  - databases
  - postgresql
updated: 2026-09-10
---

# PostgreSQL

Раздел описывает поведение PostgreSQL 18, а не абстрактной SQL-СУБД. Начните с [архитектуры](architecture.md), [MVCC](mvcc.md) и [транзакций](transactions.md), затем разберите [изоляцию](isolation-levels.md) и [блокировки](locks.md). После этого переходите к индексам и planner, а эксплуатационные темы — WAL, VACUUM, replication и pooling — изучайте вместе.

Для прикладной работы особенно важны две связки:

- `MVCC → isolation → locks`: объясняет, что увидит запрос и где он будет ждать;
- `statistics → planner → EXPLAIN`: объясняет, почему сервер выбрал конкретный план.

Страницы не заменяют runbook конкретного кластера: параметры, расширения, topology и допустимый RPO/RTO должны быть зафиксированы отдельно.

## Источники

- [PostgreSQL 18 documentation](https://www.postgresql.org/docs/18/)
- [PostgreSQL versioning policy](https://www.postgresql.org/support/versioning/)
