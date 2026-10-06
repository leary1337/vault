---
title: Runtime Go
description: Граница между гарантиями языка и standard runtime implementation.
tags:
  - go
  - runtime
updated: 2026-10-06
created: 2024-07-24
---

# Runtime Go

Runtime — часть вашей программы, которая управляет goroutines, памятью и ожиданием сети. Спецификация задаёт результат, runtime определяет конкретный способ его получения.

Runtime — код, linked с программой standard Go toolchain, который реализует goroutines/channels, scheduler, memory allocation (выделение памяти), garbage collection, panic stack (стек вызовов goroutine) unwinding, timers, network polling и взаимодействие с OS.

## Что гарантировано

Language specification и package contracts задают наблюдаемое поведение: semantics `go`, channels, `panic/recover`, memory model, `runtime` API. Программа не должна зависеть от layout `g/m/p`, размера внутренних queues, allocation thresholds или конкретного GC algorithm.

## Как реализовано в Go 1.27

- G-M-P scheduler multiplexes goroutines over OS threads.
- Platform netpoller park-ит goroutines до network readiness (готовность принимать новую работу).
- Growable stacks уменьшают стоимость большого числа goroutines.
- Concurrent Green Tea mark-sweep GC управляет Go heap (куча, область хранения объектов с управляемым временем жизни).
- Allocator использует size classes, spans и per-P caches.

Эти детали нужны для diagnostics и capacity reasoning, но перепроверяются при upgrade toolchain.

## Пакет `runtime`

Application code редко должен управлять runtime напрямую. Полезные diagnostics/API:

- `runtime.Version`, `GOOS`, `GOARCH` — build/runtime context;
- `runtime.NumGoroutine` — моментальный count, не leak detector;
- `runtime/metrics` — стабильнее и масштабируемее многих `ReadMemStats` use cases;
- `runtime.GOMAXPROCS(n)` — при `n > 0` ручная настройка parallelism, отключающая automatic updates; при `n <= 0` чтение текущего значения;
- `runtime.LockOSThread` — только для thread-affine OS/foreign APIs;
- `runtime.GC` — диагностический/специализированный инструмент, не регулярная оптимизация.

## Снять контекст диагностики

```go
fmt.Println(runtime.Version(), runtime.GOOS, runtime.GOARCH)
fmt.Println("goroutines:", runtime.NumGoroutine())
fmt.Println("Go parallelism:", runtime.GOMAXPROCS(0))
```

Фрагмент внутри `main`, нужны `fmt`, `runtime`. Конкретные числа зависят от окружения. `GOMAXPROCS(0)` читает настройку, а не устанавливает нулевой parallelism. При incident сохраняйте эти данные вместе с версиями dependency, traffic и лимитами container: одинаковый код может иметь разные scheduling/GC условия.

Рост goroutines на 1000 может быть нормальным после открытия 1000 streams. Оценивайте, остаются ли они после закрытия streams и какая работа удерживает их. Runtime метрика — наблюдение, а объяснение требует lifecycle (жизненный цикл от запуска до завершения) приложения.

## Источники

- [`runtime` package](https://pkg.go.dev/runtime)
- [`runtime/metrics`](https://pkg.go.dev/runtime/metrics)
- [Go source: runtime](https://go.dev/src/runtime/)

## Проверь себя

1. Можно ли выводить leak только из NumGoroutine?
2. Какие детали runtime нельзя считать контрактом языка?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, нужны trend, нагрузка, stacks и ожидаемый lifecycle.
2. Внутренние queues, размеры stacks/spans, layout descriptors, стратегия GC и scheduling.

</details>
