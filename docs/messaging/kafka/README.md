---
title: Apache Kafka
description: Архитектура, delivery semantics и эксплуатация Apache Kafka.
tags: [messaging, kafka]
updated: 2026-10-06
---

# Apache Kafka

Раздел описывает Apache Kafka 4.3.1: архитектуру KRaft, хранение записей, доставку и эксплуатацию.

Главные границы гарантий:

- ordering существует только внутри partition;
- replication не исключает потерю при любой configuration/failure;
- idempotent producer устраняет определённый класс retry duplicates, но не делает обработчик exactly-once;
- offset commit отмечает позицию, а не факт внешнего side effect.

Для новичка: broker — сервер данных; partition — упорядоченный журнал одного участка topic; offset — позиция записи; ISR — текущие синхронизированные replicas; controller — процесс управления метаданными.


## Темы

- [Consumer groups](consumer-groups.md)
- [Delivery semantics](delivery-semantics.md)
- [Kafka consumer](consumer.md)
- [Kafka producer](producer.md)
- [Kafka transactions](transactions.md)
- [KRaft](kraft.md)
- [Topics, partitions и replication](topics-partitions-replication.md)
- [Архитектура Kafka](architecture.md)
- [Эксплуатация Kafka](operations.md)

## Источники

- [Apache Kafka 4.3 documentation](https://kafka.apache.org/43/documentation/)
- [Apache Kafka 4.3.1 release](https://kafka.apache.org/blog/2026/06/25/apache-kafka-4.3.1-release-announcement/)
