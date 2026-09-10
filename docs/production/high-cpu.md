---
title: High CPU
description: Диагностика CPU saturation, throttling и горячего кода Go.
tags: [production, cpu, go]
updated: 2026-09-10
---

# High CPU

## Symptoms

CPU utilization/throttling и run queue растут, latency увеличивается, throughput перестаёт масштабироваться; pod может не быть «на 100%» из-за cgroup quota.

## Possible causes

Traffic growth/amplification, hot loop, expensive serialization/compression/regex/crypto, GC work из-за allocations, lock spinning, polling, profiler/debug mode или слишком низкий CPU limit.

## What to measure

User SLI и request rate, CPU seconds по process/container, throttled periods/time, run queue, goroutines, GC CPU/pause/allocation rate и CPU profile по версии/route.

## Diagnostics

Сначала нормализуйте CPU на cgroup quota и сравните replicas/versions. Проверьте traffic и deploy timeline. Если CPU следует RPS — оцените CPU/request и route mix; если нет — снимите короткий profile на affected instance. Различите application compute, GC и kernel/system time.

## Tools

Prometheus, `kubectl top` как coarse view, cgroup `cpu.stat`, `pidstat`/`top`, Go `pprof` CPU/profile и execution trace для scheduler/latency вопросов.

## Immediate mitigation

Rollback/disable expensive path, load shed/rate limit, уменьшить amplification, увеличить replicas или CPU limit при доступном node capacity. Не профилируйте весь fleet длительно.

## Root cause

Свяжите конкретное изменение/traffic shape с samples в горячих stacks и измеренным CPU/request. Высокая функция в profile может быть downstream symptom; подтвердите benchmark/reproduction.

## Prevention

Load tests с production mix, CPU/request dashboards, bounded inputs, benchmarks для hot paths, корректные requests/limits, profiling endpoint с authentication и canary regression gates.

## Источники

- [Go diagnostics](https://go.dev/doc/diagnostics)
- [Linux pressure stall information](https://docs.kernel.org/accounting/psi.html)

