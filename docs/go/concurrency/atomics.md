---
title: Atomics
description: Typed atomics, atomic.Pointer и границы lock-free state в Go.
tags:
  - go
  - concurrency
  - atomics
updated: 2026-09-10
---

# Atomics

`sync/atomic` предоставляет indivisible operations и synchronization для простого shared state. Все Go atomic operations ведут себя как один sequentially consistent order.

Предпочитайте typed wrappers: `atomic.Bool`, `Int32`, `Int64`, `Uint32`, `Uint64`, `Uintptr`, `Pointer[T]`.

```go
type Metrics struct {
    requests atomic.Uint64
}

func (m *Metrics) Inc() { m.requests.Add(1) }
func (m *Metrics) Load() uint64 { return m.requests.Load() }
```

## Compare-and-swap

CAS обновляет state только если наблюдаемое значение совпадает с expected. Цикл CAS должен повторно вычислять новый state из свежего old value и иметь понятную progress/contention model.

```go
for {
    old := state.Load()
    if state.CompareAndSwap(old, old|flagReady) {
        break
    }
}
```

## `atomic.Pointer[T]`

Подходит для immutable snapshots. Сначала полностью создайте object, затем `Store`. После publication не меняйте его без отдельной synchronization.

Atomics не объединяют несколько fields в транзакцию. Если invariant включает balance и version, два atomic variables допускают несогласованные snapshots; mutex обычно корректнее.

## Ограничения

- Не смешивайте atomic и ordinary access к одной variable.
- Проверяйте alignment/тип через typed atomic; не копируйте atomic values после использования.
- Lock-free не означает wait-free и не гарантирует лучшую latency под contention.
- False sharing между hot atomics может создавать cache-line contention; layout tuning требует measurement и привязано к platform/implementation.

## Источники

- [`sync/atomic` package](https://pkg.go.dev/sync/atomic)
- [The Go Memory Model: Atomic values](https://go.dev/ref/mem#hdr-Atomic_Values)
