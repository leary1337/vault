---
title: Docker resources
description: CPU quota, memory/OOM, PID и cgroup diagnostics.
tags: [containers, docker, cgroups]
updated: 2026-09-10
---

# Docker resources

Без limits container может использовать ресурсы host согласно scheduler. Docker flags на Linux настраивают cgroups; hard limits защищают соседей, но создают throttling/OOM внутри workload.

## CPU

`--cpus=2` задаёт CFS bandwidth quota примерно двух CPU-time cores за period, не закрепляет два физических core. `--cpu-shares`/weight влияет на долю только при contention. `--cpuset-cpus` pin-ит allowed CPUs и влияет на NUMA/cache/availability.

Смотрите `cpu.stat`: throttled periods/time вместе с latency и demand. Host CPU может быть idle, пока container throttled quota.

## Memory

`--memory` задаёт hard limit; accounting включает больше, чем language heap (anonymous, page cache и kernel categories согласно cgroup). При невозможном reclaim kernel может OOM-kill process; container exit часто 137, но подтвердите OOM event/inspect/kernel logs.

Оставляйте runtime headroom: для Go soft `GOMEMLIMIT` ниже cgroup limit, потому что RSS включает stacks/runtime/mmap/page cache. Не отключайте OOM killer без hard limit.

## Other limits

`--pids-limit` ограничивает tasks/fork bomb; `--ulimit nofile` — process FD limit; blkio/I/O controls зависят от host/storage. Compose/Swarm/Kubernetes syntax отличается — проверяйте, что выбранный orchestrator реально применяет limits.

```bash
docker stats
docker inspect <container>
cat /sys/fs/cgroup/<path>/{cpu.stat,memory.current,memory.events,pids.current}
```

Capacity учитывает сумму limits и failure headroom; oversubscription допустим только с monitoring/shedding.

## Источники

- [Resource constraints](https://docs.docker.com/engine/containers/resource_constraints/)
- [cgroup v2](../../linux/cgroups.md)
