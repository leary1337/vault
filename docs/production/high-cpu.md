---
title: High CPU
description: Диагностика CPU saturation, throttling и горячего кода Go.
tags: [production, cpu, go]
updated: 2026-10-06
---

# High CPU

CPU-профиль показывает места активного вычисления, а не время ожидания сети или канала.

## Симптомы

CPU utilization/throttling и run queue растут, latency (срок ответа) увеличивается, throughput (скорость успешной обработки) перестаёт масштабироваться; pod может не быть «на 100%» из-за cgroup quota.

## Возможные причины

Traffic growth/amplification, hot loop, expensive serialization/compression/regex/crypto, GC work из-за allocations, lock spinning, polling, profiler/debug mode или слишком низкий CPU limit.

## Что измерить

User SLI (измеренный показатель качества) и request rate, CPU seconds по process/container, throttled periods/time, run queue, goroutines, GC CPU/pause/allocation rate и CPU profile по версии/route.

## Проверка гипотез

Сначала нормализуйте CPU на cgroup quota и сравните replicas/versions. Проверьте traffic и deploy timeline. Если CPU следует RPS — оцените CPU/request и route mix; если нет — снимите короткий profile на affected instance. Различите application compute, GC и kernel/system time.

## Инструменты

Prometheus, `kubectl top` как coarse view, cgroup `cpu.stat`, `pidstat`/`top`, Go `pprof` CPU/profile и execution trace (связь этапов одной операции) для scheduler/latency вопросов.

## Как уменьшить ущерб

Rollback/disable expensive path, load shed/rate limit, уменьшить amplification, увеличить replicas или CPU limit при доступном node capacity. Не профилируйте весь fleet длительно.

## Механизм причины

Свяжите конкретное изменение/traffic shape с samples в горячих stacks и измеренным CPU/request. Высокая функция в profile может быть downstream symptom; подтвердите benchmark/reproduction.

## Предотвращение

Load tests с production mix, CPU/request dashboards, bounded (с явным конечным пределом) inputs, benchmarks для hot paths, корректные requests/limits, profiling endpoint с authentication и canary regression gates.

## Источники

- [Go diagnostics](https://go.dev/doc/diagnostics)
- [Linux pressure stall information](https://docs.kernel.org/accounting/psi.html)

## Разбор с числами

Учебные показатели: RPS=1 000 неизменен, CPU вырос 0,5→1,5 CPU-s/s после deploy. Иллюстративный `pprof top`:

```text
flat   flat%   cum%   function
0.90s  60.0%   60.0%  encoding/json.(*decodeState).object
0.30s  20.0%   20.0%  runtime.gcDrain
```

Это гипотеза о дорогом JSON/allocations, не реальный профиль проекта. Проверяем размер payload (полезное содержимое запроса или события), число decode, `alloc_space` и benchmark одинакового запроса. Высокий `cum` у handler означает стоимость его потомков, высокий `flat` — samples самой функции. Проценты samples не равны доле wall latency.

Если CPU 0,9 core при quota=1 и throttled time вырос, процесс может упираться в cgroup несмотря на низкую нагрузку целого node. Если CPU низка, p99 (время, в которое укладывается 99% наблюдений) высока и stacks в network wait, CPU-оптимизация не главный путь. [Go diagnostics](https://go.dev/doc/diagnostics).

## Проверь себя

1. Что означает flat?
2. Почему CPU меньше 100% node может быть пределом?

<details>
<summary>Ориентиры для ответа</summary>

1. Samples непосредственно в функции, без её потомков.
2. У контейнера quota значительно меньше мощности node.

</details>
