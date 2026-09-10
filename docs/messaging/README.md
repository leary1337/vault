---
title: Messaging
description: Брокеры сообщений и надёжная доставка событий.
tags:
  - messaging
updated: 2026-09-10
---

# Messaging

Начните с [архитектуры Kafka](kafka/README.md) и проследите полный путь record от producer до consumer. Затем разберите [Transactional Outbox](transactional-outbox.md) и [Inbox](inbox-pattern.md): они закрывают границу между Kafka и authoritative database, которую не охватывает Kafka exactly-once semantics.

Материалы ориентированы на Apache Kafka 4.3.1 и KRaft-only clusters. ZooKeeper упоминается только как legacy migration context.
