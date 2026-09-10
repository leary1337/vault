---
title: Архитектура Kafka
description: Brokers, KRaft controllers, metadata, partitions и clients.
tags: [messaging, kafka, architecture]
updated: 2026-09-10
---

# Архитектура Kafka

Kafka cluster разделяет data plane и metadata control plane. Brokers хранят partition logs и обслуживают produce/fetch requests. KRaft controllers ведут replicated metadata log: topics, partition assignments, ISR, broker registrations, configs и ACL-related metadata.

## Client path

`bootstrap.servers` нужен только для первого контакта. Client получает cluster metadata и затем обращается напрямую к leader нужной partition. При смене leader или topology он обновляет metadata; bootstrap list должна содержать несколько достижимых brokers, но не обязана перечислять весь cluster.

Producer выбирает partition, отправляет batch её leader. Followers этой partition fetch-ят log у leader. Consumer fetch-ит records начиная с offset; group coordinator управляет membership и assignments, но payload читается у partition leaders.

## Partition как единица данных

Topic состоит из partitions. Каждая — ordered append-only log с offset, который уникален только внутри partition. Partition задаёт:

- предел параллелизма обычной consumer group;
- область ordering;
- leader/follower replication unit;
- единицу reassignment и recovery.

Увеличение числа partitions не бесплатно: растут metadata, open files, replication/rebalance work, а keyed data может перераспределиться при повторном хэшировании.

## Control plane

Controller quorum реплицирует metadata через Raft. Active controller применяет committed metadata и координирует leaders/ISR; остальные controllers готовы продолжить после election. Quorum требует majority, поэтому обычно используют 3 или 5 controller voters в независимых failure domains.

ZooKeeper — только historical context для Kafka 3.x и миграций. Kafka 4.x удалил ZooKeeper mode; новый дизайн и runbooks должны быть KRaft-only.

## Источники

- [Kafka design](https://kafka.apache.org/43/design/design/)
- [KRaft](https://kafka.apache.org/43/operations/kraft/)
