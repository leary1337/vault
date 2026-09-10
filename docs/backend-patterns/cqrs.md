---
title: CQRS
description: Разные command и query models без обязательного event sourcing.
tags: [backend, patterns, architecture]
updated: 2026-09-10
---

# CQRS

## Problem

Одна data model плохо одновременно выражает сложные write invariants и множество оптимизированных read views или независимо масштабируемые нагрузки.

## Mechanism

Command side валидирует invariant и изменяет authoritative model. Events/CDC проецируют изменения в одну или несколько query models, оптимизированных под конкретные reads. API явно различает command acknowledgement и freshness read model.

## Guarantees

Write model обеспечивает свои transactional invariants. Read model обычно converges к committed writes при работающей projection; CQRS сам не задаёт maximum lag, ordering или exactly-once projection.

## Failure modes

- projection пропускает/дважды применяет event;
- out-of-order versions откатывают view;
- read-after-write возвращает старое;
- rebuild несовместим с новой schema;
- dual writes напрямую в обе models расходятся;
- слишком много read models становятся operational burden.

## Trade-offs

Можно независимо выбирать schema/storage и масштабировать reads, но появляются eventual consistency, messaging, replay, versioning и дополнительная on-call поверхность. CQRS не требует event sourcing; source of truth может оставаться обычной relational model.

## When not to use

Для CRUD с умеренной нагрузкой одна нормальная database/read replica/materialized query проще. Не вводите CQRS только ради отдельных DTO.

## Example

Order command commit-ит PostgreSQL row + outbox. Projection идемпотентно обновляет customer order summary по aggregate version. После command UI либо показывает pending state, либо читает write model, либо ждёт projection до returned version с bounded timeout.
