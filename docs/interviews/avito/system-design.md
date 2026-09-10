---
title: System Design interview
description: Подготовка к секции проектирования по публичным ожиданиям AvitoTech.
tags: [interviews, avito, system-design]
updated: 2026-09-10
---

# System Design interview

AvitoTech публично описывает три части: понять задачу/границы, построить high-level design, затем углубиться в выбранные детали. У задачи нет единственного ответа; оцениваются работоспособность, trade-offs и управление долгосрочными рисками. В отчёте 2025 проектирование было дополнительной секцией для senior candidates.

## Рабочий порядок

Используйте [15-step process](../../system-design/system-design-process.md): actors/use cases → functional/non-functional requirements → estimates → API/data model → components/data flow → bottlenecks/failures → scaling/consistency/security/observability → trade-offs/evolution.

В начале возьмите инициативу: уточните аудиторию, scope, latency/availability/durability, volume и out-of-scope. Нарисуйте critical path. Углубляйтесь не во всё, а в 2–3 главных риска после согласования с интервьюером.

## Карта тем

[System Design fundamentals](../../system-design/fundamentals/README.md) · [PostgreSQL](../../databases/postgresql/README.md) · [Redis](../../databases/redis/README.md) · [Kafka](../../messaging/kafka/README.md) · [distributed systems](../../distributed-systems/README.md) · [observability](../../observability/README.md) · [security](../../security/README.md)

Практикуйте cases с разными dominant constraints: view counter, notifications, chat, favorites, classifieds. Не начинайте с microservices/Kafka; каждое звено должно отвечать конкретному требованию и иметь failure behavior.

## Источник

- [AvitoTech: подготовка к System Design](https://habr.com/ru/companies/avito/articles/753248/)
