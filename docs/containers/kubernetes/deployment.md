---
title: Deployment
description: ReplicaSet, rolling update, rollout health и rollback.
tags: [containers, kubernetes, deployments]
updated: 2026-09-10
---

# Deployment

Deployment управляет ReplicaSets и обеспечивает declarative rollout stateless interchangeable Pods. Изменение Pod template создаёт новый ReplicaSet; controller постепенно меняет replicas.

## RollingUpdate

- `maxSurge` — сколько Pods сверх desired replicas можно создать;
- `maxUnavailable` — сколько desired Pods может быть unavailable;
- `minReadySeconds` — сколько Pod должен оставаться ready до available;
- `progressDeadlineSeconds` обнаруживает stalled rollout, но сам автоматически не rollback-ит.

Readiness определяет, получает ли Pod Service traffic и считается available. Liveness не должна использоваться как rollout readiness. `Recreate` сначала удаляет старые Pods и допускает downtime.

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 25%
    maxUnavailable: 0
minReadySeconds: 10
progressDeadlineSeconds: 600
```

## Safety

Image tag используйте immutable/digest; иначе одинаковая spec может запускать разный code. Schema/API changes должны быть backward-compatible на период совместной работы old/new. Capacity выдерживает surge и одну failure zone.

PodDisruptionBudget ограничивает voluntary eviction, но не гарантирует availability и не является механизмом управления Deployment rollout. Topology spread/anti-affinity распределяет replicas; слишком жёсткие constraints делают Pods Pending.

```bash
kubectl rollout status deployment/api
kubectl rollout history deployment/api
kubectl rollout undo deployment/api
```

Rollback code не откатывает external migration/state автоматически; нужен отдельный compatible plan.

## Источники

- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
