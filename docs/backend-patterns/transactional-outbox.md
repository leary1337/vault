---
title: Transactional Outbox
description: Atomic business change и intent to publish.
tags: [backend, patterns, messaging]
updated: 2026-10-06
---

# Transactional Outbox


Outbox (события, сохранённые вместе с бизнес-изменением) — строка с намерением отправить событие, записанная в одной транзакции с бизнес-изменением.

## Проблема

Database commit (фиксация результата, который считается подтверждённым) и message publish — dual write: crash между ними даёт потерянное событие или событие о rollback-нутом состоянии.

## Как работает

Business row и outbox event вставляются в одной local transaction. Relay публикует rows через polling или CDC, затем продвигает durable position/mark. Event ID создаётся до transaction и остаётся тем же при retry.

## Гарантии и границы

Committed change имеет committed intent-to-publish; rollback (отмена локальной транзакции или возврат старой версии) не оставляет event. Relay обычно доставляет at least once, поэтому duplicate остаётся частью контракта.

## Ошибки и отказы

- publish успешен, mark/offset потерян — duplicate;
- relay lag превышает SLO/retention;
- outbox table/replication slot растёт до disk exhaustion;
- несколько relays нарушают per-aggregate order;
- schema event не совместима с consumers;
- cleanup удаляет данные до replay/recovery.

## Компромиссы

Polling проще и database-heavy; CDC уменьшает queries, но добавляет connector/log operations. Outbox увеличивает write/storage и требует ownership (владение данными или ответственность за ресурс), cleanup, lag alerts и reconciliation (сверка и устранение расхождений).

## Когда не применять

Kafka-to-Kafka pipeline может использовать Kafka transaction. Если событие best-effort и loss восполняется регулярной reconciliation, полный outbox может не окупиться.

## Пример

В PostgreSQL transaction обновите order и вставьте `(event_id, aggregate_id, type, payload)`. Relay публикует с key=`aggregate_id`; consumer (потребитель работы или контракта) использует Inbox (записи уже применённых событий для защиты от повторов) unique key. Подробная реализация: [Messaging / Transactional Outbox](../messaging/transactional-outbox.md).

## Разобранный пример

Сценарий: commit объявления и события завершён; relay отправил event e17; ответ publish потерян; relay повторяет e17. Consumer хранит e17 в inbox вместе со своим изменением. Получить повтор — штатно, не значит сломать relay.

`SKIP LOCKED` помогает нескольким relay разобрать строки без ожидания, но не гарантирует порядок: worker A взял v7 и задержался, B опубликовал v8 раньше. Для строгого порядка назначаем владельца по aggregate shard (часть данных у отдельного владельца) и последовательную обработку, либо consumer обнаруживает пропуск и восстанавливает его. Для событий полного состояния достаточно не откатывать более новую версию; для дельт пропускать версию нельзя.

Чистим Outbox после подтверждения доставки и согласованного окна восстановления. Время создания не всегда задаёт commit order: две транзакции могут завершиться в обратном порядке. [PostgreSQL locking](https://www.postgresql.org/docs/18/explicit-locking.html).

## Источник механизма

[Debezium: Outbox Event Router](https://debezium.io/documentation/reference/stable/transformations/outbox-event-router.html). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Что атомарно гарантирует Outbox?
2. Почему несколько relay нарушают порядок?

<details>
<summary>Ориентиры для ответа</summary>

1. Бизнес-изменение и намерение публикации в одной локальной БД.
2. Взятые раньше строки могут публиковаться позже из-за независимых workers.

</details>
