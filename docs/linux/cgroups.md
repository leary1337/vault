---
title: cgroups v2
description: CPU, memory, PID и I/O accounting и limits.
tags: [linux, cgroups, containers]
updated: 2026-09-10
---

# cgroups v2

cgroup организует processes и применяет resource controllers и accounting иерархически. Современный unified cgroup v2 имеет единое дерево; container не является отдельной VM и делит kernel host.

## Основные interfaces

- `cpu.max`: quota + period (`max` означает без hard quota);
- `cpu.weight`: proportional share при contention;
- `cpu.stat`: usage и throttled periods/time;
- `memory.current`, `memory.stat`: current usage и breakdown;
- `memory.high`: reclaim/throttling pressure, не hard OOM limit;
- `memory.max`: hard boundary; невозможный reclaim может вызвать cgroup OOM;
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

Memory accounting включает anonymous, page cache и kernel/socket categories в пределах controller semantics; process RSS не равен `memory.current`. CPU quota создаёт periodic throttling и tail latency, даже если host имеет idle CPUs.

Limits и reservations различайте: hard cap предотвращает noisy neighbor ценой throttling/OOM; weight/protection работает при contention. Runtime должен видеть container limits: Go 1.25+ автоматически подбирает `GOMAXPROCS` по cgroup CPU limit, а `GOMEMLIMIT` оставляет headroom до memory.max.

## Источники

- [Control Group v2](https://docs.kernel.org/admin-guide/cgroup-v2.html)
