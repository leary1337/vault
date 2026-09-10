---
title: Hexagonal architecture
description: Ports and adapters вокруг application core.
tags: [architecture, hexagonal, ports-and-adapters]
updated: 2026-09-10
---

# Hexagonal architecture

Hexagonal architecture (ports and adapters) отделяет application core от способов входа и внешних технологий. Port — контракт, значимый для core; adapter переводит конкретный transport/storage/provider в этот контракт.

## Направление зависимостей

Driving adapter вызывает inbound port: HTTP handler, CLI, scheduler или Kafka consumer запускает use case. Driven adapter реализует outbound port: repository, payment gateway, clock или event publisher. Контракт outbound port обычно определяет потребитель — application/domain package, а не infrastructure package.

```text
HTTP / gRPC / Kafka -> inbound port -> application core -> outbound port <- PostgreSQL / API
```

Core не знает JSON, SQL driver или broker SDK. Но он может знать business-relevant concepts: transaction boundary, optimistic conflict, idempotency или durable event.

## Trade-offs

Плюсы: смена adapter локальна, core тестируется без network, ownership contracts становится явным. Цена: mapping, wiring, больше типов и риск абстракций «на будущее». Fake adapter может не воспроизвести isolation, retries и query behavior — integration tests всё равно обязательны.

Pattern полезен при нескольких transports/providers, сложных invariants или долгоживущем домене. Для простого proxy он может быть тяжелее самой логики. Делайте port узким и выраженным языком use case, а не зеркалом SDK.

## Ошибки границы

Не протаскивайте `sql.ErrNoRows`, HTTP status или Kafka record в core. Adapter переводит их в результат контракта. Одновременно не скрывайте важную semantics: retryable conflict должен отличаться от permanent validation failure.

