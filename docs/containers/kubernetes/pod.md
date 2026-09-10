---
title: Pod
description: Smallest deployable unit, shared namespaces и lifecycle.
tags: [containers, kubernetes, pods]
updated: 2026-09-10
---

# Pod

Pod — smallest deployable Kubernetes unit: один или несколько tightly coupled containers с общим network namespace/IP/ports и declaratively shared volumes. Containers внутри общаются через `localhost`, но имеют отдельные process/filesystem/cgroup boundaries согласно runtime config.

Pod не durable identity. После reschedule controller создаёт новый Pod с новым UID/IP; application state храните во внешнем store/PersistentVolume и используйте Service/DNS discovery.

## Containers

- init containers выполняются до application containers последовательно;
- sidecars обслуживают logging/proxy/helper lifecycle, но добавляют resources и termination ordering;
- ephemeral containers предназначены для troubleshooting, не normal workload;
- restart policy действует через kubelet внутри Pod, а controller заменяет failed/deleted Pods.

Pod phase (`Pending/Running/Succeeded/Failed/Unknown`) грубая; container states/reasons/events дают детали. `CrashLoopBackOff` — backoff отображения повторных crashes, а не root cause.

## Scheduling и identity

Scheduler выбирает node по requests, affinity/anti-affinity, topology spread, taints/tolerations и constraints. ServiceAccount identity/token и security context задавайте явно; не используйте default privileges без необходимости.

```bash
kubectl get pod <pod> -o wide
kubectl describe pod <pod>
kubectl get pod <pod> -o yaml
```

Не создавайте naked Pod для долгоживущего сервиса: Deployment/StatefulSet/Job управляет replacement и rollout.

## Источники

- [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Pod lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
