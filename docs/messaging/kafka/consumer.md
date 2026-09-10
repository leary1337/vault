---
title: Kafka consumer
description: Poll loop, offsets, commits, lag и poison messages.
tags: [messaging, kafka, consumer]
updated: 2026-09-10
---

# Kafka consumer

Consumer fetch-ит batches у partition leaders и отслеживает position — offset следующего record для чтения. Committed offset группы хранится отдельно и определяет, откуда возобновиться после restart/reassignment.

## Poll loop

```text
poll → process → commit next offset
```

`poll()` одновременно получает records и обслуживает group lifecycle. Если обработка дольше `max.poll.interval.ms`, coordinator может исключить member и отдать partitions другому consumer; старый worker при этом ещё способен выполнять side effect. Ограничивайте `max.poll.records`, отделяйте bounded worker pool и корректно pause/resume partitions.

Consumer обычно не thread-safe. Один owner должен управлять poll, assignment и commits; передача records workers требует координации offset по каждой partition, чтобы не commit-ить через незавершённый record.

## Offset commits

Auto commit периодически commit-ит offsets records, возвращённых предыдущими polls, а не подтверждает успешный business side effect. При crash до commit records будут повторены; commit до завершения обработки создаёт потерю для приложения.

Для at-least-once commit-ьте следующий offset только после успешной обработки всех предыдущих offsets partition. Synchronous commit проще на shutdown/rebalance; asynchronous commit быстрее, но callback может прийти out of order — старый failed commit нельзя слепо retry-ить поверх нового.

`auto.offset.reset` применяется, когда committed offset отсутствует или уже вне retention; это recovery policy (`earliest`, `latest`, `none` и актуальные варианты), а не обычный rewind.

## Lag и poison records

Offset lag приблизительно равен log end offset минус committed offset. Он не показывает возраст события, незакоммиченную работу workers или correctness. Наблюдайте records lag, time lag, consume rate, rebalance frequency и processing failures вместе.

Poison record нельзя бесконечно retry-ить в tight loop. Используйте bounded attempts/backoff, классификацию retriable/permanent, retry topics или DLQ с original topic/partition/offset/schema/error. DLQ нарушает строгий порядок и требует owner, retention, replay и alerting; это не «успешная обработка».

## Источники

- [Consumer configuration](https://kafka.apache.org/43/configuration/consumer-configs/)
- [Consumer API](https://kafka.apache.org/43/javadoc/org/apache/kafka/clients/consumer/KafkaConsumer.html)
