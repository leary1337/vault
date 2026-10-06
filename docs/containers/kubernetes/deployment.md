---
title: Deployment
description: ReplicaSet, rolling update, rollout health и rollback.
tags: [containers, kubernetes, deployments]
updated: 2026-10-06
---

# Deployment

Deployment поддерживает нужное число взаимозаменяемых Pods и постепенно заменяет версию приложения. Он управляет процессами, но не понимает безопасность миграции данных.

Deployment управляет ReplicaSets и обеспечивает declarative rollout (замена экземпляров приложения новой версией) stateless interchangeable Pods. Изменение Pod template создаёт новый ReplicaSet; controller постепенно меняет replicas.

## RollingUpdate

- `maxSurge` — сколько Pods сверх desired replicas можно создать;
- `maxUnavailable` — сколько desired Pods может быть unavailable;
- `minReadySeconds` — сколько Pod должен оставаться ready до available;
- `progressDeadlineSeconds` обнаруживает stalled rollout, но сам автоматически не rollback-ит.

Readiness определяет, получает ли Pod Service traffic и считается available. Liveness не должна использоваться как rollout readiness (готовность к операции или к приёму новой работы в указанном контексте). `Recreate` сначала удаляет старые Pods и допускает downtime.

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

PodDisruptionBudget ограничивает voluntary eviction (удаление Pod по решению платформы), но не гарантирует availability и не является механизмом управления Deployment rollout. Topology spread/anti-affinity распределяет replicas; слишком жёсткие constraints делают Pods Pending.

```bash
kubectl rollout status deployment/api
kubectl rollout history deployment/api
kubectl rollout undo deployment/api
```

Rollback code не откатывает external migration/state автоматически; нужен отдельный compatible plan.

## Цельный пример для API

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: {name: api}
spec:
  replicas: 3
  selector: {matchLabels: {app: api}}
  strategy:
    rollingUpdate: {maxSurge: 1, maxUnavailable: 0}
  template:
    metadata: {labels: {app: api}}
    spec:
      terminationGracePeriodSeconds: 45
      containers:
        - name: api
          image: registry.example/api:2026-10-06
          ports: [{name: http, containerPort: 8080}]
          resources:
            requests: {cpu: 250m, memory: 256Mi}
            limits: {cpu: "1", memory: 512Mi}
          readinessProbe:
            httpGet: {path: /health/ready, port: http}
```

Image и endpoint — пример договора с вашим приложением; в эксплуатации закрепите проверенный digest (криптографический идентификатор конкретного содержимого). Три replicas с surge=1 требуют ресурса на четвёртый Pod. Старые Pods удаляются только при достаточной availability новых.

Совместимость schema: сначала добавить nullable поле, затем обновить writers/readers, потом удалить старое в отдельном изменении. Rollback binary не восстановит удалённое поле/данные. `progressDeadlineSeconds` сообщает stalled rollout, а автоматику rollback реализует delivery-система.

## Источники

- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## Проверь себя

1. Почему rollout может зависнуть при maxUnavailable=0?
2. Откатит ли rollout undo миграцию БД?

<details>
<summary>Ориентиры для ответа</summary>

1. Нужен capacity для surge и успешная readiness нового Pod; без них нельзя убрать старый.
2. Нет, это откат Pod template; данные и schema требуют отдельного совместимого плана.

</details>
