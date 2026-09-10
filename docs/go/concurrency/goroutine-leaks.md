---
title: Goroutine leaks
description: Как находить и предотвращать goroutines без пути завершения.
tags:
  - go
  - concurrency
  - production
updated: 2026-09-10
---

# Goroutine leaks

Leak — goroutine, которая больше не выполняет полезную работу и не может завершиться. Она удерживает stack и всё достижимое состояние; тысячи leaks приводят к росту памяти, scheduler overhead, timers и открытых connections.

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

Go 1.27 добавил профиль `goroutineleak`, который автоматически выявляет доказуемо permanently blocked goroutines на channels и поддержанных `sync` primitives. Он точнее обычного snapshot для этого subset, но не видит все логические leaks, foreign I/O или goroutines, чьи primitives остаются достижимы через live/global state.

## Предотвращение

- У каждой goroutine есть owner и stop condition.
- Blocking operations принимают context/deadline.
- Sends/receives в pipeline имеют cancellation branch.
- Concurrency и queue capacity ограничены.
- Shutdown test проверяет, что background components завершились.

## Источники

- [Go blog: Pipelines and cancellation](https://go.dev/blog/pipelines)
- [`runtime/pprof` package](https://pkg.go.dev/runtime/pprof)
- [Go 1.27: Goroutine Leak Profiles](https://go.dev/blog/goroutine-leak-profiles)
