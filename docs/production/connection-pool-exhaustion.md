---
title: Connection pool exhaustion
description: Диагностика pool wait, leaked connections, slow operations и capacity mismatch.
tags: [production, connections, database]
updated: 2026-09-10
---

# Connection pool exhaustion

## Symptoms

Pool waiters/wait duration и acquisition timeouts растут, хотя database может не быть на пределе. Active connections равны max; latency распространяется на unrelated requests.

## Possible causes

Slow/blocked queries, long transactions, leaked/unclosed rows or response bodies, concurrency burst, слишком маленький pool, слишком большой fleet-wide pool для server capacity, connection churn или dependency outage.

## What to measure

Open/in-use/idle/max, wait count/duration, hold time, query/transaction latency, database sessions/waits/max, request concurrency, timeouts и connections across all replicas/jobs.

## Diagnostics

Разделите acquisition wait и operation time. Если hold time вырос — ищите slow/blocked work и ownership release path. Если concurrency вырос при прежнем hold time — оцените Little's Law/capacity. Сверьте process pool max × replicas с database/proxy limit и reserved admin headroom.

## Tools

Driver pool statistics, traces со span на acquire и query, goroutine stacks, `pg_stat_activity`/locks, proxy metrics и connection establishment errors.

## Immediate mitigation

Остановить leak/blocker, rollback, ограничить request/job concurrency, shed load, сократить timeout/transaction scope. Увеличивать pool только если database имеет headroom; иначе очередь просто переместится и overload усилится.

## Root cause

Определите, почему connection удерживался дольше или demand превысил рассчитанную concurrency: missing close, remote call внутри transaction, lock, traffic burst или fleet scaling mismatch.

## Prevention

Всегда close rows/body, transaction deadlines, pool wait/hold metrics, bounded concurrency, fleet-wide connection budget, leak tests и reserved operational connections. См. [connection pooling](../databases/postgresql/connection-pooling.md).

