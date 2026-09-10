---
title: Kafka transactions
description: Transactional producer, read_committed и consume-transform-produce.
tags: [messaging, kafka, transactions]
updated: 2026-09-10
---

# Kafka transactions

Kafka transaction атомарно помечает набор writes в нескольких topic partitions и, при processing pipeline, offsets consumer group. Она не включает внешнюю database.

## Producer lifecycle

Producer получает стабильный уникальный `transactional.id`, вызывает initialization, затем для каждой unit of work:

```text
beginTransaction
send records
sendOffsetsToTransaction(offsets, group metadata)
commitTransaction
```

При ошибке transaction abort-ится и input offsets не продвигаются. Broker выдаёт producer ID/epoch; новый instance с тем же `transactional.id` fence-ит старый, что защищает от zombie producer. Поэтому ID должен быть уникален для одновременно работающего application instance/partition of work, но стабилен через restart для recovery.

## Consumer visibility

`read_uncommitted` видит обычные и transactional records до commit marker и пропускает aborted records по API semantics не так, как нужно EOS pipeline. `read_committed` возвращает только committed records и ограничивает чтение Last Stable Offset; открытая долгая transaction может удерживать видимость последующих records partition.

## Timeouts и errors

Transaction должна завершиться до broker `transaction.timeout.ms`; слишком длинная обработка повышает latency, удерживает LSO и усложняет retry. Некоторые errors retriable, другие требуют abort, пересоздание producer или остановку из-за fencing — используйте client library classification, а не retry любого exception.

## Граница atomicity

Сценарий «записать PostgreSQL и publish Kafka» остаётся dual write: Kafka transaction не координирует commit БД. Используйте [transactional outbox](../transactional-outbox.md), CDC или idempotent reconciliation. Аналогично external API side effect требует idempotency/inbox.

## Источники

- [Kafka transactions design](https://kafka.apache.org/43/design/design/#transactions)
- [Producer API transactions](https://kafka.apache.org/43/javadoc/org/apache/kafka/clients/producer/KafkaProducer.html)
