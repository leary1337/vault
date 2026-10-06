---
title: Resources
description: Requests, limits, CPU throttling, OOMKilled и Go runtime.
tags: [containers, kubernetes, resources]
updated: 2026-10-06
---

# Resources

Request описывает ресурс для размещения, limit ограничивает использование. Свободная память node не отменяет hard memory limit отдельного container.

Per-container requests участвуют в scheduling и CPU shares; limits применяются runtime/kernel cgroups. Pod effective request включает containers и scheduling semantics init/sidecars по API rules — проверяйте manifest/status, не суммируйте на глаз сложный Pod.

## CPU

`500m` = 0.5 CPU time. Request влияет на placement и proportional weight при contention. Limit — hard CFS bandwidth ceiling: превышение не убивает container, а throttles, что может поднять p99 при низком average CPU host.

Go 1.25+ автоматически выбирает default `GOMAXPROCS` с учётом cgroup CPU limit и периодически обновляет его. CPU request без limit не задаёт такой ceiling; при manual override поведение меняется.

## Memory

Memory request нужен scheduler и влияет на eviction/QoS; limit задаёт cgroup boundary, превышение/reclaim failure может дать `OOMKilled`. Accounting включает не только Go heap: stacks, runtime, mmap, page cache, tmpfs `emptyDir`, socket/kernel memory.

`GOMEMLIMIT` — soft Go runtime target, не hard cap; задавайте ниже container limit с измеренным headroom (запас ресурсов сверх обычной нагрузки). Слишком низкий target вызывает excessive GC, слишком высокий — OOM до полезной реакции runtime.

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

Смотрите usage/working set, throttling (принудительное ожидание после исчерпания квоты), `memory.events`, restart reason, node pressure и application heap/profile. Requests получают из load tests и percentiles, затем пересматривают; limit без headroom — не capacity plan.

## Бюджет replicas и runtime

В manifest request=250m/256Mi, limit=1CPU/512Mi. Три Pods требуют scheduler не менее 750m CPU и 768Mi memory; rollout (замена экземпляров приложения новой версией) с surge=1 потребует requests уже 1CPU/1Gi. Это расчёт только данных containers, без дополнительного Pod overhead/init/sidecar semantics.

Memory usage 480Mi при limit512Mi оставляет слишком мало запаса для burst. `GOMEMLIMIT=400MiB` — гипотеза для эксперимента, не hard protection: измерьте allocation pressure, RSS/cgroup, external memory и GC CPU. CPU limit1 может регулярно throttling-ить burst при средней utilization (доля занятого ресурса за интервал) ниже1.

QoS (класс ресурсообеспечения Pod) Guaranteed требует соответствующих request=limit для необходимых resources у containers; оно влияет на eviction (удаление Pod по решению платформы) ordering, но не делает Pod бессмертным. `OOMKilled` container и `Evicted` Pod — разные механизмы: первый связан с OOM, второй с решениями kubelet по node pressure и thresholds.

## Источники

- [Resource management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
- [Go container-aware GOMAXPROCS](../../go/runtime/scheduler.md)

## Проверь себя

1. Почему surge считают по requests?
2. Чем OOMKilled отличается от Evicted?

<details>
<summary>Ориентиры для ответа</summary>

1. Scheduler размещает Pods по requests; peak rollout создаёт дополнительную потребность.
2. Убийство memory controller и удаление Pod из-за node pressure — разные причины/проверки.

</details>
