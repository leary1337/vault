---
title: Data modeling
description: Access patterns, invariants, ownership, indexes и lifecycle.
tags: [system-design, data]
updated: 2026-10-06
---

# Data modeling

Модель данных отражает запросы и правила, которые никогда не должны нарушаться.

Начните с access patterns и invariants, затем выбирайте storage. Таблица/документ/event — representation, а не источник требований.

## Вопросы

- Какой service/store — source of truth (основной достоверный источник данных)?
- Каковы entity и stable business keys?
- Какие uniqueness/referential/state-transition invariants нужны?
- Какие queries, sort/filter и update patterns критичны?
- Какой consistency (согласованность наблюдаемых значений и порядка) scope: row, aggregate, tenant, global?
- Retention (срок хранения), delete, legal hold, audit и backup?
- Как schema мигрирует без остановки?

Relational normalization уменьшает anomalies и хорошо держит constraints; denormalization ускоряет reads ценой duplicate state и update protocol. Read model/search index/cache — производные данные: у них должны быть rebuild/reconciliation и lag semantics.

Индекс проектируется под predicate/order/selectivity и увеличивает write cost. Partition/shard key определяет locality и hotspot risk. Монотонный key удобен для range, но концентрирует writes.

## Изменение схемы

Используйте expand/contract: добавить совместимую schema, dual-read/write только при доказанной идемпотентности, backfill с checkpoints/throttle, переключить readers, затем удалить старое после safety window. Большой DDL оценивайте по locks и rewrite behavior конкретной БД.

Event schema включает event ID, aggregate ID/version, occurred/published time и versioned type. Не помещайте секреты «временно»: logs/queues/backups живут дольше request.

## На конкретном примере

Для избранного unique `(user_id,item_id)` отвечает за отсутствие второй связи, индекс `(user_id,created_at DESC,item_id DESC)` — за список. Это разные задачи. Цена в minor units плюс currency предотвращает неоднозначную дробную арифметику, но масштаб minor units зависит от валюты и договорённости.

Expand/contract для нового `price_minor`: добавляем nullable столбец; code умеет старые/новые данные; backfill идёт пакетами с checkpoint (сохранённая позиция завершённой обработки); контролируем расхождения; переводим чтение; только после ухода старого кода удаляем прежнее поле. Большой UPDATE одной транзакцией увеличит locks, WAL, lag и срок rollback (отмена локальной транзакции или возврат старой версии). Реальные последствия DDL проверяем по выбранной версии СУБД.

## Источник механизма

[PostgreSQL 18: constraints](https://www.postgresql.org/docs/18/ddl-constraints.html). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Чем constraint отличается от index для чтения?
2. Зачем backfill checkpoint?

<details>
<summary>Ориентиры для ответа</summary>

1. Первый удерживает правило, второй ускоряет определённый запрос; unique index может делать оба.
2. Чтобы повторить/продолжить работу после сбоя без полного перезапуска.

</details>
