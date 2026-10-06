---
title: Apache Kafka
description: Потоки сообщений, повторы, границы сохранности и эксплуатация Kafka.
tags: [messaging, kafka]
updated: 2026-10-06
---

# Apache Kafka

Kafka хранит записи для одного или нескольких независимых получателей. В разделе рассматривается версия 4.3.1: устройство KRaft, поток сообщений, повторы и эксплуатация.

[Архитектура](architecture.md) показывает роли серверов. [Потоки, части и копии Kafka](topics-partitions-replication.md) объясняют порядок и сохранность. [Отправитель Kafka](producer.md) и [Получатель Kafka](consumer.md) разбирают подтверждения и позиции. [Гарантии доставки](delivery-semantics.md) объясняют результат падения между шагами.

Порядок гарантирован внутри одной части, а не всего кластера. Защита отправителя от сетевого повтора не предотвращает второе списание в PostgreSQL. Позиция чтения тоже не является подтверждением внешней операции. Эти различия подробно разобраны на примерах.

## Темы

- [Группы получателей](consumer-groups.md)
- [Гарантии доставки](delivery-semantics.md)
- [Получатель Kafka](consumer.md)
- [Отправитель Kafka](producer.md)
- [Транзакции Kafka](transactions.md)
- [KRaft](kraft.md)
- [Потоки, части и копии Kafka](topics-partitions-replication.md)
- [Архитектура Kafka](architecture.md)
- [Эксплуатация Kafka](operations.md)

## Источники

- [Apache Kafka 4.3 documentation](https://kafka.apache.org/43/documentation/)
- [Apache Kafka 4.3.1 release](https://kafka.apache.org/blog/2026/06/25/apache-kafka-4.3.1-release-announcement/)
