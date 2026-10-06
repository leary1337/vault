---
title: Autoscaling
description: HPA metrics, requests, stabilization и capacity limits.
tags: [containers, kubernetes, autoscaling]
updated: 2026-10-06
---

# Autoscaling

HPA изменяет количество replicas по измеренной нагрузке. Он реагирует с задержкой, поэтому минимальные replicas и защита от перегрузки нужны до scale-up.

HorizontalPodAutoscaler периодически меняет replicas scalable workload по resource, custom или external metrics. Он реагирует после load, поэтому не заменяет baseline/headroom/backpressure.

Для average CPU utilization (доля занятого ресурса за интервал) нужны CPU requests; без request metric для Pod может быть undefined. Примерная формула:

```text
desired replicas = ceil(current replicas × current metric / target metric)
```

Controller применяет tolerance, readiness/missing metrics и stabilization policies, поэтому результат не обязан равняться формуле мгновенно.

## Metric choice

CPU подходит CPU-bound stateless workloads. Для queue workers лучше oldest message age/backlog per ready worker с учетом processing rate; request concurrency/latency может отражать saturation (очередь работы, которая ждёт ресурс). Memory часто плохо уменьшается после load из-за heap/cache и опасна для scale-down.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata: {name: api}
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

Cold start + scheduling + image pull задают response lag. Scale-up может обрушить DB connection pool; total downstream concurrency ограничивайте отдельно. Scale-down должен корректно завершать work; PDB не блокирует обычное уменьшение Deployment. При недоступных metrics возможен запрет downscale; неверная external metric может вызвать колебания — задайте min/max, stabilization и alerts.

Kubernetes 1.37 добавляет beta scale-to-zero возможности для HPA при определённых metrics/feature configuration; не полагайтесь на них без проверки cluster gates/provider и cold-start SLO (цель для показателя качества сервиса).

## Формула на конкретных данных

Есть 4 replicas, текущий средний CPU utilization относительно requests — 80%, target — 50%. Формула даёт `ceil(4×80/50)=7`. Controller дополнительно применяет tolerance, отсутствующие показатели, readiness (готовность к операции или к приёму новой работы в указанном контексте) и правила стабилизации; 7 не обязано появиться мгновенно.

Если каждая replica может открыть 50 DB connections, увеличение 4→7 повышает потенциальную нагрузку 200→350. HPA не защищает лимит БД: pool/concurrency budget должен учитывать maxReplicas.

Scale-to-zero в Kubernetes 1.37 beta, default enabled через `HPAScaleToZero` на apiserver и controller-manager. Требуется хотя бы object/external metric: CPU/memory нельзя измерить у нуля Pods. Не спутайте это с ручным replicas=0 и minReplicas>0, которое деактивирует обычное регулирование.

При нескольких metrics выбирается рекомендация большего масштаба. Ошибка получения одной metric может запрещать downscale, но не обязательно запрещает upscale по другой. PDB не является защитой от удаления Pods при scale-down Deployment.

## Источники

- [Horizontal Pod Autoscaling](https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/)

## Проверь себя

1. Что даёт 80% при request=250m?
2. Почему maxReplicas считают вместе с DB pool?

<details>
<summary>Ориентиры для ответа</summary>

1. Около 200m CPU в среднем, а не 80% всей node.
2. Каждая replica добавляет свой concurrency; суммарный предел может перегрузить зависимость.

</details>
