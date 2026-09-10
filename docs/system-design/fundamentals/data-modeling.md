---
title: Data modeling
description: Access patterns, invariants, ownership, indexes и lifecycle.
tags: [system-design, data]
updated: 2026-09-10
---

# Data modeling

Начните с access patterns и invariants, затем выбирайте storage. Таблица/документ/event — representation, а не источник требований.

## Вопросы

- Какой service/store — source of truth?
- Каковы entity и stable business keys?
- Какие uniqueness/referential/state-transition invariants нужны?
- Какие queries, sort/filter и update patterns критичны?
- Какой consistency scope: row, aggregate, tenant, global?
- Retention, delete, legal hold, audit и backup?
- Как schema мигрирует без остановки?

Relational normalization уменьшает anomalies и хорошо держит constraints; denormalization ускоряет reads ценой duplicate state и update protocol. Read model/search index/cache — производные данные: у них должны быть rebuild/reconciliation и lag semantics.

Индекс проектируется под predicate/order/selectivity и увеличивает write cost. Partition/shard key определяет locality и hotspot risk. Монотонный key удобен для range, но концентрирует writes.

## Changes

Используйте expand/contract: добавить совместимую schema, dual-read/write только при доказанной идемпотентности, backfill с checkpoints/throttle, переключить readers, затем удалить старое после safety window. Большой DDL оценивайте по locks и rewrite behavior конкретной БД.

Event schema включает event ID, aggregate ID/version, occurred/published time и versioned type. Не помещайте секреты «временно»: logs/queues/backups живут дольше request.
