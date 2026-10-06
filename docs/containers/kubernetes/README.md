---
title: Kubernetes
description: Workloads, networking, resources и lifecycle Kubernetes 1.37.
tags: [containers, kubernetes]
updated: 2026-10-06
---

# Kubernetes

Kubernetes поддерживает желаемое состояние: сколько экземпляров запустить, где их разместить и как направлять запросы. Это не заменяет корректный код, probes и shutdown. Baseline — Kubernetes 1.37; официальная release page на 2026-10-06 указывает patch 1.37.1. Конкретные CNI/CSI/controller и feature gates проверяют в вашем кластере.

![Компоненты Kubernetes: control plane и worker nodes](../../assets/kubernetes-components.svg)

Источник: [Kubernetes contributors](https://kubernetes.io/docs/concepts/overview/components/), лицензия [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Что делают компоненты

| Компонент | Ответственность |
|---|---|
| API server | принимает запросы, проверяет доступ и сохраняет желаемое состояние |
| etcd | хранит состояние control plane; требует backup и защиты |
| Scheduler | выбирает node для ещё не размещённого Pod |
| Controller manager | замечает расхождения и создаёт/изменяет объекты для нужного состояния |
| Kubelet | на node приводит локальные containers к заданной Pod spec |
| Container runtime | через CRI запускает и останавливает containers |
| Network plugin / Service data plane | создаёт Pod сеть и обеспечивает маршруты/Service traffic |

Control plane управляет состоянием, worker nodes запускают workload. Подтверждение API запроса не означает, что Pod уже Running: отдельные компоненты выполняют последующие действия асинхронно.

## Темы

- [Autoscaling](autoscaling.md)
- [ConfigMap и Secret](configmap-and-secret.md)
- [Deployment](deployment.md)
- [Graceful shutdown](graceful-shutdown.md)
- [Ingress](ingress.md)
- [Kubernetes networking](networking.md)
- [Kubernetes troubleshooting](troubleshooting.md)
- [Pod](pod.md)
- [Probes](probes.md)
- [Resources](resources.md)
- [Service](service.md)

## Источники

- [Kubernetes 1.37 release](https://kubernetes.io/releases/1.37/)
- [Kubernetes concepts](https://kubernetes.io/docs/concepts/)
