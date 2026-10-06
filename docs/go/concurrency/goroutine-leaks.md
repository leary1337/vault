---
title: Goroutine leaks
description: Как находить и предотвращать goroutines без пути завершения.
tags:
  - go
  - concurrency
  - production
updated: 2026-10-06
---

# Goroutine leaks

Утечка goroutine — работа, которая больше не нужна, но остаётся ждать или бесконечно выполняться. Она удерживает память и ссылки даже при нулевой загрузке CPU.

Leak — goroutine, которая больше не выполняет полезную работу и не может завершиться. Она удерживает stack (стек вызовов goroutine) и всё достижимое состояние; тысячи leaks приводят к росту памяти, scheduler overhead, timers и открытых connections.

## Частые причины

- Send результата после того, как receiver ушёл по timeout.
- Receive/range из channel, который никто не закроет.
- I/O без deadline/context.
- Ticker, worker или retry loop без stop path.
- Unbounded fan-out под overload.

## Диагностика

Сначала подтвердите устойчивый рост `runtime.NumGoroutine`/runtime metrics, затем сравните goroutine profiles во времени:

```bash
go tool pprof http://service/debug/pprof/goroutine
```

Группируйте stacks по blocking point и связывайте их с request rate, queue depth, dependency latency и deploy version. Snapshot без временного сравнения часто показывает нормальные long-lived workers.

Go 1.27 добавил профиль `goroutineleak`, который автоматически выявляет доказуемо permanently blocked goroutines на channels и поддержанных `sync` primitives. Он точнее обычного snapshot (снимок состояния) для этого subset, но не видит все логические leaks, foreign I/O или goroutines, чьи primitives остаются достижимы через live/global state.

## Предотвращение

- У каждой goroutine есть owner и stop condition.
- Blocking operations принимают context/deadline.
- Sends/receives в pipeline имеют cancellation branch.
- Concurrency и queue capacity ограничены.
- Shutdown test проверяет, что background components завершились.

## Минимальная утечка и исправление

```go
func publish(ctx context.Context, out chan<- int, value int) error {
	select {
	case out <- value:
		return nil
	case <-ctx.Done():
		return context.Cause(ctx)
	}
}
```

Это определение функции, нужен импорт `context`. Если никто не читает `out`, функция ждёт только до отмены. Обычный `out <- value` без второго пути удержал бы goroutine навсегда. Для чтения input требуется такой же отменяемый `select`; исправить только send недостаточно.

После теста отмены дождитесь канала `done`, который закрывает сама запущенная работа. Сравнение NumGoroutine с точным числом ненадёжно: тестовая инфраструктура тоже может запускать goroutines. Профиль goroutineleak выявляет только определённый класс невозможных пробуждений, а не любую работу, потерявшую бизнес-смысл.

## Источники

- [Go blog: Pipelines and cancellation](https://go.dev/blog/pipelines)
- [`runtime/pprof` package](https://pkg.go.dev/runtime/pprof)
- [Go 1.27: Goroutine Leak Profiles](https://go.dev/blog/goroutine-leak-profiles)

## Проверь себя

1. Почему buffer=1 не всегда исправляет утечку?
2. Как доказать в тесте, что именно worker завершился?

<details>
<summary>Ориентиры для ответа</summary>

1. Он разрешает одну отправку, но следующий send снова может навсегда заблокироваться.
2. Отменить context и дождаться его собственного done/Wait с защитным timeout.

</details>
