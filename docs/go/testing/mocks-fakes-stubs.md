---
title: Mocks, fakes и stubs
description: Выбор test double по риску и границе системы.
tags:
  - go
  - testing
updated: 2026-10-06
---

# Mocks, fakes и stubs

Подмена зависимости делает тест дешёвым и управляемым. Важно явно понимать, возвращает ли она ответ, хранит ли состояние или проверяет вызовы.

- Stub возвращает заранее заданный ответ.
- Fake содержит рабочую упрощённую реализацию, например in-memory repository.
- Mock проверяет ожидаемые interactions.

Предпочитайте behavior assertion через маленький consumer-side interface. Mock каждого внутреннего вызова связывает тест с implementation и мешает refactoring.

```go
type Clock interface{ Now() time.Time }

type fixedClock struct{ now time.Time }

func (c fixedClock) Now() time.Time { return c.now }
```

Fake должен сохранять те semantics, на которых строится тест. In-memory map не заменяет PostgreSQL, если важны transactions, isolation, SQL types или constraints. Эти свойства проверяются integration test.

Generated mocks полезны для больших внешних interfaces, но это сигнал пересмотреть abstraction size. Не создавайте interface только ради mocking, если concrete dependency дешёвая и deterministic.

## Stub для результата, mock для обязательного взаимодействия

```go
type UserReader interface {
	Find(context.Context, string) (string, error)
}
type stubReader struct {
	name string
	err  error
}

func (s stubReader) Find(context.Context, string) (string, error) {
	return s.name, s.err
}
```

Нужен `context`. Stub позволяет проверить, что service переводит ErrNotFound в нужный исход. Если контракт — «на отказе в правах не обращаться к repository», нужен fake с счётчиком или mock, проверяющий ноль обращений.

Не заставляйте mock проверять каждую перестановку внутренних helper calls: это проверяет устройство, а не поведение. Для fake repository документируйте, какие свойства отсутствуют: транзакции, locks, SQL types и constraints.

## Источники

- [Go Code Review Comments: Interfaces](https://go.dev/wiki/CodeReviewComments#interfaces)

## Проверь себя

1. Чем fake отличается от stub?
2. Когда проверка числа вызовов оправдана?

<details>
<summary>Ориентиры для ответа</summary>

1. Fake выполняет упрощённую логику и меняет состояние; stub возвращает заданный ответ.
2. Когда сам факт/отсутствие взаимодействия является внешним контрактом, например запрет записи без прав.

</details>
