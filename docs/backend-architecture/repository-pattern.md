---
title: Repository pattern
description: Collection-like boundary для persistence и её ограничения.
tags: [architecture, repository, database]
updated: 2026-10-06
---

# Repository pattern

Repository — контракт работы с хранимыми объектами, выраженный необходимыми операциями приложения.

Repository предоставляет application/domain к persistence через use-case-oriented contract (договорённость о поведении и гарантиях). Он полезен, когда storage details не должны определять domain policy; это не обязательная обёртка над каждой SQL таблицей.

## Хороший контракт

```go
type AdRepository interface {
    Get(ctx context.Context, id AdID) (Ad, error)
    UpdatePrice(ctx context.Context, id AdID, expectedVersion int64, price Money) error
}
```

Метод выражает нужную consistency (согласованность наблюдаемых значений и порядка) semantics: expected version важнее generic `Save(any)`. Ошибки различают not found, conflict и unavailable, не раскрывая driver types.

Transaction boundary обычно принадлежит application use case/unit of work. Если repository сам незаметно commit-ит каждый вызов, invariant (правило, которое система обязана сохранять) между двумя writes нарушается. API должен позволять atomic operation либо передавать transaction-scoped repositories.

## Reads и performance

Сложный read endpoint может использовать отдельный query service с SQL projection (производная модель для чтения), pagination и database-specific features. Принуждать analytics/read model восстанавливать graph entities — лишние I/O и allocations. Repository не должен скрывать N+1 или обещать переносимость, которой нет.

## Когда не нужен

Для простого data service типизированные SQL queries уже являются ясной boundary. Generic CRUD repository часто теряет constraints, batching, locks и query shape. Создавайте abstraction под операции и invariants, а integration tests запускайте на настоящем engine.

Связанные темы: [PostgreSQL transactions](../databases/postgresql/transactions.md) и [data modeling](../system-design/fundamentals/data-modeling.md).

## Механизм на примере

Вместо `Get → изменить → Save` для цены реализуем атомарно `UPDATE ads SET price_minor=$1, version=version+1 WHERE id=$2 AND version=$3 RETURNING version`. Так два клиента не теряют изменение друг друга. Ноль строк требует безопасного различения missing/not allowed/version conflict; не выдаём существование чужого объекта через ошибку.

Read-model запрос может вернуть сразу карточку с count, не восстанавливая все entities. Если список из 50 карточек вызывает 50 запросов владельца, N+1 остаётся проблемой даже при идеальных интерфейсах. Контракт batch get должен задавать порядок результатов, отсутствующие ID и предел размера.

Transaction-scoped repository не сохраняем после commit (фиксация результата, который считается подтверждённым): handle больше не действителен. Retry при serialization failure охватывает весь use case и создаёт новую transaction scope.

## Источник механизма

[Martin Fowler: Repository](https://martinfowler.com/eaaCatalog/repository.html). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Что скрывает плохой generic repository?
2. Почему нужны integration tests?

<details>
<summary>Ориентиры для ответа</summary>

1. Важные guarantees версий, batching, constraints и транзакций.
2. Интерфейс не доказывает атомарность реальной SQL-реализации.

</details>
