---
title: Backend architecture
description: Границы, направления зависимостей и компромиссы архитектуры backend-сервисов.
tags: [architecture, backend, design]
updated: 2026-09-10
---

# Backend architecture

Архитектура определяет границы ответственности, ownership данных и допустимые направления зависимостей. Название pattern не гарантирует maintainability: хорошая структура делает типичные изменения локальными и failure modes видимыми.

Оценивайте решение по change coupling, runtime coupling, consistency, latency, operability, team ownership и стоимости migration. Начинайте с минимальной структуры, которая удерживает реальные invariants; добавляйте indirection только под существующую ось изменений.

## Темы

- [API design](api-design.md)
- [Clean Architecture](clean-architecture.md)
- [Dependency injection](dependency-injection.md)
- [Hexagonal architecture](hexagonal-architecture.md)
- [Layered architecture](layered-architecture.md)
- [Modular monolith](modular-monolith.md)
- [Monolith vs microservices](monolith-vs-microservices.md)
- [Repository pattern](repository-pattern.md)
- [Service Layer](service-layer.md)
