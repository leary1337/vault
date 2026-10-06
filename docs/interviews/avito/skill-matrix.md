---
title: Указатель тем интервью
description: Соответствие публичных секций Avito разделам Knowledge Base.
tags: [interviews, avito, skills]
updated: 2026-10-06
---

# Указатель тем интервью

Этот указатель связывает вопросы с тематическими статьями. Он помогает найти объяснение, но не является внутренней системой оценивания Avito.

Это тематический указатель: он связывает типы вопросов с разделами базы. Это не внутренняя scoring rubric Avito.

| Секция | Основные разделы | Что демонстрировать |
|---|---|---|
| Scoring/screening | [Go](../../go/README.md), [DB](../../databases/README.md), [networking](../../networking/README.md), [distributed systems](../../distributed-systems/README.md) | точный фундамент, границы гарантий, короткие production examples |
| Programming | [Algorithms](../../algorithms/README.md) | clarification, invariant, correct code, tests, complexity |
| Platform | [Go language](../../go/language/README.md), [concurrency](../../go/concurrency/README.md), [runtime](../../go/runtime/README.md), [backend](../../go/backend/README.md) | чтение кода, lifecycle, memory/race/error behavior, diagnostics |
| System Design | [process](../../system-design/system-design-process.md), [PostgreSQL](../../databases/postgresql/README.md), [Redis](../../databases/redis/README.md), [Kafka](../../messaging/kafka/README.md), [observability](../../observability/README.md) | requirements, estimates, contracts, bottlenecks, failure modes, trade-offs |
| Final | [incidents](../../production/incident-response.md), [architecture](../../backend-architecture/README.md), [архитектурный пример](../../practice/go-backend-project.md) | ownership, communication, measured outcomes, honest learning |

## Самооценка

Для любой выбранной темы можно проверить: удаётся ли объяснить термин, вывести mechanism, назвать ограничения и подтвердить практическим примером. Такая самооценка помогает выбрать интересующую тему и не задаёт обязательный порядок чтения.

## Пример поиска по проблеме

| Наблюдение | Что объяснить | Где искать |
| --- | --- | --- |
| Цена после сохранения старая | Replica lag и cache race | [Репликация](../../databases/postgresql/replication.md), [кэш](../../databases/redis/caching.md) |
| Consumer повторно списал | Commit boundary и stable event ID | [Inbox](../../messaging/inbox-pattern.md) |
| Запросы стоят при низкой CPU | Pool wait, locks, lifecycle | [Пул](../../databases/postgresql/connection-pooling.md), [locks](../../databases/postgresql/locks.md) |
| Код работает на одном input | Invariant и контрпример | [Алгоритмы](../../algorithms/README.md) |

Для глубины ответа проверьте: определение доступно новичку, механизм объясняет результат, названы условия гарантии, есть контрпример и метод проверки. «Всё понял» подтверждается новым примером без подсказки. Senior уровень требует выбирать решение под ограничения: нельзя одинаково применять кэш к описанию объявления и к факту оплаты.

Эта таблица классифицирует знания, не назначает порядок тем или календарь. Любую статью можно открыть независимо и проверить вопросы в конце.

## Проверь себя

1. **Что означает уверенность в теме?**

   <details>
   <summary>Ответ</summary>

   Умение объяснить и применить механизм к новому примеру, включая ограничения.

   </details>

2. **Гарантирует ли заполненная матрица оффер?**

   <details>
   <summary>Ответ</summary>

   Нет; реальные навыки, коммуникация и scope вакансии оцениваются отдельно.

   </details>
