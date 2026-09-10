---
title: Backend architecture
description: Границы, направления зависимостей и компромиссы архитектуры backend-сервисов.
tags: [architecture, backend, design]
updated: 2026-09-10
---

# Backend architecture

Архитектура определяет границы ответственности, ownership данных и допустимые направления зависимостей. Название pattern не гарантирует maintainability: хорошая структура делает типичные изменения локальными и failure modes видимыми.

## Порядок изучения

1. [Layered architecture](layered-architecture.md) — простая организация по техническим ролям.
2. [Hexagonal architecture](hexagonal-architecture.md) и [Clean Architecture](clean-architecture.md) — защита application/domain policy от adapters.
3. [Dependency injection](dependency-injection.md), [Repository](repository-pattern.md) и [Service Layer](service-layer.md) — wiring и границы use cases/data access.
4. [API design](api-design.md) — внешний контракт и evolution.
5. [Monolith vs microservices](monolith-vs-microservices.md) и [modular monolith](modular-monolith.md) — deployment/data boundaries.

Оценивайте решение по change coupling, runtime coupling, consistency, latency, operability, team ownership и стоимости migration. Начинайте с минимальной структуры, которая удерживает реальные invariants; добавляйте indirection только под существующую ось изменений.

