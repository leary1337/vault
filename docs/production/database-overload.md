---
title: Database overload
description: Диагностика PostgreSQL saturation, locks, queries и workload amplification.
tags: [production, postgresql, database]
updated: 2026-10-06
---

# Database overload

Перегрузка БД — запросы приходят быстрее, чем конкретный ресурс может обслужить их.

## Симптомы

Query latency/timeouts и pool waits растут, TPS перестаёт увеличиваться; CPU/I/O/locks/WAL или connection count насыщаются. Application retries могут резко усилить load.

## Возможные причины

Traffic/query mix change, missing/invalid index, plan regression/statistics, lock contention, connection storm, large transaction, autovacuum debt/bloat, checkpoint/WAL/I/O pressure, hot row/table или replica (копия данных на другом узле) lag.

## Что измерить

User SLI (измеренный показатель качества), QPS/latency/error по normalized query, active/waiting sessions, wait events/locks, CPU/IOPS/latency, buffers/cache hit с контекстом, temp files, WAL/checkpoint, dead tuples/vacuum и pool wait.

## Проверка гипотез

Сначала остановите amplification и определите dominant wait class. Найдите top queries по total time/calls, blockers и long transactions. Сравните план/statistics с healthy period; `EXPLAIN ANALYZE` на write/expensive query запускайте только в безопасной среде или с пониманием side effects.

## Инструменты

`pg_stat_activity`, `pg_locks`, `pg_stat_statements`, `pg_stat_io`, `pg_stat_database`, `EXPLAIN`, logs/auto_explain, OS/cgroup I/O и application pool metrics.

## Как уменьшить ущерб

Rate/load shed, disable expensive endpoint/job, stop retry storm, terminate только доказанный blocker с оценкой rollback (отмена локальной транзакции или возврат старой версии), rollback query/deploy, reduce batch/concurrency или fail over лишь при подтверждённом failure. Простое увеличение connections часто ухудшает overload.

## Механизм причины

Свяжите workload/plan/lock/maintenance change с конкретным resource bottleneck и queueing. Укажите, почему admission, query review или capacity guard не сработал.

## Предотвращение

Query budgets/statement timeout, bounded (с явным конечным пределом) pools, indexes/statistics/vacuum monitoring, load tests с data scale, slow-query review, online migration procedure и capacity/error-budget alerts. См. [PostgreSQL operations](../databases/postgresql/README.md).

## Разбор с числами

Иллюстративный EXPLAIN, не результат замера этого репозитория:

```text
Seq Scan on ads (actual time=0.1..420.0 rows=50 loops=1)
  Filter: (owner_id = 42)
  Rows Removed by Filter: 999950
  Buffers: shared hit=1000 read=12000
```

Здесь запрос ради 50 строк просмотрел миллион, чтение страниц подтверждает большой объём. Для списка владельца рассматриваем индекс `(owner_id, created_at DESC, id DESC)` под реальный фильтр/порядок. Но index scan не всегда лучше: запрос большинства строк может выгоднее читать последовательно. Сравниваем estimates/actual rows, loops, buffers и время на production-подобном объёме.

Альтернатива: высокий wait_event `Lock`, CPU низкая, блокирующая транзакция 20 минут. Новый индекс не устранит lock. Сначала находим блокировщика и владельца операции; terminate может вызвать долгий rollback. `EXPLAIN ANALYZE` выполняет запрос, включая writes; even rollback не отменяет все внешние эффекты/sequence changes. [PostgreSQL EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html), [статистика](https://www.postgresql.org/docs/18/monitoring-stats.html).

## Проверь себя

1. Почему нельзя лечить все проблемы индексом?
2. Что делает EXPLAIN ANALYZE?

<details>
<summary>Ориентиры для ответа</summary>

1. Locks, I/O saturation (насыщение ресурса и образование очереди) и amplification требуют другого механизма.
2. Действительно запускает запрос и измеряет выполнение.

</details>
