---
title: Atomics
description: Typed atomics, atomic.Pointer и границы lock-free state в Go.
tags:
  - go
  - concurrency
  - atomics
updated: 2026-10-06
---

# Atomics

Атомарная операция неделимо читает или меняет одно значение. Она подходит для счётчика или публикации готового снимка, но не заменяет защиту сложного состояния.

`sync/atomic` предоставляет indivisible operations и synchronization для простого shared state. Все Go atomic operations ведут себя как один sequentially consistent order.

Предпочитайте typed wrappers: `atomic.Bool`, `Int32`, `Int64`, `Uint32`, `Uint64`, `Uintptr`, `Pointer[T]`.

```go
type Metrics struct {
	requests atomic.Uint64
}

func (m *Metrics) Inc()         { m.requests.Add(1) }
func (m *Metrics) Load() uint64 { return m.requests.Load() }
```

## Compare-and-swap

CAS (compare-and-swap, условное атомарное обновление) обновляет state только если наблюдаемое значение совпадает с expected. Цикл CAS должен повторно вычислять новый state из свежего old value и иметь понятную progress/contention model.

```go
for {
	old := state.Load()
	if state.CompareAndSwap(old, old|flagReady) {
		break
	}
}
```

## `atomic.Pointer[T]`

Подходит для immutable (неизменяемый после создания) snapshots. Сначала полностью создайте object, затем `Store`. После publication не меняйте его без отдельной synchronization.

Atomics не объединяют несколько fields в транзакцию. Если invariant (условие, которое должно сохраняться при любом допустимом изменении) включает balance и version, два atomic variables допускают несогласованные snapshots; mutex обычно корректнее.

## Ограничения

- Не смешивайте atomic и ordinary access к одной variable.
- Проверяйте alignment/тип через typed atomic; не копируйте atomic values после использования.
- Lock-free не означает wait-free и не гарантирует лучшую latency под contention (конкуренция за один ресурс, например lock).
- False sharing между hot atomics может создавать cache-line contention; layout tuning требует measurement и привязано к platform/implementation.

## Почему atomic-счётчики не защищают перевод денег

Пусть `A=100`, `B=0`. Два вызова `A.Add(-10)` и `B.Add(10)` атомарны каждый по отдельности. Читатель между ними увидит сумму 90. Если сумма должна всегда быть 100, весь перевод и чтение пары должны происходить под одним mutex или через публикацию одного неизменяемого снимка.

CAS-цикл допускает повтор вычисления, поэтому не помещайте в вычисляемую часть отправку письма или другую побочную операцию. При неудачном CAS она могла бы выполниться несколько раз. ABA означает, что значение успело стать A→B→A: равенство указателя само по себе не подтверждает прежнюю логическую версию.

## Источники

- [`sync/atomic` package](https://pkg.go.dev/sync/atomic)
- [The Go Memory Model: Atomic values](https://go.dev/ref/mem#hdr-Atomic_Values)

## Проверь себя

1. Что защищает atomic.Pointer: указатель или поля объекта?
2. Почему две atomic-переменные не дают транзакцию?

<details>
<summary>Ориентиры для ответа</summary>

1. Смена указателя атомарна; последующие изменения объекта нуждаются в собственной синхронизации.
2. Между двумя отдельными операциями другой поток может наблюдать частичное обновление.

</details>
