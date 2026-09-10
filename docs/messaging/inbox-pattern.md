---
title: Inbox и deduplication
description: Идемпотентное применение at-least-once сообщений в базе данных.
tags: [messaging, reliability, patterns]
updated: 2026-09-10
---

# Inbox и deduplication

## Problem

At-least-once consumer может повторно получить event после crash между database commit и offset commit. Проверка «сначала SELECT, потом INSERT» race-ит между workers.

## Mechanism

В одной transaction вставьте dedup marker с unique key и выполните business change:

```sql
BEGIN;

INSERT INTO consumer_inbox(consumer_name, event_id, received_at)
VALUES ($1, $2, clock_timestamp())
ON CONFLICT DO NOTHING;

-- выполнять изменение только если INSERT добавил строку

COMMIT;
```

Удобно использовать `INSERT ... RETURNING` или affected rows. Unique `(consumer_name, event_id)` сериализует concurrent duplicates. Offset commit выполняется после commit БД; повтор безопасно увидит marker.

## Guarantees и границы

Inbox обеспечивает effectively-once effect только для изменений в той же transaction/database. HTTP call или другая БД снова создаёт dual write и требует idempotency key downstream, saga/reconciliation или собственного outbox.

Producer должен повторять тот же `event_id`, а не генерировать новый на каждой publish attempt. Dedup retention должен покрывать максимальное время Kafka retention, replay, DLQ и backup restore; ранний cleanup оживит старый duplicate.

## Trade-offs

Inbox растёт, добавляет write/index contention и lifecycle job. Иногда естественный business key или monotonic aggregate version даёт более компактную идемпотентность. Для commutative operation (`max(version)`, set membership) отдельная inbox table может не требоваться.

Poison message после permanent validation error обычно фиксируют отдельно и отправляют в DLQ; не отмечайте transient failure как успешно обработанный.

## Связанные темы

- [Kafka delivery semantics](kafka/delivery-semantics.md)
- [Transactional Outbox](transactional-outbox.md)
- [PostgreSQL transactions](../databases/postgresql/transactions.md)
