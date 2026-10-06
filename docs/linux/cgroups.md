---
title: cgroups v2
description: CPU, memory, PID и I/O accounting и limits.
tags: [linux, cgroups, containers]
updated: 2026-10-06
---

# cgroups v2

cgroup объединяет процессы и задаёт им общий бюджет ресурсов. Namespace меняет видимость, а cgroup ограничивает использование: это разные механизмы контейнера.

cgroup организует processes и применяет resource controllers и accounting иерархически. Современный unified cgroup v2 имеет единое дерево; container не является отдельной VM и делит kernel host.

## Основные interfaces

- `cpu.max`: quota + period (`max` означает без hard quota);
- `cpu.weight`: proportional share при contention;
- `cpu.stat`: usage и throttled periods/time;
- `memory.current`, `memory.stat`: current usage и breakdown;
- `memory.high`: reclaim/throttling pressure, не hard OOM limit;
- `memory.max`: hard boundary; невозможный reclaim (освобождение или вытеснение страниц для получения памяти) может вызвать cgroup OOM;
- `memory.events`: `high/max/oom/oom_kill` counters;
- `pids.current/pids.max`: tasks limit;
- `io.stat/io.max/io.weight`: device I/O accounting/control;
- `*.pressure`: PSI внутри cgroup.

```bash
cat /proc/$PID/cgroup
cat /sys/fs/cgroup/<path>/cpu.max
cat /sys/fs/cgroup/<path>/cpu.stat
cat /sys/fs/cgroup/<path>/memory.current
cat /sys/fs/cgroup/<path>/memory.events
```

Memory accounting включает anonymous, page cache и kernel/socket categories в пределах controller semantics; process RSS не равен `memory.current`. CPU quota создаёт periodic throttling (принудительное ожидание после исчерпания квоты) и tail latency (задержка самых медленных запросов, например p99), даже если host имеет idle CPUs.

Limits и reservations различайте: hard cap предотвращает noisy neighbor ценой throttling/OOM; weight/protection работает при contention. Runtime должен видеть container limits: Go 1.25+ при соответствующих defaults подбирает `GOMAXPROCS` по cgroup CPU limit, а `GOMEMLIMIT` оставляет headroom (запас ресурсов сверх обычной нагрузки) до memory.max.

## Прочитать квоту в понятных единицах

```text
cpu.max: 150000 100000
memory.max: 536870912
```

Это пример вывода. Первая строка даёт до 150 мс суммарного CPU-времени за период 100 мс: средний потолок 1,5 CPU, а не закреплённые полтора ядра. Вторая — 512 МиБ памяти. Несколько потоков могут быстро потратить quota, а потом ждать остаток периода. Именно поэтому p99 может ухудшаться при свободном host CPU.

Проверяйте также родителей cgroup: дочернее `max` не снимает ограничение предка. Для memory сравните `memory.current`, `memory.stat`, `memory.events` и pressure; RSS одного process не включает весь учёт группы. Go 1.25+ defaults также зависят от go directive и GODEBUG, подробнее в [scheduler](../go/runtime/scheduler.md).

## Источники

- [Control Group v2](https://docs.kernel.org/admin-guide/cgroup-v2.html)

## Проверь себя

1. Что означает 50000 100000 в cpu.max?
2. Снимает ли memory.max=max дочерней группы лимит родителя?

<details>
<summary>Ориентиры для ответа</summary>

1. До 0,5 CPU в среднем за период, не affinity на половину ядра.
2. Нет, ограничения иерархические.

</details>
