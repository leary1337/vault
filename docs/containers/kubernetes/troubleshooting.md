---
title: "Диагностика Kubernetes"
description: "До удаления Pod сохраните его состояние, события и прошлые логи."
tags: [containers, kubernetes, troubleshooting]
updated: 2026-10-06
---

# Диагностика Kubernetes

До удаления Pod сохраните его состояние, события и прошлые логи. Перезапуск меняет условия и может убрать причину. Зафиксируйте время, пространство имён, приложение, версию и пользовательский эффект.

## 1. Желаемая версия и обновление

```bash
kubectl get deploy,rs,pod -n <ns> -o wide
kubectl rollout status deploy/<name> -n <ns>
kubectl describe deploy/<name> -n <ns>
```

Проверьте образ и digest, число экземпляров, условия и правила обновления. Отличайте желаемый шаблон от реально запущенной версии.

## 2. Размещение и состояние Pod

```bash
kubectl describe pod/<pod> -n <ns>
kubectl get events -n <ns> --sort-by=.metadata.creationTimestamp
kubectl get pod/<pod> -n <ns> -o yaml
```

Для Pending смотрите requests, разрешённые узлы, запреты, квоты, тома и скачивание образа. CrashLoopBackOff — пауза после падений: нужна причина завершения. OOMKilled ведёт к проверке памяти cgroup, Evicted — ресурсов узла. События могут истекать и объединяться.

## 3. Логи и процесс

```bash
kubectl logs <pod> -c <container> -n <ns> --since=30m
kubectl logs <pod> -c <container> -n <ns> --previous
kubectl top pod <pod> -n <ns> --containers
kubectl debug -it <pod> -n <ns> --image=<approved-debug-image> --target=<container>
```

Ограничивайте права диагностического контейнера и не выводите секреты. Текущий контейнер мог ещё ничего не записать, поэтому нужен прошлый запуск.

## 4. Сетевой путь

```bash
kubectl get svc,endpointslice -n <ns>
kubectl get networkpolicy -n <ns>
kubectl run net-debug --rm -it -n <ns> --image=<approved-debug-image> -- sh
```

Проверьте DNS, EndpointSlices и готовность, затем TCP, TLS и HTTP/gRPC. Port-forward обходит часть реальной сети и не доказывает исправность Service или Ingress.

## Причина предыдущего запуска

```bash
kubectl get pod api-abc -n app -o jsonpath='{.status.containerStatuses[*].lastState.terminated}'
kubectl logs api-abc -n app -c api --previous
kubectl describe pod api-abc -n app
```

Имена условны. Если причина — OOMKilled, изучайте память и её профиль. Если приложение сообщает о неверной конфигурации, проверьте версию настроек и проекцию, а не увеличивайте задержку liveness. Если событие говорит `Insufficient cpu`, проблема в размещении: оптимизация одного обработчика не изменит запрос ресурсов.

## Узел и завершение расследования

Если проблема затронула несколько приложений на одном узле или в зоне, проверьте условия узла, нехватку ресурсов, kubelet, среду контейнеров, сеть CNI и хранилище CSI. Передавайте оператору конкретные времена, UID и признаки.

`kubectl top` зависит от системы метрик и не показывает все пики. Логи и события имеют срок хранения: сохраняйте UID и версию вместе с временем. Временный откат или рост числа Pod отделяйте от причины. Проверяйте исправление тем же показателем и обновляйте описание действий.

## Источники

- [Troubleshooting applications](https://kubernetes.io/docs/tasks/debug/debug-application/)
- [Troubleshooting clusters](https://kubernetes.io/docs/tasks/debug/debug-cluster/)

## Проверь себя

1. Зачем `--previous` у логов?
2. Доказывает ли успешный port-forward исправность Ingress?

<details>
<summary>Ответы</summary>

1. Причина падения может быть в уже завершённом запуске.
2. Нет: он обходит часть внешнего пути.

</details>
