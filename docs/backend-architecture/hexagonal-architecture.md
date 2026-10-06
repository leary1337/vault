---
title: Hexagonal architecture
description: Ports and adapters вокруг application core.
tags: [architecture, hexagonal, ports-and-adapters]
updated: 2026-10-06
---

# Hexagonal architecture

Порт — необходимое бизнес-возможности действие; адаптер переводит внешний протокол в этот контракт.

Hexagonal architecture (ports and adapters) отделяет application core от способов входа и внешних технологий. Port — контракт, значимый для core; adapter (адаптер конкретной технологии к контракту) переводит конкретный transport/storage/provider в этот контракт.

## Направление зависимостей

Driving adapter вызывает inbound port: HTTP handler, CLI, scheduler или Kafka consumer (потребитель работы или контракта) запускает use case. Driven adapter реализует outbound port: repository, payment gateway, clock или event publisher. Контракт outbound port обычно определяет потребитель — application/domain package, а не infrastructure package.

```text
HTTP / gRPC / Kafka -> inbound port -> application core -> outbound port <- PostgreSQL / API
```

Core не знает JSON, SQL driver или broker SDK. Но он может знать business-relevant concepts: transaction boundary, optimistic conflict, idempotency или durable event.

## Компромиссы

Плюсы: смена adapter локальна, core тестируется без network, ownership (владение данными или ответственность за ресурс) contracts становится явным. Цена: mapping, wiring, больше типов и риск абстракций «на будущее». Fake adapter может не воспроизвести isolation, retries и query behavior — integration tests всё равно обязательны.

Pattern полезен при нескольких transports/providers, сложных invariants или долгоживущем домене. Для простого proxy он может быть тяжелее самой логики. Делайте port узким и выраженным языком use case, а не зеркалом SDK.

## Ошибки границы

Не протаскивайте `sql.ErrNoRows`, HTTP status или Kafka record в core. Adapter переводит их в результат контракта. Одновременно не скрывайте важную semantics: retryable conflict должен отличаться от permanent validation failure.

## Механизм на примере

Для `ReserveBudget(ctx, accountID, amount, operationID)` важны сумма, отказ из-за недостатка средств и неизвестный исход. Adapter платежей не должен превращать все HTTP-ошибки в `false`: timeout после списания отличается от подтверждённого отказа. Замена провайдера безопасна, только если новый adapter сохраняет эти гарантии.

Один inbound use case можно вызвать из HTTP и очереди. Очередь имеет повтор доставки, HTTP — повтор клиента; оба передают stable operation ID. Транзакция не обязана быть скрыта за интерфейсом: порт может выражать одну атомарную операцию с ожидаемой версией. Слишком общий порт зеркалирует SDK и сохраняет прежнюю связанность под новым именем.

## Источник механизма

[Alistair Cockburn: исходное описание Hexagonal Architecture](https://alistair.cockburn.us/hexagonal-architecture/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Что является хорошим портом?
2. Почему unknown outcome отдельная ошибка?

<details>
<summary>Ориентиры для ответа</summary>

1. Узкий контракт use case с явными гарантиями, а не копия всех методов SDK.
2. Эффект мог состояться; без выяснения нельзя безопасно повторить.

</details>
