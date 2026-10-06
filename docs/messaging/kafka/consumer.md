---
title: Kafka consumer
description: Poll loop, offsets, commits, lag и poison messages.
tags: [messaging, kafka, consumer]
updated: 2026-10-06
---

# Kafka consumer

Consumer читает записи и отдельно сохраняет позицию продолжения. Commit offset не выполняет бизнес-операцию и не подтверждает её автоматически: правильный порядок задаёт приложение.

Consumer fetch-ит batches у partition leaders и отслеживает position — offset следующего record для чтения. Committed offset группы хранится отдельно и определяет, откуда возобновиться после restart/reassignment.

## Poll loop

```text
poll → process → commit next offset
```

`poll()` одновременно получает records и обслуживает group lifecycle. Если обработка дольше `max.poll.interval.ms`, coordinator может исключить member и отдать partitions другому consumer; старый worker при этом ещё способен выполнять side effect. Ограничивайте `max.poll.records`, отделяйте bounded worker pool и корректно pause/resume partitions.

Consumer обычно не thread-safe. Один owner должен управлять poll, assignment и commits; передача records workers требует координации offset по каждой partition, чтобы не commit-ить через незавершённый record.

## Сохранение позиции чтения

Auto commit периодически commit-ит offsets records, возвращённых предыдущими polls, а не подтверждает успешный business side effect. При crash до commit records будут повторены; commit до завершения обработки создаёт потерю для приложения.

Для at-least-once commit-ьте следующий offset только после успешной обработки всех предыдущих offsets partition. Synchronous commit проще на shutdown/rebalance; asynchronous commit быстрее, но callback может прийти out of order — старый failed commit нельзя слепо retry-ить поверх нового.

`auto.offset.reset` применяется, когда committed offset отсутствует или уже вне retention; это recovery policy (`earliest`, `latest`, `none` и актуальные варианты), а не обычный rewind.

## Отставание и необрабатываемые записи

Offset lag приблизительно равен log end offset минус committed offset. Он не показывает возраст события, незакоммиченную работу workers или correctness. Наблюдайте records lag, time lag, consume rate, rebalance frequency и processing failures вместе.

Poison record нельзя бесконечно retry-ить в tight loop. Используйте bounded attempts/backoff, классификацию retriable/permanent, retry topics или DLQ с original topic/partition/offset/schema/error. DLQ нарушает строгий порядок и требует owner, retention, replay и alerting; это не «успешная обработка».

## Параллельные workers и дырка

Из одной partition получили offsets 10,11,12. Worker 12 закончил первым, 11 вторым, 10 ещё работает. Максимальный завершённый offset равен 12, но безопасный committed offset остаётся 10: restart обязан повторить незавершённую запись 10.

| Завершены | Можно commit next offset |
| --- | --- |
| Только 12 | 10 |
| 11 и 12 | 10 |
| 10,11,12 | 13 |

Пример предполагает, что до 10 уже обработан весь префикс. Храните завершения per-partition и продвигайте только непрерывную границу. Offset указывается как **следующий**, не последний обработанный.

```properties
# Java consumer: явное управление обработкой
enable.auto.commit=false
isolation.level=read_committed
max.poll.records=100
```

Эти settings не являются универсальным Go API. Библиотека может автоматически хранить offsets при выдаче callback; проверяйте её store/commit semantics. poll lifecycle относится к Java consumer, а у Go clients свой поток fetching/heartbeat и политика rebalance.

При revocation прекратите новые задачи partition, дождитесь ограниченного числа in-flight или отмените их и commit только успешный префикс. Старый worker способен записать side effect после потери assignment: БД inbox защищает от повторов, а порядок по entity может требовать version predicate. Отмена context сама не откатывает уже завершённый HTTP эффект.

## Источники

- [Consumer configuration](https://kafka.apache.org/43/configuration/consumer-configs/)
- [Consumer API](https://kafka.apache.org/43/javadoc/org/apache/kafka/clients/consumer/KafkaConsumer.html)

## Проверь себя

1. **Почему нельзя commit max completed offset?**

   <details>
   <summary>Ответ</summary>

   Ниже может оставаться незавершённая запись; restart пропустит её.

   </details>

2. **Последняя обработанная запись 42: что commit?**

   <details>
   <summary>Ответ</summary>

   43 при успешно обработанном полном префиксе этой partition.

   </details>
