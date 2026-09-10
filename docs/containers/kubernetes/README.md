---
title: Kubernetes
description: Workloads, networking, resources и lifecycle Kubernetes 1.37.
tags: [containers, kubernetes]
updated: 2026-09-10
---

# Kubernetes

Раздел ориентирован на Kubernetes 1.37. Kubernetes reconciles declarative desired state; он не исправляет application semantics, плохие probes или отсутствие graceful shutdown.

Читайте: Pod → Deployment → Service/Ingress/networking → configuration/resources/probes → autoscaling/shutdown → troubleshooting. Связывайте manifests с [Linux cgroups](../../linux/cgroups.md), [Docker/container fundamentals](../docker/README.md) и runtime behavior Go.

Не копируйте YAML без проверки API version, feature gates, admission policies и конкретной реализации CNI/Ingress/CSI/cloud. Core contracts общие, data plane и extensions различаются.

## Источники

- [Kubernetes 1.37 release](https://kubernetes.io/releases/1.37/)
- [Kubernetes concepts](https://kubernetes.io/docs/concepts/)
