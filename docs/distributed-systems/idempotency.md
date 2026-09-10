---
title: Идемпотентность
description: Stable operation identity, dedup state и unknown outcomes.
tags: [distributed-systems, reliability]
updated: 2026-09-10
---

# Идемпотентность

Operation idempotent, если повтор с тем же logical intent не меняет итог после первого успешного применения. HTTP method name или retry library сами этого не обеспечивают.

## Idempotency key

Client генерирует key один раз на business operation и повторяет его при timeout. Server atomically создаёт record со scope, request fingerprint и state:

```text
(tenant, operation, idempotency_key) UNIQUE
status: processing | succeeded | failed
request_hash
response/result reference
```

Concurrent duplicate либо ждёт bounded время, либо получает `processing`; completed duplicate получает сохранённый semantically equivalent response. Тот же key с другим fingerprint — client error, а не новая operation.

Dedup record и business mutation должны commit-иться атомарно в одной database transaction. Если side effect внешний, передавайте key downstream или используйте durable workflow/outbox; иначе crash между effect и marker оставляет unknown outcome.

## Retention и scope

TTL должен покрывать максимальное retry, queue retention, offline client и replay window. После удаления key старый retry снова станет новым. Infinite retention дорого, поэтому domain identifier/state machine иногда лучше отдельного key.

Scope включают tenant/user и operation type, чтобы чужой key не collision-нул. Key — untrusted input: ограничьте длину, rate и доступ к сохранённым responses.

## Естественная идемпотентность

- `PUT resource/version` с compare-and-set;
- unique business key + `INSERT ... ON CONFLICT`;
- set membership;
- применение aggregate event только если `version = current + 1`;
- commutative `max(processed_offset, x)`.

`SET balance = 100` может быть идемпотентен по значению, `balance += 100` — нет. Но повторный `SET` всё равно может повторить audit/event side effects, поэтому определяйте наблюдаемую границу.

## Источники

- [HTTP Semantics: idempotent methods](https://www.rfc-editor.org/rfc/rfc9110.html#name-idempotent-methods)
- [Stripe idempotent requests](https://docs.stripe.com/api/idempotent_requests)
