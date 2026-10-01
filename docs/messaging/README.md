---
title: Messaging
description: Брокеры сообщений и надёжная доставка событий.
tags:
  - messaging
updated: 2026-09-10
---

# Messaging

Kafka, Transactional Outbox и Inbox описывают доставку событий и границу между брокером и authoritative database.

Материалы ориентированы на Apache Kafka 4.3.1 и KRaft-only clusters. ZooKeeper упоминается только как legacy migration context.

## Темы

- [Apache Kafka](kafka/README.md)
- [Inbox и deduplication](inbox-pattern.md)
- [Transactional Outbox](transactional-outbox.md)
