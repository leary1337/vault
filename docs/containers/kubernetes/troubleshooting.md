---
title: Kubernetes troubleshooting
description: Ordered workflow от desired state до node/runtime/network.
tags: [containers, kubernetes, troubleshooting]
updated: 2026-10-06
---

# Kubernetes troubleshooting

Сначала сохраняют состояние и logs, затем проверяют границу отказа. Удаление Pod до этого часто убирает нужные следы и меняет условия воспроизведения.

Сначала зафиксируйте namespace/workload/revision/time/impact и recent deploy/config/node events. Не удаляйте Pod до сохранения status, events и previous logs.

## 1. Desired state и rollout (замена экземпляров приложения новой версией)

```bash
kubectl get deploy,rs,pod -n <ns> -o wide
kubectl rollout status deploy/<name> -n <ns>
kubectl describe deploy/<name> -n <ns>
```

Проверьте image/digest, replicas, conditions, unavailable и rollout strategy.

## 2. Pod scheduling/lifecycle

```bash
kubectl describe pod/<pod> -n <ns>
kubectl get events -n <ns> --sort-by=.metadata.creationTimestamp
kubectl get pod/<pod> -n <ns> -o yaml
```

`Pending`: requests/affinity/taints/quota/PVC/image. `CrashLoopBackOff`: container exit reason, не diagnosis. `OOMKilled`: memory/cgroup; `Evicted`: node pressure. Events имеют retention и могут повторяться/агрегироваться.

## 3. Logs и process

```bash
kubectl logs <pod> -c <container> -n <ns> --since=30m
kubectl logs <pod> -c <container> -n <ns> --previous
kubectl top pod <pod> -n <ns> --containers
kubectl debug -it <pod> -n <ns> --image=<approved-debug-image> --target=<container>
```

Не печатайте secrets; debug image и permissions controlled.

## 4. Service/network

```bash
kubectl get svc,endpointslice -n <ns>
kubectl get networkpolicy -n <ns>
kubectl run net-debug --rm -it -n <ns> --image=<approved-debug-image> -- sh
```

Проверяйте DNS → EndpointSlice/readiness → TCP → TLS → HTTP/gRPC. Port-forward обходит часть real path и не доказывает Service/Ingress health.

## 5. Node/control plane

Если scope (область измерения: host, cgroup или process) несколько workloads на node/zone, проверьте node conditions, pressure, kubelet/runtime/CNI/CSI и cloud events. Эскалируйте cluster operator с timestamps/PIDs/UIDs.

Mitigation (rollback, scale, isolate node, shed load) отделяйте от root cause. Validate тем же SLI (измеряемый показатель качества сервиса) и сохраните evidence/runbook update.

## CrashLoop: искать причину предыдущего запуска

```bash
kubectl get pod api-abc -n app -o jsonpath='{.status.containerStatuses[*].lastState.terminated}'
kubectl logs api-abc -n app -c api --previous
kubectl describe pod api-abc -n app
```

Имена условные. Если предыдущий reason=OOMKilled, memory.events и memory profile важнее повторной сборки image. Если app пишет invalid config, проверьте version/checksum и проекцию, а не увеличивайте liveness (проверка, нужен ли restart застрявшему процессу) delay. Если Pending event говорит Insufficient cpu, оптимизация handler не поможет размещению: нужны resources/capacity.

`kubectl top` зависит от metrics pipeline и показывает sampled usage, не все пики. Events могут истечь, previous logs ограничены lifecycle/rotation. Сохраняйте UID Pod и revision вместе со временем. Debug container не должен получать больше host/secret доступа, чем нужно для конкретной проверки.

## Источники

- [Troubleshooting applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Troubleshooting clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/)

## Проверь себя

1. Почему нужен --previous?
2. Доказывает ли успешный port-forward исправность Ingress?

<details>
<summary>Ориентиры для ответа</summary>

1. Current container может ещё не успеть ничего записать; причина в предыдущем запуске.
2. Нет, он обходит часть реального пути трафика.

</details>
