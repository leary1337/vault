---
title: Kubernetes troubleshooting
description: Ordered workflow от desired state до node/runtime/network.
tags: [containers, kubernetes, troubleshooting]
updated: 2026-09-10
---

# Kubernetes troubleshooting

Сначала зафиксируйте namespace/workload/revision/time/impact и recent deploy/config/node events. Не удаляйте Pod до сохранения status, events и previous logs.

## 1. Desired state и rollout

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

Если scope несколько workloads на node/zone, проверьте node conditions, pressure, kubelet/runtime/CNI/CSI и cloud events. Эскалируйте cluster operator с timestamps/PIDs/UIDs.

Mitigation (rollback, scale, isolate node, shed load) отделяйте от root cause. Validate тем же SLI и сохраните evidence/runbook update.

## Источники

- [Troubleshooting applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Troubleshooting clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/)
