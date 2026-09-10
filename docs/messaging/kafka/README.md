---
title: Apache Kafka
description: Архитектура, delivery semantics и эксплуатация Apache Kafka.
tags: [messaging, kafka]
updated: 2026-09-10
---

# Apache Kafka

Раздел описывает Apache Kafka 4.3.1: current architecture работает только в KRaft mode. Начните с [архитектуры](architecture.md), [topics и partitions](topics-partitions-replication.md), затем пройдите producer и consumer path, delivery semantics и transactions. [Operations](operations.md) связывает эти модели с production signals.

Главные границы гарантий:

- ordering существует только внутри partition;
- replication не исключает потерю при любой configuration/failure;
- idempotent producer устраняет определённый класс retry duplicates, но не делает обработчик exactly-once;
- offset commit отмечает позицию, а не факт внешнего side effect.

Старая монолитная заметка удалена после тематического rewrite; при необходимости она восстановима из Git history и не является вторым source of truth.

## Источники

- [Apache Kafka 4.3 documentation](https://kafka.apache.org/43/documentation/)
- [Apache Kafka 4.3.1 release](https://kafka.apache.org/blog/2026/06/25/apache-kafka-4.3.1-release-announcement/)
