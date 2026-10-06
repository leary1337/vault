---
title: CQRS
description: Разные command и query models без обязательного event sourcing.
tags: [backend, patterns, architecture]
updated: 2026-10-06
---

# CQRS


CQRS разделяет команды изменения и модели чтения; это можно сделать даже в одном процессе и одной БД.

## Проблема

Одна data model плохо одновременно выражает сложные write invariants и множество оптимизированных read views или независимо масштабируемые нагрузки.

## Как работает

Command side валидирует invariant (правило, которое система обязана сохранять) и изменяет authoritative (владеющий достоверным состоянием) model. Events/CDC проецируют изменения в одну или несколько query models, оптимизированных под конкретные reads. API явно различает command acknowledgement и freshness read model.

## Гарантии и границы

Write model обеспечивает свои transactional invariants. Read model обычно converges к committed writes при работающей projection (производная модель для чтения); CQRS сам не задаёт maximum lag, ordering или exactly-once projection.

## Ошибки и отказы

- projection пропускает/дважды применяет event;
- out-of-order versions откатывают view;
- read-after-write возвращает старое;
- rebuild несовместим с новой schema;
- dual writes напрямую в обе models расходятся;
- слишком много read models становятся operational burden.

## Компромиссы

Можно независимо выбирать schema/storage и масштабировать reads, но появляются eventual consistency (согласованность наблюдаемых значений и порядка), messaging, replay (повторное проигрывание сохранённых событий), versioning и дополнительная on-call поверхность. CQRS не требует event sourcing; source of truth (основной достоверный источник данных) может оставаться обычной relational model.

## Когда не применять

Для CRUD с умеренной нагрузкой одна нормальная database/read replica/materialized query проще. Не вводите CQRS только ради отдельных DTO (структура данных внешнего запроса/ответа).

## Пример

Order command commit-ит PostgreSQL row + outbox (события, сохранённые вместе с бизнес-изменением). Projection идемпотентно обновляет customer order summary по aggregate version. После command UI либо показывает pending state, либо читает write model, либо ждёт projection до returned version с bounded (с явным конечным пределом) timeout.

## Разобранный пример

Клиент изменил объявление и получил `version=12`. Поисковая проекция пока v11. Три честных ответа: показать pending; читать карточку из основной модели; ждать `projection_version>=12` с ограниченным временем. Пауза 100 ms не даёт гарантии.

Проекция со полным состоянием может применить v12 и игнорировать v11. Для событий-дельт нельзя просто пропустить v11: прибавление и вычитание требуют непрерывного порядка либо отдельной дедупликации и восстановления пропущенных изменений. Rebuild выполняется в новую версию модели с согласованным снимком и журналом после него. Копия текущих строк без догоняющего журнала теряет изменения во время копирования.

## Источник механизма

[Martin Fowler: CQRS](https://martinfowler.com/bliki/CQRS.html). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Нужен ли event sourcing для CQRS?
2. Когда нельзя игнорировать старую версию события?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, основной моделью может быть обычная таблица.
2. Если событие содержит необходимую дельту, а не полное заменяющее состояние.

</details>
