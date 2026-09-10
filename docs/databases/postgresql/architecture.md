---
title: Архитектура PostgreSQL
description: Процессы, память, storage и путь запроса в PostgreSQL.
tags: [databases, postgresql, internals]
updated: 2026-09-10
---

# Архитектура PostgreSQL

PostgreSQL использует модель «один server process на соединение». Главный `postgres` принимает подключения и создаёт backend process; фоновые процессы занимаются WAL, checkpoints, vacuum, replication и другими задачами. Это отличается от thread-per-connection серверов и делает стоимость большого числа соединений заметной.

## Путь запроса

1. Parser строит parse tree и проверяет синтаксис.
2. Analyzer связывает имена с объектами каталога и типами.
3. Rewriter применяет rules и разворачивает views.
4. Planner/optimizer оценивает допустимые планы по statistics и cost model.
5. Executor читает heap/index pages, проверяет MVCC visibility и формирует результат.

Plan cache prepared statement может использовать custom или generic plan. Generic plan экономит planning time, но хуже учитывает конкретные значения параметров; проверяйте это через `EXPLAIN` и `plan_cache_mode`, а не предполагайте.

## Память и storage

- `shared_buffers` — общий buffer cache PostgreSQL; ОС параллельно использует page cache.
- `work_mem` задаёт лимит для отдельной sort/hash operation, а не для процесса или запроса целиком.
- `maintenance_work_mem` обслуживает maintenance operations.
- Таблица физически состоит из fixed-size pages, обычно 8 KiB; строки лежат в heap, индексы — отдельные relations.
- WAL записывает изменения до dirty data pages и обеспечивает crash recovery.

Data directory содержит relation files, WAL, transaction status и служебные данные. Не копируйте его как обычную папку работающего сервера: backup должен обеспечивать согласованность с WAL.

## Фоновые процессы

Checkpointer ограничивает объём crash recovery, background writer сглаживает запись dirty buffers, WAL writer пишет WAL buffers, autovacuum workers удаляют/замораживают старые версии и обновляют statistics. Для replication работают walsender/walreceiver; logical replication добавляет launcher/workers.

## Источники

- [PostgreSQL server architecture](https://www.postgresql.org/docs/18/tutorial-arch.html)
- [Database physical storage](https://www.postgresql.org/docs/18/storage.html)
- [Resource consumption](https://www.postgresql.org/docs/18/runtime-config-resource.html)
