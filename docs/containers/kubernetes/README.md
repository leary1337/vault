---
title: Kubernetes
description: Workloads, networking, resources и lifecycle Kubernetes 1.37.
tags: [containers, kubernetes]
updated: 2026-09-10
---

# Kubernetes

Раздел ориентирован на Kubernetes 1.37. Kubernetes reconciles declarative desired state; он не исправляет application semantics, плохие probes или отсутствие graceful shutdown.

Не копируйте YAML без проверки API version, feature gates, admission policies и конкретной реализации CNI/Ingress/CSI/cloud. Core contracts общие, data plane и extensions различаются.


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
