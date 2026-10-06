---
title: Runtime trace
description: Scheduler, blocking, syscalls и latency analysis через Go execution trace.
tags:
  - go
  - performance
  - tracing
updated: 2026-10-06
---

# Runtime trace

Trace показывает события на временной оси: когда goroutine работала, ждала и была готова. Это объясняет задержку, которую CPU profile может не показать.

Execution trace записывает runtime events: goroutine transitions, scheduler delays, syscalls, network blocking, GC и user tasks/regions. Он отвечает на вопросы, которые CPU profile не видит: почему работа runnable, но не выполняется; где goroutine blocked; как GC совпадает с latency spike.

```bash
go test -trace trace.out ./path/to/pkg
go tool trace trace.out
```

В приложении используйте `runtime/trace` на ограниченном окне. Trace имеет overhead и быстро растёт; не оставляйте неограниченный capture.

## User regions

`trace.WithRegion`, `trace.StartRegion` и `trace.NewTask` связывают application phases с runtime events. Labels должны быть bounded (с явным пределом времени, количества или размера): не превращайте каждый user ID в отдельную категорию.

## Flight recorder

Go 1.25 добавил `runtime/trace.FlightRecorder`: rolling window можно сохранить при редком incident. Настройте размер/период из memory budget и защитите dump, поскольку trace может содержать operational metadata.

## Связать время ожидания с операцией

```go
ctx, task := trace.NewTask(ctx, "load-ad")
defer task.End()
trace.WithRegion(ctx, "db-query", func() {
	result, err = repo.Find(ctx, id)
})
```

Фрагмент функции; `result`, `err`, `repo`, `id` определены приложением, нужен `runtime/trace`. Имена категорий стабильны и не содержат user ID. В просмотрщике region виден рядом с waiting/runnable/running событиями.

Если CPU свободен, а region долго ждёт channel, увеличение GOMAXPROCS не устранит задержку. Если goroutine долго runnable при занятом CPU, ищите очередь исполнения и лимиты ОС. Trace может содержать чувствительные имена/labels; храните dump как диагностический артефакт с ограниченным доступом.

## Источники

- [`runtime/trace`](https://pkg.go.dev/runtime/trace)
- [Go diagnostics: execution tracer](https://go.dev/doc/diagnostics#execution-tracer)
- [Go blog: Flight Recorder in Go 1.25](https://go.dev/blog/flight-recorder)

## Проверь себя

1. Почему CPU profile не видит всё время запроса?
2. Что искать при длинном runnable-интервале?

<details>
<summary>Ориентиры для ответа</summary>

1. Ожидание сети/lock не потребляет CPU; trace показывает эти интервалы.
2. Недостаток ресурса исполнения, CPU saturation/throttling и очереди scheduler.

</details>
