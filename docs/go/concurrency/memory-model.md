---
title: Модель памяти Go
description: Sequenced-before, synchronized-before, happens-before и DRF-SC.
tags:
  - go
  - concurrency
  - memory-model
level:
  - middle
  - senior
updated: 2026-09-10
---

# Модель памяти Go

Модель памяти отвечает на вопрос: когда read в одной goroutine гарантированно наблюдает write из другой. «Операция уже успела выполниться по времени» недостаточно — нужна synchronization relation.

## Основные отношения

- **sequenced-before** — порядок операций внутри корректного последовательного выполнения одной goroutine, с учётом правил языка;
- **synchronized-before** — порядок, создаваемый наблюдаемыми synchronization operations;
- **happens-before** — transitive closure объединения двух отношений.

Обычный read обязан видеть write, который видим ему по happens-before и не перекрыт более поздним видимым write.

## Data race и DRF-SC

Data race возникает, когда два unordered-by-happens-before доступа к одной memory location выполняются конкурентно, хотя бы один — write и доступы не являются atomic.

Для data-race-free программ действует DRF-SC: результат можно объяснить некоторым sequentially consistent interleaving goroutines. Это не означает детерминированный scheduler order; допустимых interleavings может быть много.

Go не превращает race в безопасный last-write-wins. Даже если word-sized read должен наблюдать реально записанное значение, race на multiword descriptors (interface, slice, string) может смешать части состояний и привести к memory corruption.

## Goroutine creation и завершение

`go f()` synchronized-before начала выполнения `f`. Поэтому writes перед `go` видимы новой goroutine.

Простое завершение goroutine не создаёт synchronization с другими goroutines. Нельзя публиковать результат через общую переменную и затем «достаточно подождать по времени».

```go
var result string

go func() { result = "ready" }()
fmt.Println(result) // data race; нет гарантии наблюдения
```

Используйте channel, `WaitGroup`, mutex или другую документированную primitive.

## Channels

- Send synchronized-before completion соответствующего receive.
- Close synchronized-before receive, который возвращает zero value из-за closed state.
- Для unbuffered channel receive synchronized-before completion соответствующего send.
- Для channel capacity `C`: k-й receive synchronized-before completion (k+C)-го send.

Эти правила позволяют безопасно публиковать данные, но только вокруг соответствующих операций; сам факт, что две goroutines используют один channel для несвязанных сообщений, не упорядочивает все accesses автоматически.

## Mutex, Once, WaitGroup и atomics

- n-й `Unlock` synchronized-before return m-го `Lock` для n < m того же mutex.
- Completion функции в `Once.Do` synchronized-before return любого `Once.Do` для того же `Once`.
- `WaitGroup.Done`/return функции, запущенной через `WaitGroup.Go`, synchronized-before return `Wait`, который они разблокировали.
- Go atomics ведут себя как единый sequentially consistent order; наблюдаемый atomic effect создаёт synchronized-before.

Точные гарантии каждой primitive читайте в package docs.

## Publication

Правильная публикация immutable snapshot:

```go
type Config struct{ Timeout time.Duration }

var current atomic.Pointer[Config]

func publish(c *Config) { current.Store(c) }
func load() *Config     { return current.Load() }
```

После publication нельзя мутировать object без отдельной synchronization. Atomic pointer защищает только сам pointer transition, не поля объекта от последующих races.

## Double-checked locking

Проверка обычного pointer вне lock и повторная проверка под lock остаётся race: первая read не синхронизирована с write. Для lazy initialization используйте `sync.Once`, `sync.OnceValue` или корректный atomic publication protocol.

## Вопросы для самопроверки

1. Чем synchronized-before отличается от wall-clock order?
2. Гарантирует ли завершение goroutine видимость её writes?
3. Как close channel публикует ранее записанные данные нескольким receivers?
4. Почему atomic pointer не делает mutable object потокобезопасным?

## Источники

- [The Go Memory Model](https://go.dev/ref/mem)
- [`sync` package](https://pkg.go.dev/sync)
- [`sync/atomic` package](https://pkg.go.dev/sync/atomic)
