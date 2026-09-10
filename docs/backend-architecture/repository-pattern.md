---
title: Repository pattern
description: Collection-like boundary для persistence и её ограничения.
tags: [architecture, repository, database]
updated: 2026-09-10
---

# Repository pattern

Repository предоставляет application/domain к persistence через use-case-oriented contract. Он полезен, когда storage details не должны определять domain policy; это не обязательная обёртка над каждой SQL таблицей.

## Хороший контракт

```go
type AdRepository interface {
    Get(ctx context.Context, id AdID) (Ad, error)
    UpdatePrice(ctx context.Context, id AdID, expectedVersion int64, price Money) error
}
```

Метод выражает нужную consistency semantics: expected version важнее generic `Save(any)`. Ошибки различают not found, conflict и unavailable, не раскрывая driver types.

Transaction boundary обычно принадлежит application use case/unit of work. Если repository сам незаметно commit-ит каждый вызов, invariant между двумя writes нарушается. API должен позволять atomic operation либо передавать transaction-scoped repositories.

## Reads и performance

Сложный read endpoint может использовать отдельный query service с SQL projection, pagination и database-specific features. Принуждать analytics/read model восстанавливать graph entities — лишние I/O и allocations. Repository не должен скрывать N+1 или обещать переносимость, которой нет.

## Когда не нужен

Для простого data service типизированные SQL queries уже являются ясной boundary. Generic CRUD repository часто теряет constraints, batching, locks и query shape. Создавайте abstraction под операции и invariants, а integration tests запускайте на настоящем engine.

Связанные темы: [PostgreSQL transactions](../databases/postgresql/transactions.md) и [data modeling](../system-design/fundamentals/data-modeling.md).

