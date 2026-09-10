---
title: Transactional Outbox
description: Надёжная публикация события вместе с изменением бизнес-данных.
tags: [messaging, reliability, patterns]
updated: 2026-09-10
---

# Transactional Outbox

## Problem

Последовательность `COMMIT database → publish event` теряет event при crash между шагами. Обратный порядок публикует event о transaction, которая затем rollback-нулась. Distributed transaction часто недоступна или непропорциональна задаче.

## Mechanism

В одной local database transaction измените aggregate и вставьте outbox row:

```sql
BEGIN;
UPDATE orders SET status = 'paid' WHERE id = $1;
INSERT INTO outbox(event_id, aggregate_id, event_type, payload, created_at)
VALUES ($2, $1, 'order.paid.v1', $3, clock_timestamp());
COMMIT;
```

Отдельный relay публикует pending rows. Варианты:

- polling publisher выбирает batches (`FOR UPDATE SKIP LOCKED`), публикует и помечает sent;
- CDC читает WAL/change log и преобразует outbox inserts в events, например через Debezium.

## Guarantees и failure modes

Atomicity БД гарантирует: business change и intent-to-publish существуют вместе. Но relay crash после publish до mark/offset создаёт duplicate. Поэтому `event_id` стабилен, producer/consumer идемпотентны, а outbox cleanup хранит данные дольше максимального retry/replay window.

Polling проще контролировать, но добавляет queries/locking и latency. CDC снижает polling load и сохраняет log order в своей области, но добавляет connector, schema mapping, replication slot retention и сложный recovery.

Ordering требует явного aggregate key и стратегии нескольких relay workers. «Глобальный порядок commit» обычно не нужен и дорог.

## When not to use

Если операция целиком Kafka-to-Kafka, Kafka transaction проще. Если потеря уведомления допустима и есть reconciliation job, outbox может быть избыточен. Не используйте outbox как бесконечный event store без отдельного retention/contract design.

## Источники

- [Debezium outbox event router](https://debezium.io/documentation/reference/stable/transformations/outbox-event-router.html)
- [PostgreSQL SKIP LOCKED](https://www.postgresql.org/docs/18/sql-select.html#SQL-FOR-UPDATE-SHARE)
