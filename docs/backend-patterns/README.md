---
title: Backend patterns
description: Паттерны надёжности, контроля нагрузки и согласования данных.
tags: [backend, patterns]
updated: 2026-09-10
---

# Backend patterns

Паттерн меняет свойства системы и добавляет свои failure modes. Здесь собраны способы контроля повторов, защиты от перегрузки и согласования данных.

Каждая страница отвечает на одни и те же вопросы:

- какую конкретную проблему решаем;
- что гарантирует mechanism, а что нет;
- как он отказывает и как наблюдается;
- когда дополнительная сложность не окупается.

Комбинации важнее отдельных элементов: retries без idempotency создают duplicates, retries без jitter синхронизируют storm, queue без backpressure лишь откладывает overload, circuit breaker без fallback только быстрее возвращает ошибку.


## Темы

- [Backpressure](backpressure.md)
- [Bulkhead](bulkhead.md)
- [Cache-aside](cache-aside.md)
- [Circuit breaker](circuit-breaker.md)
- [CQRS](cqrs.md)
- [Distributed locks](distributed-locks.md)
- [Exponential backoff и jitter](exponential-backoff-and-jitter.md)
- [Idempotency](idempotency.md)
- [Load shedding](load-shedding.md)
- [Rate limiting](rate-limiting.md)
- [Retries](retries.md)
- [Saga](saga.md)
- [Singleflight](singleflight.md)
- [Transactional Outbox](transactional-outbox.md)

## Связанные разделы

- [Distributed systems](../distributed-systems/README.md)
- [Messaging](../messaging/README.md)
- [Go backend](../go/backend/README.md)
