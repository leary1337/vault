---
title: Паттерны конкурентности
description: Pipelines, fan-out/fan-in, worker pools и bounded lifecycle в Go.
tags: [go, concurrency, patterns]
created: 2024-07-27
updated: 2026-09-10
---

# Паттерны конкурентности

Concurrency pattern полезен, когда явно задаёт ownership, bounds, cancellation и error propagation. Схема channels без этих свойств лишь переносит leak/deadlock в production.

## Pipeline

Stage читает input, преобразует values и закрывает свой output после завершения. Downstream early exit обязан отменить upstream, иначе producer навсегда блокируется на send.

```go
func mapStage(ctx context.Context, in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for v := range in {
            select {
            case out <- v * v:
            case <-ctx.Done():
                return
            }
        }
    }()
    return out
}
```

Буфер сглаживает ограниченный burst, но не исправляет устойчивое превышение arrival rate. Размер выбирают из memory/latency budget и измерений.

## Fan-out и fan-in

Fan-out даёт нескольким workers общий input для параллельной независимой обработки. Это меняет completion order; если order важен, переносите sequence number и делайте bounded reorder или не распараллеливайте.

Fan-in объединяет outputs. Общий channel закрывается только после завершения всех forwarders:

```go
func merge[T any](ctx context.Context, inputs ...<-chan T) <-chan T {
    out := make(chan T)
    var wg sync.WaitGroup
    for _, input := range inputs {
        input := input
        wg.Go(func() {
            for v := range input {
                select {
                case out <- v:
                case <-ctx.Done():
                    return
                }
            }
        })
    }
    go func() {
        wg.Wait()
        close(out)
    }()
    return out
}
```

`WaitGroup.Go` доступен в Go 1.25+. Для более старого toolchain используйте `Add` до запуска goroutine и `defer Done`.

## Worker pool

Worker pool ограничивает concurrent expensive operations. Queue тоже bounded; при заполнении policy должна быть явной: backpressure, reject/load shed или spill в durable broker. Бесконечная in-memory queue отменяет защиту pool-а.

Количество workers выбирают по bottleneck. Для CPU-bound стартуют около доступного parallelism и измеряют; для I/O-bound учитывают latency, rate, dependency pool/limits и Little's Law. Больше workers может увеличить contention и tail latency.

## Singleflight и semaphore

Singleflight объединяет concurrent одинаковую работу, но не cache-ит результат после завершения и делает callers зависимыми от одного execution. Key должен быть bounded/correctly scoped.

Buffered channel иногда используется как semaphore, но `x/sync/semaphore` поддерживает weighted acquisition/context. Release выполняют на всех paths. Локальный semaphore не ограничивает весь fleet — нужен distributed admission или downstream quota.

## Periodic/background work

Ticker/consumer/sweeper принадлежит process component-у: owner хранит cancel, goroutine вызывает `Stop`/закрывает resources и входит в shutdown wait. Не создавайте ticker на каждый request. Jitter schedules, чтобы replicas не образовали herd.

## Failure checklist

- кто закрывает каждый channel и может ли быть double close;
- что происходит при early consumer exit;
- куда возвращается первая/несколько errors;
- кто отменяет siblings;
- ограничены ли goroutines, queue и result buffering;
- сохраняется ли нужный order/idempotency;
- завершится ли shutdown при зависшем dependency;
- какие metrics/profile покажут saturation или leak.

См. [backpressure](backpressure.md), [graceful shutdown](graceful-shutdown.md), [singleflight](../../backend-patterns/singleflight.md) и [production goroutine leak](../../production/goroutine-leak.md).

## Источники

- [Go blog: Pipelines and cancellation](https://go.dev/blog/pipelines)
- [`sync.WaitGroup`](https://pkg.go.dev/sync#WaitGroup)
- [`golang.org/x/sync/semaphore`](https://pkg.go.dev/golang.org/x/sync/semaphore)
