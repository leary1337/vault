---
title: Service Layer
description: Application use cases, transactions, orchestration и domain boundaries.
tags: [architecture, service-layer]
updated: 2026-10-06
---

# Service Layer

Service layer связывает шаги одной пользовательской операции и определяет, где она атомарна.

Service Layer определяет application boundary и координирует один use case: authorization, validation, transaction, domain operation, persistence и publication result. Transport handler остаётся переводчиком protocol-а.

## Ответственность

Application service может:

- принять command/query с domain-relevant fields;
- проверить permission через policy;
- начать transaction и загрузить state;
- вызвать domain behavior;
- сохранить state и [Outbox (события, сохранённые вместе с бизнес-изменением) event](../backend-patterns/transactional-outbox.md);
- вернуть typed result/error.

Domain service нужен для business rule, который естественно не принадлежит одной entity/value object. Не называйте domain service любой I/O orchestration.

## Boundary

Один публичный метод соответствует capability/use case, а не таблице. Не передавайте `http.Request`, protobuf generated message или database handle глубже без необходимости. Context переносит cancellation/deadline и tracing, но не optional business parameters.

## Failure semantics

Use case определяет atomicity и idempotency. Remote call внутри database transaction удлиняет locks и не становится атомарным; используйте reservation, outbox/saga или измените invariant (правило, которое система обязана сохранять). Retry policy принадлежит boundary, которая понимает idempotency и budget.

## Риски

«God service» с сотнями методов смешивает bounded (с явным конечным пределом) contexts. Разделяйте по capability и ownership (владение данными или ответственность за ресурс). Для простого CRUD service может быть тонким — это нормально, пока handler не дублирует policy, но лишние interfaces/mappers не добавляют ценности.

## Механизм на примере

Создание объявления: авторизация → проверка данных → BEGIN → идемпотентный ключ → INSERT ad → INSERT Outbox → сохранённый результат → COMMIT (фиксация результата, который считается подтверждённым). Handler только переводит результат в HTTP. Ошибка до commit откатывает все локальные изменения; потеря ответа после commit возвращается по ключу.

Удалённую модерацию нельзя сделать частью SQL commit: вызов в транзакции удерживает соединение и locks, но rollback (отмена локальной транзакции или возврат старой версии) не отменит внешний эффект. Вместо этого фиксируем pending и задание, затем условно применяем результат. Для публичного метода явно описываем контекст, deadline (крайний срок завершения), какие ресурсы он владеет и возможно ли повторение.

## Источник механизма

[Martin Fowler: Service Layer](https://martinfowler.com/eaaCatalog/serviceLayer.html). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему HTTP call внутри SQL transaction не атомарен с ней?
2. Как сделать долгую модерацию?

<details>
<summary>Ориентиры для ответа</summary>

1. Внешний сервис не участвует в SQL rollback.
2. Durable pending state, задание и условное применение результата по версии.

</details>
