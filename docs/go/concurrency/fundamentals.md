---
title: Основы конкурентности в Go
description: Concurrency, parallelism, goroutines, synchronization и lifecycle.
tags: [go, concurrency]
created: 2024-07-27
updated: 2026-10-06
---

# Основы конкурентности в Go

Конкурентность означает несколько задач в процессе работы, параллелизм — выполнение одновременно. Например, один повар может чередовать два блюда, а два повара готовят параллельно.

Concurrency — организация нескольких независимо продвигающихся задач; parallelism — их физическое выполнение одновременно. Конкурентная программа может работать на одном P, а параллельная требует доступного execution capacity. Ни goroutine, ни channel сами по себе не устраняют races и deadlocks.

## Goroutines и scheduler

`go f()` создаёт goroutine и не ждёт её завершения. Go runtime multiplexes goroutines поверх OS threads; детали очередей и scheduling не являются fairness contract. Process завершается с возвратом `main`, даже если другие goroutines ещё живы.

Каждая goroutine должна иметь:

- owner, который решает, когда её запустить;
- termination condition/cancellation;
- bound на создаваемое количество и queued work;
- способ дождаться завершения, если результат/resource важен;
- policy обработки panic/error.

## Shared state

Если две goroutines обращаются к одной memory location, хотя бы одна пишет и нет happens-before ordering, это data race. Поведение программы с race не становится корректным от того, что тест «обычно проходит».

Выберите механизм по invariant (условие, которое должно сохраняться при любом допустимом изменении):

- mutex защищает составное mutable state;
- atomics подходят для отдельных well-defined state transitions/counters;
- channel передаёт ownership/data и синхронизирует определённые events;
- immutable (неизменяемый после создания) snapshot (снимок состояния) уменьшает shared mutation.

Channel не является автоматически быстрее mutex и не должен использоваться ради слогана. Контракт owner-а закрывает channel; receive-side обычно не закрывает чужой input. Закрытие — broadcast отсутствия будущих values, не cancellation всех goroutines.

## Cancellation и errors

`context.Context` передаётся вниз по call tree; child не увеличивает deadline parent-а. I/O operations получают context/deadline, loops выбирают cancellation вместе с send/receive. Error возвращается owner-у или агрегируется через structured group; fire-and-forget допустим только с отдельным owned lifecycle (жизненный цикл от запуска до завершения).

```go
func worker(ctx context.Context, jobs <-chan Job) error {
	for {
		select {
		case <-ctx.Done():
			return context.Cause(ctx)
		case job, ok := <-jobs:
			if !ok {
				return nil
			}
			if err := process(ctx, job); err != nil {
				return err
			}
		}
	}
}
```

## Проверка

Unit tests проверяют state transitions; `go test -race` ищет наблюдённые races, но не доказывает их отсутствие. Block/mutex/goroutine profiles и runtime trace помогают разделить contention (конкуренция за один ресурс, например lock), blocking, scheduler delay и leak. Нагрузка должна достигать steady state и затем корректно завершаться.

Продолжение: [memory model](memory-model.md), [goroutines](goroutines.md), [channels](channels.md), [sync primitives](sync-primitives.md), [context](context.md) и [patterns](patterns.md).

## Выбор механизма на примере сервиса

Для счётчика обработанных запросов достаточно atomic. Для перевода между двумя балансами один mutex защищает общий инвариант суммы. Для передачи задания работнику подходит channel, потому что нужно передать значение и управлять ожиданием. Для группы запросов к зависимостям нужен context с deadline и ожидание завершения.

Блокировка не равна потреблению CPU: goroutine может ждать сеть, канал или lock. Busy loop с `select { default: }` при пустом input, напротив, постоянно забирает CPU. Проверяйте загрузку и profiles, прежде чем увеличивать число работников.

## Источники

- [The Go Memory Model](https://go.dev/ref/mem)
- [Effective Go: concurrency](https://go.dev/doc/effective_go#concurrency)
- [`sync` package](https://pkg.go.dev/sync)

## Проверь себя

1. Можно ли конкурентно выполнить две задачи на одном P?
2. Что кроме запуска обязан решить владелец goroutine?

<details>
<summary>Ориентиры для ответа</summary>

1. Да, выполнение чередуется; физического параллелизма Go-кода на одном P нет.
2. Предел количества, отмену, получение ошибки, ожидание завершения и освобождение ресурсов.

</details>
