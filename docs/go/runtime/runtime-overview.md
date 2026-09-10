---
title: Runtime Go
description: Граница между гарантиями языка и standard runtime implementation.
tags:
  - go
  - runtime
updated: 2026-09-10
created: 2024-07-24
---

# Runtime Go

Runtime — код, linked с программой standard Go toolchain, который реализует goroutines/channels, scheduler, memory allocation, garbage collection, panic stack unwinding, timers, network polling и взаимодействие с OS.

## Что гарантировано

Language specification и package contracts задают наблюдаемое поведение: semantics `go`, channels, `panic/recover`, memory model, `runtime` API. Программа не должна зависеть от layout `g/m/p`, размера внутренних queues, allocation thresholds или конкретного GC algorithm.

## Как реализовано в Go 1.27

- G-M-P scheduler multiplexes goroutines over OS threads.
- Platform netpoller park-ит goroutines до network readiness.
- Growable stacks уменьшают стоимость большого числа goroutines.
- Concurrent Green Tea mark-sweep GC управляет Go heap.
- Allocator использует size classes, spans и per-P caches.

Эти детали нужны для diagnostics и capacity reasoning, но перепроверяются при upgrade toolchain.

## Пакет `runtime`

Application code редко должен управлять runtime напрямую. Полезные diagnostics/API:

- `runtime.Version`, `GOOS`, `GOARCH` — build/runtime context;
- `runtime.NumGoroutine` — моментальный count, не leak detector;
- `runtime/metrics` — стабильнее и масштабируемее многих `ReadMemStats` use cases;
- `runtime.GOMAXPROCS` — явная настройка parallelism, отключающая automatic default behavior;
- `runtime.LockOSThread` — только для thread-affine OS/foreign APIs;
- `runtime.GC` — диагностический/специализированный инструмент, не регулярная оптимизация.

## Источники

- [`runtime` package](https://pkg.go.dev/runtime)
- [`runtime/metrics`](https://pkg.go.dev/runtime/metrics)
- [Go source: runtime](https://go.dev/src/runtime/)
