---
title: Mocks, fakes и stubs
description: Выбор test double по риску и границе системы.
tags:
  - go
  - testing
updated: 2026-09-10
---

# Mocks, fakes и stubs

- Stub возвращает заранее заданный ответ.
- Fake содержит рабочую упрощённую реализацию, например in-memory repository.
- Mock проверяет ожидаемые interactions.

Предпочитайте behavior assertion через маленький consumer-side interface. Mock каждого внутреннего вызова связывает тест с implementation и мешает refactoring.

```go
type Clock interface { Now() time.Time }

type fixedClock struct{ now time.Time }
func (c fixedClock) Now() time.Time { return c.now }
```

Fake должен сохранять те semantics, на которых строится тест. In-memory map не заменяет PostgreSQL, если важны transactions, isolation, SQL types или constraints. Эти свойства проверяются integration test.

Generated mocks полезны для больших внешних interfaces, но это сигнал пересмотреть abstraction size. Не создавайте interface только ради mocking, если concrete dependency дешёвая и deterministic.

## Источники

- [Go Code Review Comments: Interfaces](https://go.dev/wiki/CodeReviewComments#interfaces)
