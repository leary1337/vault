---
title: Database overload
description: Диагностика PostgreSQL saturation, locks, queries и workload amplification.
tags: [production, postgresql, database]
updated: 2026-09-10
---

# Database overload

## Symptoms

Query latency/timeouts и pool waits растут, TPS перестаёт увеличиваться; CPU/I/O/locks/WAL или connection count насыщаются. Application retries могут резко усилить load.

## Possible causes

Traffic/query mix change, missing/invalid index, plan regression/statistics, lock contention, connection storm, large transaction, autovacuum debt/bloat, checkpoint/WAL/I/O pressure, hot row/table или replica lag.

## What to measure

User SLI, QPS/latency/error по normalized query, active/waiting sessions, wait events/locks, CPU/IOPS/latency, buffers/cache hit с контекстом, temp files, WAL/checkpoint, dead tuples/vacuum и pool wait.

## Diagnostics

Сначала остановите amplification и определите dominant wait class. Найдите top queries по total time/calls, blockers и long transactions. Сравните план/statistics с healthy period; `EXPLAIN ANALYZE` на write/expensive query запускайте только в безопасной среде или с пониманием side effects.

## Tools

`pg_stat_activity`, `pg_locks`, `pg_stat_statements`, `pg_stat_io`, `pg_stat_database`, `EXPLAIN`, logs/auto_explain, OS/cgroup I/O и application pool metrics.

## Immediate mitigation

Rate/load shed, disable expensive endpoint/job, stop retry storm, terminate только доказанный blocker с оценкой rollback, rollback query/deploy, reduce batch/concurrency или fail over лишь при подтверждённом failure. Простое увеличение connections часто ухудшает overload.

## Root cause

Свяжите workload/plan/lock/maintenance change с конкретным resource bottleneck и queueing. Укажите, почему admission, query review или capacity guard не сработал.

## Prevention

Query budgets/statement timeout, bounded pools, indexes/statistics/vacuum monitoring, load tests с data scale, slow-query review, online migration procedure и capacity/error-budget alerts. См. [PostgreSQL operations](../databases/postgresql/README.md).

