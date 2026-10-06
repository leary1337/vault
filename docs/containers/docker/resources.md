---
title: Docker resources
description: CPU quota, memory/OOM, PID и cgroup diagnostics.
tags: [containers, docker, cgroups]
updated: 2026-10-06
---

# Docker resources

Лимит container ограничивает общий расход ресурсов, а не только heap приложения. Превышение CPU ведёт к ожиданию, превышение памяти может закончиться убийством процесса.

Без limits container может использовать ресурсы host согласно scheduler. Docker flags на Linux настраивают cgroups; hard limits защищают соседей, но создают throttling/OOM внутри workload.

## CPU

`--cpus=2` задаёт CFS bandwidth quota примерно двух CPU-time cores за period, не закрепляет два физических core. `--cpu-shares`/weight влияет на долю только при contention. `--cpuset-cpus` pin-ит allowed CPUs и влияет на NUMA/cache/availability.

Смотрите `cpu.stat`: throttled periods/time вместе с latency и demand. Host CPU может быть idle, пока container throttled quota.

## Memory

`--memory` задаёт hard limit; accounting включает больше, чем language heap (anonymous, page cache и kernel categories согласно cgroup). При невозможном reclaim (освобождение или вытеснение страниц для получения памяти) kernel может OOM-kill process; container exit часто 137, но подтвердите OOM event/inspect/kernel logs.

Оставляйте runtime headroom (запас ресурсов сверх обычной нагрузки): для Go soft `GOMEMLIMIT` ниже cgroup limit, потому что cgroup учёт включает также память вне Go runtime и memory limit является мягким. Не отключайте OOM killer без hard limit.

## Other limits

`--pids-limit` ограничивает tasks/fork bomb; `--ulimit nofile` — process FD limit; blkio/I/O controls зависят от host/storage. Compose/Swarm/Kubernetes syntax отличается — проверяйте, что выбранный orchestrator реально применяет limits.

```bash
docker stats
docker inspect <container>
cat /sys/fs/cgroup/<path>/{cpu.stat,memory.current,memory.events,pids.current}
```

Capacity учитывает сумму limits и failure headroom; oversubscription допустим только с monitoring/shedding.

## Конкретный запуск и трактовка результата

```bash
docker run --cpus=1 --memory=512m --pids-limit=128   --ulimit nofile=4096:4096 api-image
```

Это пример: CPU quota около 1 CPU, memory hard limit 512 МиБ, предел tasks 128 и FD 4096. PID limit учитывает tasks, поэтому большое число threads тоже важно. Критичная нагрузка должна пройти тест именно с такими лимитами.

`GOMEMLIMIT=400MiB` при container 512 МиБ можно взять как гипотезу, оставляя 112 МиБ headroom; это не универсальная формула. Runtime-managed stacks уже входят в бюджет Go memory limit, а внешняя cgo/mmap и часть OS учёта — нет. Сверьте RSS/cgroup breakdown под нагрузкой.

`exit=137` означает завершение SIGKILL; подтвердите OOM через `.State.OOMKilled` и events. Увеличить лимит без поиска растущей очереди/retention — только временно отложить отказ.

## Источники

- [Resource constraints](https://docs.docker.com/engine/containers/resource_constraints/)
- [cgroup v2](../../linux/cgroups.md)

## Проверь себя

1. Закрепляет ли --cpus=1 одно физическое ядро?
2. Почему GOMEMLIMIT ниже memory limit?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, ограничивает CPU-time quota; affinity задаётся отдельно.
2. Он soft и охватывает только managed runtime память; нужен запас для остальных категорий.

</details>
