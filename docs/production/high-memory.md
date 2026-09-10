---
title: High memory
description: Диагностика heap, RSS, page cache, mmap и cgroup memory pressure.
tags: [production, memory, go]
updated: 2026-09-10
---

# High memory

## Symptoms

Working set/RSS приближается к limit, растут reclaim/PSI/OOM events, GC учащается или container получает OOMKill. Go heap metric может быть заметно меньше process memory.

## Possible causes

Рост live heap, временный burst, large buffers/caches, goroutine stacks, mmap/native allocations, page cache, memory fragmentation, telemetry queues или неверный limit.

## What to measure

RSS/working set, cgroup `memory.current/events/stat`, heap live/in-use/idle/released, allocation rate, GC frequency, goroutines/stacks, page cache и relation к traffic/data size.

## Diagnostics

Определите компонент памяти: Go heap vs stacks vs mapped/native vs file cache. Сравните после GC и между versions. Heap profiles `inuse_space` показывают удерживаемые объекты, `alloc_space` — churn; один snapshot не доказывает leak. Проверьте memory limit/GOMEMLIMIT и OOM event timeline.

## Tools

cgroup v2 files, `memory.stat`, `/proc/<pid>/smaps_rollup`, `pmap`, Go runtime metrics/`pprof`, Kubernetes events и node PSI.

## Immediate mitigation

Остановить admission/large jobs, уменьшить bounded caches/batches, rollback, traffic shift или аккуратно увеличить memory при наличии capacity. Rolling restart временно снимает pressure, но сохраняйте profile/evidence сначала.

## Root cause

Классифицируйте: пропорциональный legitimate working set, allocation burst, retained object graph, native mapping или resource limit mismatch. Подтвердите timeline и controlled test.

## Prevention

Memory budgets на caches/queues, bounded payload/batch, load tests до steady state, heap/profile access, requests/limits по измерениям и alerts на PSI/OOM/budget trend, а не только процент.

