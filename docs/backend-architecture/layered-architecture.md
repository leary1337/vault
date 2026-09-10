---
title: Layered architecture
description: Слои presentation, application, domain и infrastructure и цена их связности.
tags: [architecture, layers]
updated: 2026-09-10
---

# Layered architecture

Layered architecture группирует код по роли. Типичный поток: transport/presentation → application/service → domain → data/infrastructure. В строгом варианте верхний слой зависит только от следующего; в relaxed варианте может обращаться через несколько слоёв.

## Границы

- transport преобразует HTTP/gRPC/message contract в application command/query;
- application координирует use case, transaction и external effects;
- domain хранит business rules и invariants;
- infrastructure реализует SQL, cache, broker и remote clients.

DTO transport-а не должен незаметно становиться domain model и database row одновременно: это связывает API evolution, storage schema и invariants. Ошибки переводятся на boundary: domain error → стабильный API status, а не утечка SQL текста.

## Компромиссы

Плюсы: низкий порог входа, понятный request flow, достаточно для большинства CRUD/service applications. Риски: «толстый service», anemic domain, горизонтальные папки с сотнями unrelated types, обход слоёв и зависимость business logic от framework.

Layering по техническим папкам ухудшает locality feature changes. Практичный вариант — сначала разделить bounded modules/features, затем использовать небольшие слои внутри каждого.

## Когда не усложнять

Для небольшого stateless adapter достаточно handler + client и тестов contract. Интерфейс на каждый package и четыре mapping layers без независимых моделей создают ceremony, не границу.

