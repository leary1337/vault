---
title: High latency
description: Разложение end-to-end latency на queue, compute, I/O и retry time.
tags: [production, latency, observability]
updated: 2026-09-10
---

# High latency

## Symptoms

p95/p99 или доля запросов медленнее SLO растёт; timeouts увеличивают errors/retries. Average и p50 могут оставаться нормальными.

## Possible causes

Queueing/saturation, slow dependency/query, connection/DNS/TLS establishment, lock contention, GC/scheduler delay, payload growth, retry amplification, hot shard или mixed slow cohort.

## What to measure

Latency distribution по route/version/region/outcome, queue vs service time, dependency spans, saturation, timeouts/retries и request budget. Cardinality IDs оставляйте в traces/logs.

## Diagnostics

Подтвердите affected cohort и изменение traffic/deploy. Разложите representative slow trace на admission, queue, compute и downstream wait. Сравните slow с healthy trace и server latency с client-observed latency. Затем проверяйте saturation конкретного компонента.

## Tools

Prometheus histograms/exemplars, distributed traces, structured logs, Go block/mutex/CPU profiles, database `EXPLAIN (ANALYZE, BUFFERS)` безопасно на representative query, network/DNS/TLS metrics.

## Immediate mitigation

Rollback, disable slow feature, shed/rate-limit expensive work, cap queue/deadlines, serve stale/cache, shift traffic или add capacity только в доказанном bottleneck. Не добавляйте retries к latency outage.

## Root cause

Опишите механизм critical path: какой ресурс/operation добавил queue/service time, почему control не ограничил его и как это перешло в SLO impact. Один slow span — evidence, не статистическое доказательство.

## Prevention

Latency budgets по hop, bounded concurrency/queues, representative load tests, query/index review, timeout hierarchy, trace sampling slow paths и SLO burn alerts.

