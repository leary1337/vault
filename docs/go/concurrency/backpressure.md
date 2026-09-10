---
title: Backpressure
description: Ограничение очередей и скорости producer в конкурентных Go-системах.
tags:
  - go
  - concurrency
  - production
updated: 2026-09-10
---

# Backpressure

Backpressure не даёт producer бесконечно опережать consumer. Без неё overload превращается в рост goroutines/queue memory и tail latency, а затем — в timeout storm или OOM.

## Механизмы

- Bounded channel: producer blocks или выбирает явную drop/reject policy.
- Semaphore: ограничивает число concurrent operations.
- Admission control/rate limit: отклоняет работу до дорогих allocations.
- Pull model: consumer забирает работу по доступной capacity.

```go
select {
case queue <- job:
    return nil
case <-ctx.Done():
    return context.Cause(ctx)
default:
    return ErrOverloaded
}
```

`default` здесь реализует rejection, а не ожидание. Выбор block/drop/reject должен быть частью API: для HTTP это может быть `429`/`503`, для Kafka — пауза consumption с учётом rebalance и processing deadlines.

## Что измерять

Queue depth и age oldest item, admission/rejection rate, active workers, service time, end-to-end latency, timeouts и dependency saturation. Размер buffer подбирают из latency/memory budget, а не чтобы «пережить любой spike».

## Failure modes

- Большой buffer скрывает overload до резкого обвала.
- Semaphore, взятый после allocation/DB connection, слишком поздно ограничивает дорогой ресурс.
- Retry rejected work без jitter создаёт feedback loop.
- Общий pool позволяет одному tenant занять всю capacity; нужен fairness/partitioning.

## Источники

- [Go blog: Pipelines and cancellation](https://go.dev/blog/pipelines)
- [`golang.org/x/sync/semaphore`](https://pkg.go.dev/golang.org/x/sync/semaphore)
