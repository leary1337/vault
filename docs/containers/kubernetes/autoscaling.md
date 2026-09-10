---
title: Autoscaling
description: HPA metrics, requests, stabilization и capacity limits.
tags: [containers, kubernetes, autoscaling]
updated: 2026-09-10
---

# Autoscaling

HorizontalPodAutoscaler периодически меняет replicas scalable workload по resource, custom или external metrics. Он реагирует после load, поэтому не заменяет baseline/headroom/backpressure.

Для average CPU utilization нужны CPU requests; без request metric для Pod может быть undefined. Примерная формула:

```text
desired replicas = ceil(current replicas × current metric / target metric)
```

Controller применяет tolerance, readiness/missing metrics и stabilization policies, поэтому результат не обязан равняться формуле мгновенно.

## Metric choice

CPU подходит CPU-bound stateless workloads. Для queue workers лучше oldest message age/backlog per ready worker с учетом processing rate; request concurrency/latency может отражать saturation. Memory часто плохо уменьшается после load из-за heap/cache и опасна для scale-down.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 3
  maxReplicas: 30
  scaleTargetRef: {apiVersion: apps/v1, kind: Deployment, name: api}
  metrics:
    - type: Resource
      resource:
        name: cpu
        target: {type: Utilization, averageUtilization: 65}
```

## Limits и failures

Cold start + scheduling + image pull задают response lag. Scale-up может обрушить DB connection pool; total downstream concurrency ограничивайте отдельно. Scale-down drain-ит work и должен учитывать PDB/termination. Metric pipeline outage оставляет current scale, а bad external metric может oscillate — задайте min/max, stabilization и alerts.

Kubernetes 1.37 добавляет beta scale-to-zero возможности для HPA при определённых metrics/feature configuration; не полагайтесь на них без проверки cluster gates/provider и cold-start SLO.

## Источники

- [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
