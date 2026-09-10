---
title: Runtime trace
description: Scheduler, blocking, syscalls и latency analysis через Go execution trace.
tags:
  - go
  - performance
  - tracing
updated: 2026-09-10
---

# Runtime trace

Execution trace записывает runtime events: goroutine transitions, scheduler delays, syscalls, network blocking, GC и user tasks/regions. Он отвечает на вопросы, которые CPU profile не видит: почему работа runnable, но не выполняется; где goroutine blocked; как GC совпадает с latency spike.

```bash
go test -trace trace.out ./path/to/pkg
go tool trace trace.out
```

В приложении используйте `runtime/trace` на ограниченном окне. Trace имеет overhead и быстро растёт; не оставляйте неограниченный capture.

## User regions

`trace.WithRegion`, `trace.StartRegion` и `trace.NewTask` связывают application phases с runtime events. Labels должны быть bounded: не превращайте каждый user ID в отдельную категорию.

## Flight recorder

Go 1.25 добавил `runtime/trace.FlightRecorder`: rolling window можно сохранить при редком incident. Настройте размер/период из memory budget и защитите dump, поскольку trace может содержать operational metadata.

## Источники

- [`runtime/trace`](https://pkg.go.dev/runtime/trace)
- [Go diagnostics: execution tracer](https://go.dev/doc/diagnostics#execution-tracer)
- [Go blog: Flight Recorder in Go 1.25](https://go.dev/blog/flight-recorder)
