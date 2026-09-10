---
title: Redis Sentinel
description: Monitoring, discovery и failover для non-clustered Redis.
tags: [databases, redis, high-availability]
updated: 2026-09-10
---

# Redis Sentinel

Sentinel добавляет monitoring, notifications, service discovery и automatic failover для primary с replicas, когда не используется Redis Cluster. Он не sharding layer и не обеспечивает synchronous replication.

## Как принимается решение

Отдельный Sentinel может признать primary субъективно недоступным (`SDOWN`). Для objective down (`ODOWN`) нужно число голосов, заданное `quorum`. Чтобы реально выполнить failover, Sentinel leader дополнительно должен получить authorization большинства известных Sentinel processes; `quorum` и majority — разные условия.

Leader выбирает подходящую replica, повышает её до primary, перенастраивает остальные replicas и публикует новую configuration. Клиенты должны получать актуальный primary через Sentinel-aware library и уметь переподключаться: старые connections/addresses не обновляются магически.

## Failure semantics

Поскольку data replication asynchronous, promoted replica может не содержать последние acknowledged writes. Старый primary в network partition может некоторое время принимать writes; после rejoin он станет replica и его divergent writes будут потеряны. Fencing внешних side effects и idempotency остаются задачей системы.

Рекомендуемый минимум — три Sentinel в независимых failure domains. Размещение Sentinel только рядом с одним Redis host не даёт осмысленного quorum при отказе зоны. NAT/port remapping и неверно объявленные addresses могут сломать discovery.

## Operations

Настройте уникальное имя monitored primary, quorum, `down-after-milliseconds`, failover timeout и parallel syncs под SLO. Проверяйте:

- доступность Sentinel quorum/majority;
- replica lag и suitability for promotion;
- события `+sdown`, `+odown`, `+switch-master`;
- поведение clients и DNS/service discovery;
- controlled failover и возврат старого primary.

Config file Sentinel изменяет сам и использует после restart; он должен быть writable и сохранён корректно.

## Источники

- [High availability with Sentinel](https://redis.io/docs/latest/operate/oss_and_stack/management/sentinel/)
