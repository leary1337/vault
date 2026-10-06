---
title: PostgreSQL
description: Архитектура, транзакции, запросы и эксплуатация PostgreSQL.
tags:
  - databases
  - postgresql
updated: 2026-10-06
---

# PostgreSQL

Раздел описывает PostgreSQL 18.6. Один запрос может быстро найти строку, ждать другого писателя или прочитать прежнюю версию. Здесь объясняется, почему эти результаты возникают и как их проверить.

Для вопроса «что видит параллельный запрос?» связаны [MVCC](mvcc.md), [изоляция](isolation-levels.md) и [блокировки](locks.md). Для «почему запрос медленный?» — [Планировщик запросов](query-planner.md), [индексы](indexes.md) и [EXPLAIN](explain.md). [Журнал изменений: WAL](wal.md), [репликация](replication.md) и [VACUUM](vacuum.md) объясняют сохранение, копирование и обслуживание.

Примеры имеют учебные данные и указанные предположения. Реальные лимиты и порядок восстановления зависят от вашего сервера; статья объясняет механизм, чтобы выбрать их осознанно.

## Темы

- [Пул соединений](connection-pooling.md)
- [EXPLAIN](explain.md)
- [Соединение таблиц: JOIN](joins.md)
- [MVCC](mvcc.md)
- [Планировщик запросов](query-planner.md)
- [SQL-задачи](sql-interview-tasks.md)
- [VACUUM и autovacuum](vacuum.md)
- [Журнал изменений: WAL](wal.md)
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

- [PostgreSQL 18.6 release notes](https://www.postgresql.org/docs/18/release-18-6.html)
