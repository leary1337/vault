---
title: "Deployment"
description: "Deployment поддерживает нужное число взаимозаменяемых Pod и постепенно меняет версию приложения."
tags: [containers, kubernetes, deployments]
updated: 2026-10-06
---

# Deployment

Deployment поддерживает нужное число взаимозаменяемых Pod и постепенно меняет версию приложения. Он создаёт ReplicaSet для шаблона Pod; изменение шаблона создаёт новый набор, а контроллер меняет число старых и новых экземпляров.

## Постепенное обновление

`maxSurge` разрешает дополнительные Pod сверх желаемого числа. `maxUnavailable` задаёт, сколько желаемых экземпляров могут быть недоступны. `minReadySeconds` требует непрерывной готовности до признания доступным. `progressDeadlineSeconds` сообщает об остановившемся продвижении, но сам не откатывает обновление.

Readiness определяет участие в Service и доступность нового экземпляра. Liveness решает вопрос перезапуска и не заменяет готовность. Стратегия `Recreate` сначала удаляет старые Pod, допуская перерыв.

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 25%
    maxUnavailable: 0
minReadySeconds: 10
progressDeadlineSeconds: 600
```

## Совместная работа версий

Фиксируйте образ по проверенному digest, иначе одинаковый шаблон может получить другой код. Старые и новые версии должны понимать совместимые API и данные. Узлы должны выдерживать дополнительные Pod и нужный запас при отказе.

PDB ограничивает добровольные выселения, но не управляет самим обновлением Deployment и не гарантирует доступность. Правила распределения по узлам и зонам помогают избежать общего отказа; слишком строгие ограничения могут оставить Pod в Pending.

```bash
kubectl rollout status deployment/api
kubectl rollout history deployment/api
kubectl rollout undo deployment/api
```

Откат шаблона не откатывает БД. Безопаснее сначала добавить совместимое поле, обновить читателей и писателей, а удалять старое отдельно. Возврат прежнего бинарного файла не восстановит удалённые данные.

## Цельный пример API

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

Образ и путь проверки — пример контракта с приложением. Три экземпляра с surge=1 требуют ресурсов на четвёртый. При `maxUnavailable=0` без места или успешной готовности нового Pod старые нельзя убрать: обновление остановится. Автоматический откат реализует отдельная система поставки, если он нужен.

## Источники

- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## Проверь себя

1. Почему обновление может остановиться при `maxUnavailable=0`?
2. Откатит ли `rollout undo` миграцию БД?

<details>
<summary>Ответы</summary>

1. Нет места для дополнительного Pod либо новый не стал готовым.
2. Нет. Откатывается шаблон Pod, а данные требуют отдельного плана.

</details>
