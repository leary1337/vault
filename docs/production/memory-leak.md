---
title: Memory leak
description: Поиск монотонно удерживаемой памяти и различение heap, native и cache growth.
tags: [production, memory-leak, go]
updated: 2026-09-10
---

# Memory leak

## Symptoms

После одинаковой нагрузки post-GC heap или RSS растёт от цикла к циклу и не возвращается к устойчивому plateau; время до OOM зависит от uptime.

## Possible causes

Unbounded map/cache, забытые subscribers/timers, slice retaining большой backing array, queued work, goroutine leak с captured objects, unclosed response bodies, C/native allocation или intended cache без eviction.

## What to measure

Post-GC live heap/RSS по времени и uptime, object count/bytes по type/stack, cache/queue cardinality, goroutines, native mappings и allocation-minus-free slope при стабильной нагрузке.

## Diagnostics

Сначала докажите устойчивый рост после warm-up и GC, затем различите heap/RSS. Снимите два comparable heap profiles через интервал и diff retained allocations. Идите от растущего type к retaining owner/lifecycle. Если heap стабилен, исследуйте mmap/native/page cache.

## Tools

Go `pprof` heap (`inuse_space`, `inuse_objects`), runtime metrics, `go tool pprof -base`, `/proc` maps/smaps, cgroup memory и controlled soak test.

## Immediate mitigation

Ограничить offending cache/queue/input, отключить feature, уменьшить traffic, увеличить headroom или выполнить rolling restart с controlled concurrency. Не объявляйте restart исправлением.

## Root cause

Найдите ownership path и отсутствующее lifecycle condition: кто добавляет, почему entry/object остаётся reachable и какое событие должно было удалить/закрыть его. Для native leak подтвердите allocation API и release path.

## Prevention

Bounded collections с eviction/TTL, explicit `Close`/cancel ownership, soak/leak tests, profile regression, cardinality metrics и review lifetime каждого background goroutine/cache.

## Источник

- [Go profiling](https://go.dev/blog/pprof)

