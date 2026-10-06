---
title: Идемпотентность
description: Stable operation identity, dedup state и unknown outcomes.
tags: [distributed-systems, reliability]
updated: 2026-10-06
---

# Идемпотентность

Защита повторов связывает одно намерение с устойчивым ID, сохраняемым через все сетевые границы.

Operation idempotent (без второго эффекта при повторе одного намерения), если повтор с тем же logical intent не меняет итог после первого успешного применения. HTTP method name или retry library сами этого не обеспечивают.

## Idempotency key

Client генерирует key один раз на business operation и повторяет его при timeout. Server atomically создаёт record со scope, request fingerprint и state:

```text
(tenant, operation, idempotency_key) UNIQUE
status: processing | succeeded | failed
request_hash
response/result reference
```

Concurrent duplicate либо ждёт bounded (с явным конечным пределом) время, либо получает `processing`; completed duplicate получает сохранённый semantically equivalent response. Тот же key с другим fingerprint — client error, а не новая operation.

Dedup record и business mutation должны commit-иться атомарно в одной database transaction. Если side effect внешний, передавайте key downstream или используйте durable workflow/outbox; иначе crash между effect и marker оставляет unknown outcome.

## Retention и scope

TTL (время жизни записи) должен покрывать максимальное retry, queue retention (срок хранения), offline client и replay (повторное проигрывание сохранённых событий) window. После удаления key старый retry снова станет новым. Infinite retention дорого, поэтому domain identifier/state machine иногда лучше отдельного key.

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

## Механизм на примере

Пример: `operation_id=pay-17` создаётся клиентом, API сохраняет его, Outbox (события, сохранённые вместе с бизнес-изменением) не меняет `event_id`, consumer (потребитель работы или контракта) передаёт поставщику `pay-17`. Если каждый этап выдаёт новый ID, местная дедупликация не доказывает один внешний эффект.

Не используем trace (связь этапов одной операции) ID: у повторной HTTP-попытки может быть новый trace, а одно трассирование может содержать несколько бизнес-операций. Не используем только payload (полезное содержимое запроса или события) hash: два одинаковых перевода по 100 рублей могут быть разными намерениями.

Внешняя система без idempotency/status lookup создаёт неустранимую локально неопределённость после принятия запроса и потери ответа. Durable workflow хранит unknown и решает его сверкой/оператором; обещание exactly once без этой границы неверно.

## Проверь себя

1. Почему одинаковый payload не означает одну операцию?
2. Когда exactly-once DB effect не равен одной отправке SMS?

<details>
<summary>Ориентиры для ответа</summary>

1. Пользователь вправе дважды выполнить одно и то же действие.
2. Провайдер не участвует в транзакции и его результат мог потеряться.

</details>
