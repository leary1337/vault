---
title: Idempotency
description: Безопасный повтор одной logical operation.
tags: [backend, patterns, reliability]
updated: 2026-09-10
---

# Idempotency

## Problem

После timeout client не знает, применил ли server operation. Retry может повторно списать деньги, создать заказ или отправить event.

## Mechanism

Client создаёт stable idempotency key один раз на logical operation. Server atomically связывает `(scope, key)` с request hash, status и result. Duplicate того же request получает сохранённый результат; тот же key с другим payload отклоняется.

## Guarantees

При durable dedup record и атомарности с business mutation наблюдаемый database effect выполняется один раз в retention window. Это не гарантирует exactly-once для внешних side effects без их участия.

## Failure modes

- marker commit-нулся отдельно от mutation;
- key генерируется заново на retry;
- record удалён раньше позднего retry/replay;
- concurrent request видит `processing` без recovery policy;
- response содержит секреты и доступен другому tenant из-за неверного scope.

## Trade-offs

Нужны storage, unique index, lifecycle и сохранение response/reference. Долгое retention увеличивает стоимость; короткое оживляет duplicates.

## When not to use

Для естественно idempotent read или operation с unique business key отдельная таблица может быть лишней. Если duplicate безопасен и дешевле coordination, достаточно at-least-once.

## Example

```sql
INSERT INTO idempotency(scope, key, request_hash, status)
VALUES ($1, $2, $3, 'processing')
ON CONFLICT DO NOTHING;
```

Далее mutation и перевод в `succeeded` выполняются в той же transaction. Полная модель — в [distributed idempotency](../distributed-systems/idempotency.md).
