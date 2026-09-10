---
title: Backend patterns
description: Паттерны надёжности, контроля нагрузки и согласования данных.
tags: [backend, patterns]
updated: 2026-09-10
---

# Backend patterns

Паттерн — не готовое улучшение, а обмен одного failure mode на другой. Начните с [idempotency](idempotency.md), deadline-aware [retries](retries.md) и [backoff/jitter](exponential-backoff-and-jitter.md). Затем изучите защиту от перегрузки: circuit breaker, bulkhead, rate limiting, load shedding и backpressure. Data consistency patterns — Saga, Outbox, CQRS и cache-aside — требуют отдельных invariants и reconciliation.

Каждая страница отвечает на одни и те же вопросы:

- какую конкретную проблему решаем;
- что гарантирует mechanism, а что нет;
- как он отказывает и как наблюдается;
- когда дополнительная сложность не окупается.

Комбинации важнее отдельных элементов: retries без idempotency создают duplicates, retries без jitter синхронизируют storm, queue без backpressure лишь откладывает overload, circuit breaker без fallback только быстрее возвращает ошибку.

## Связанные разделы

- [Distributed systems](../distributed-systems/README.md)
- [Messaging](../messaging/README.md)
- [Go backend](../go/backend/README.md)
