---
title: Resources
description: Requests, limits, CPU throttling, OOMKilled и Go runtime.
tags: [containers, kubernetes, resources]
updated: 2026-09-10
---

# Resources

Per-container requests участвуют в scheduling и CPU shares; limits применяются runtime/kernel cgroups. Pod effective request включает containers и scheduling semantics init/sidecars по API rules — проверяйте manifest/status, не суммируйте на глаз сложный Pod.

## CPU

`500m` = 0.5 CPU time. Request влияет на placement и proportional weight при contention. Limit — hard CFS bandwidth ceiling: превышение не убивает container, а throttles, что может поднять p99 при низком average CPU host.

Go 1.25+ автоматически выбирает default `GOMAXPROCS` с учётом cgroup CPU limit и периодически обновляет его. CPU request без limit не задаёт такой ceiling; при manual override поведение меняется.

## Memory

Memory request нужен scheduler и влияет на eviction/QoS; limit задаёт cgroup boundary, превышение/reclaim failure может дать `OOMKilled`. Accounting включает не только Go heap: stacks, runtime, mmap, page cache, tmpfs `emptyDir`, socket/kernel memory.

`GOMEMLIMIT` — soft Go runtime target, не hard cap; задавайте ниже container limit с измеренным headroom. Слишком низкий target вызывает excessive GC, слишком высокий — OOM до полезной реакции runtime.

```yaml
resources:
  requests: {cpu: 250m, memory: 256Mi}
  limits: {cpu: "1", memory: 512Mi}
```

## Diagnosis

```bash
kubectl describe pod <pod>
kubectl top pod <pod> --containers
kubectl get pod <pod> -o jsonpath='{.status.containerStatuses[*].lastState}'
```

Смотрите usage/working set, throttling, `memory.events`, restart reason, node pressure и application heap/profile. Requests получают из load tests и percentiles, затем пересматривают; limit без headroom — не capacity plan.

## Источники

- [Resource management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Go container-aware GOMAXPROCS](../../go/runtime/scheduler.md)
