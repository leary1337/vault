---
title: Goroutines
description: Lifecycle, scheduling, ownership и отмена goroutines.
tags:
  - go
  - concurrency
level:
  - middle
updated: 2026-09-10
created: 2024-07-24
---

# Goroutines

Goroutine — независимо выполняемая функция, управляемая Go runtime. Это не OS thread: runtime multiplexes many goroutines over threads, а blocking syscall или network wait обрабатывается с участием scheduler/netpoller.

```go
go serve(conn)
```

`go` statement не возвращает handle, error или join operation. Lifecycle нужно спроектировать отдельно.

## Stack и стоимость

Goroutine начинает с небольшого growable stack; runtime перемещает/расширяет его по необходимости. Точные initial sizes и scheduler structures — implementation details. «Легковесная» не означает бесплатная: goroutine удерживает stack, references, timers, descriptors и связанные buffers.

## Ownership

Для каждой goroutine должно быть понятно:

- кто её запустил;
- что является входом и кто закрывает input;
- как передаётся cancellation;
- куда возвращается error;
- кто ждёт завершения;
- что ограничивает concurrency.

```go
g, ctx := errgroup.WithContext(ctx)
g.Go(func() error { return consume(ctx, jobs) })
g.Go(func() error { return report(ctx) })
return g.Wait()
```

`errgroup` не входит в standard library (`golang.org/x/sync/errgroup`), но даёт общую cancellation/error boundary.

## Blocking и cancellation

Blocked goroutine не потребляет CPU, но остаётся live. Channel operation, mutex wait, network I/O или timer должны иметь путь к завершению. Передавайте `context.Context` в blocking APIs и добавляйте cancellation branch в `select`.

```go
select {
case jobs <- job:
    return nil
case <-ctx.Done():
    return context.Cause(ctx)
}
```

## Завершение процесса

Return из `main` завершает process; runtime не ждёт остальные goroutines. Поэтому код с единственным blocked worker не является обязательным deadlock. Сервер должен остановить приём, инициировать cancellation, дождаться owned work в пределах deadline и только затем выйти.

## Panic

Panic в goroutine нельзя recover в другой goroutine. Если recovery допустима, boundary должна находиться внутри запущенной function. `WaitGroup.Go` требует, чтобы function не panic.

## Типичные ошибки

- Fire-and-forget без owner и cancellation.
- Unbounded goroutine per item.
- Send результата в channel, который никто не читает после timeout.
- Захват loop variable/изменяемого state без ясной lifetime модели.
- Использование `time.Sleep` как synchronization.

## Источники

- [Go specification: Go statements](https://go.dev/ref/spec#Go_statements)
- [The Go Memory Model: Goroutine creation/destruction](https://go.dev/ref/mem#hdr-Goroutine_creation)
- [Go blog: Pipelines and cancellation](https://go.dev/blog/pipelines)
