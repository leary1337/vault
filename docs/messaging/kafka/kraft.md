---
title: KRaft
description: Controller quorum и metadata log в Kafka 4.x.
tags: [messaging, kafka, kraft]
updated: 2026-09-10
---

# KRaft

KRaft — metadata quorum Kafka на основе Raft. Начиная с Kafka 4.0 ZooKeeper mode удалён: production baseline — KRaft.

## Roles

Process имеет `broker`, `controller` или обе roles. Combined mode удобен для local development и малых окружений; для critical production controllers обычно выделяют отдельно, чтобы data-plane load/failure не затрагивал quorum.

Каждый node имеет уникальный `node.id`; controllers образуют quorum. Active controller — leader metadata partition, остальные voters реплицируют log. Metadata change считается committed после majority, поэтому quorum из трёх переносит отказ одного voter, из пяти — двух. Два controllers не дают полезной majority fault tolerance.

Dynamic controller quorum в актуальных Kafka позволяет менять voters через поддерживаемые administrative procedures. Не редактируйте quorum configuration/metadata files вручную; следуйте upgrade documentation конкретной версии.

## Metadata log

Metadata records хранятся в internal `__cluster_metadata` log; snapshots ускоряют recovery, но log остаётся source of changes. Brokers регистрируются и получают metadata images/updates от controllers. Fencing epochs не позволяет старому broker/controller продолжать работу как актуальный после смены состояния.

Storage directories перед первым стартом форматируются единым cluster ID. Повторное случайное форматирование уничтожает локальную identity/metadata; cluster ID и disaster-recovery procedure должны быть сохранены.

## Operations

Наблюдайте active controller, quorum leader/epoch, voter lag, metadata log end offset, commit latency, offline partitions и broker heartbeats. Controller majority loss останавливает metadata changes/elections и в зависимости от события нарушает доступность data plane.

ZooKeeper-to-KRaft migration относится только к legacy upgrade path до Kafka 4.x. Не добавляйте ZooKeeper в новую architecture «на всякий случай».

## Источники

- [KRaft operations](https://kafka.apache.org/43/operations/kraft/)
- [KRaft configuration](https://kafka.apache.org/43/configuration/kraft/)
