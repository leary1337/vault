---
title: Dependency injection
description: Explicit wiring, interfaces at boundaries и lifecycle зависимостей в Go.
tags: [architecture, dependency-injection, go]
updated: 2026-09-10
---

# Dependency injection

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

Required dependencies передавайте constructor-ом и проверяйте там; optional behavior — typed options только при реальной optional semantics. Не используйте service locator: скрытые global lookups затрудняют чтение, тесты и lifecycle.

## Где определять interface

Interface принадлежит consumer и описывает минимальные операции use case. Не создавайте интерфейс только ради mock-а, если concrete type стабилен и дешёв. Для I/O boundary маленький consumer-owned interface полезен; для pure helper часто достаточно функции.

## Composition root и lifecycle

Один bootstrap layer читает config, создаёт logger/telemetry, clients, repositories, services и transports. Он же задаёт порядок shutdown. Singleton/request/scoped lifetimes должны быть явными: shared client pool не создаётся на запрос, request context не сохраняется в singleton.

Code generation/container может уменьшить wiring большого graph, но усложняет диагностику. В Go ручной wiring обычно остаётся самым прозрачным до доказанной проблемы.

