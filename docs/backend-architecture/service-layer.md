---
title: Service Layer
description: Application use cases, transactions, orchestration и domain boundaries.
tags: [architecture, service-layer]
updated: 2026-09-10
---

# Service Layer

Service Layer определяет application boundary и координирует один use case: authorization, validation, transaction, domain operation, persistence и publication result. Transport handler остаётся переводчиком protocol-а.

## Ответственность

Application service может:

- принять command/query с domain-relevant fields;
- проверить permission через policy;
- начать transaction и загрузить state;
- вызвать domain behavior;
- сохранить state и [Outbox event](../backend-patterns/transactional-outbox.md);
- вернуть typed result/error.

Domain service нужен для business rule, который естественно не принадлежит одной entity/value object. Не называйте domain service любой I/O orchestration.

## Boundary

Один публичный метод соответствует capability/use case, а не таблице. Не передавайте `http.Request`, protobuf generated message или database handle глубже без необходимости. Context переносит cancellation/deadline и tracing, но не optional business parameters.

## Failure semantics

Use case определяет atomicity и idempotency. Remote call внутри database transaction удлиняет locks и не становится атомарным; используйте reservation, outbox/saga или измените invariant. Retry policy принадлежит boundary, которая понимает idempotency и budget.

## Риски

«God service» с сотнями методов смешивает bounded contexts. Разделяйте по capability и ownership. Для простого CRUD service может быть тонким — это нормально, пока handler не дублирует policy, но лишние interfaces/mappers не добавляют ценности.

