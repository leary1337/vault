---
title: Retries в System Design
description: Placement, budgets, idempotency и deadline allocation.
tags: [system-design, reliability]
updated: 2026-09-10
---

# Retries в System Design

Retry — дополнительная нагрузка и latency, поэтому его placement входит в architecture. Три attempts на каждом из трёх вложенных layers могут породить до 27 downstream attempts.

## Политика

- retry только transient/retriable outcome;
- одна logical operation сохраняет idempotency key;
- один ответственный layer, остальные возвращают классифицированную ошибку;
- per-attempt timeout укладывается в propagated overall deadline;
- exponential backoff + jitter + `Retry-After`;
- max attempts/elapsed time и global retry budget;
- circuit breaker/load shedding при массовом failure.

Hedged request снижает tail чтения, отправляя дополнительный attempt после percentile delay, но умножает load и требует cancel loser; не применяйте к unsafe writes.

## Ambiguous outcome

Timeout означает «client перестал ждать», не «server отменил». Для create/payment нужны idempotency/status lookup. Для DB serialization/deadlock повторяют всю transaction после rollback, а не один последний statement.

Наблюдайте attempts per logical request, recovered success, added latency/load и final errors. Chaos/load test должен доказать, что retry policy помогает при небольшом fault и выключается при outage. Подробнее: [retries pattern](../../backend-patterns/retries.md).
