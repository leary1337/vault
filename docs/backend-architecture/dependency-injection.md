---
title: Dependency injection
description: Explicit wiring, interfaces at boundaries и lifecycle зависимостей в Go.
tags: [architecture, dependency-injection, go]
updated: 2026-10-06
---

# Dependency injection

DI означает передать зависимость явно: сервису дают готовый repository и clock, вместо чтения скрытых глобальных переменных.

Dependency injection передаёт объекту collaborators извне вместо скрытого создания или чтения из global state. Это техника управления зависимостями, не DI container.

## В Go

Предпочтителен explicit constructor injection:

```go
type Clock interface { Now() time.Time }

type Service struct {
    repo  AdRepository
    clock Clock
}

func NewService(repo AdRepository, clock Clock) *Service {
    return &Service{repo: repo, clock: clock}
}
```

Required dependencies передавайте constructor-ом и проверяйте там; optional behavior — typed options только при реальной optional semantics. Не используйте service locator: скрытые global lookups затрудняют чтение, тесты и lifecycle (кто создаёт, останавливает и освобождает ресурс).

## Где определять interface

Interface принадлежит consumer (потребитель работы или контракта) и описывает минимальные операции use case. Не создавайте интерфейс только ради mock-а, если concrete type стабилен и дешёв. Для I/O boundary маленький consumer-owned interface полезен; для pure helper часто достаточно функции.

## Composition root и lifecycle

Один bootstrap (подготовка приложения при запуске) layer читает config, создаёт logger/telemetry, clients, repositories, services и transports. Он же задаёт порядок shutdown. Singleton/request/scoped lifetimes должны быть явными: shared client pool не создаётся на запрос, request context не сохраняется в singleton.

Code generation/container может уменьшить wiring большого graph, но усложняет диагностику. В Go ручной wiring обычно остаётся самым прозрачным до доказанной проблемы.

## Механизм на примере

Constructor создаёт сервис, composition root (место сборки зависимостей приложения) — место сборки приложения — создаёт весь граф и владеет закрытием ресурсов. Если конструктор сервиса получает общий DB pool, он не должен закрыть его в конце одного запроса. Если функция сама создала отдельный файл/клиент, её контракт определяет передачу владения.

Go interface с typed nil не равен nil: `var p *SQLRepo=nil; var r AdRepository=p` даёт `r != nil`. Поэтому проверка `if repo==nil` не ловит все неверные способы wiring. Практично не возвращать typed nil из фабрик и проверять граф при запуске; reflection-проверки повсюду не заменяют ясный контракт.

Тестовый Clock помогает воспроизвести истечение срока без настоящего sleep, но production deadline (крайний срок завершения) зависит также от context и реальных I/O. Context запроса не сохраняем в общем сервисе: после ответа он будет отменён, а последующие операции получат чужой срок.

## Источник механизма

[Go specification: interface values](https://go.dev/ref/spec#Interface_types). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Кто закрывает общий pool?
2. Почему interface может быть ненулевым при nil pointer?

<details>
<summary>Ориентиры для ответа</summary>

1. Владелец жизненного цикла приложения, а не получивший его use case.
2. Interface хранит динамический тип и значение; тип присутствует.

</details>
