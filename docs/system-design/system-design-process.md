---
title: Процесс System Design
description: Пятнадцать шагов от requirements до explicit trade-offs.
tags: [system-design, architecture]
updated: 2026-10-06
---

# Процесс System Design

Framework полезен для нового сервиса, RFC, capacity review и интервью. Шаги итеративны: новая оценка bottleneck может изменить API или data model.

1. Functional requirements — actors, use cases, state transitions, edge cases и out of scope.
2. Non-functional requirements — измеримые SLO (цель качества сервиса за заданное окно) latency/availability, durability (сохранность подтверждённых данных при заявленных отказах), consistency (согласованность наблюдаемых значений и порядка), privacy, cost, RPO/RTO.
3. Rough capacity estimation — average/peak QPS (число запросов в секунду), payload (полезное содержимое запроса или события), storage growth, bandwidth, concurrency и skew.
4. API — contracts, idempotency, pagination, errors, versioning и authorization boundary.
5. Data model — source of truth (основной достоверный источник данных), keys, invariants, indexes, retention (срок хранения) и migrations.
6. High-level architecture — минимальные components и ownership (владение данными или ответственность за ресурс); синхронные/асинхронные boundaries.
7. Write path — validation → authoritative (владеющий достоверным состоянием) commit (фиксация результата, который считается подтверждённым) → events/cache/index; atomicity и duplicate handling.
8. Read path — routing, cache, fan-out (раздача одного действия многим получателям), consistency и fallback.
9. Bottlenecks — hottest key/partition, shared pool, database, network, queue, control plane.
10. Scaling — vertical/horizontal, replication, sharding, batching, caching и rebalancing cost.
11. Consistency — model и scope, stale-read budget, conflict resolution и cross-resource invariants.
12. Failure scenarios — timeout ambiguity, dependency/zone loss, overload, split brain, data corruption, recovery.
13. Observability — SLI/SLO, golden signals, tracing/log fields, audit и actionable alerts.
14. Security — identity, authorization, encryption, secrets, abuse limits, data lifecycle (кто создаёт, останавливает и освобождает ресурс) и threat model.
15. Trade-offs — alternatives, rejected options, assumptions, risks, cost и trigger для пересмотра.

## Проверка путей

Для критичного use case нарисуйте отдельно write и read path, называя каждый durable/acknowledgement point. На каждой network boundary спросите: что будет при timeout, повторе, старом response и частичной записи?

## Результат проектирования

Хороший design document содержит decision log, schema/API examples, capacity table, failure matrix и rollout/rollback plan. Unknowns превращаются в spike/load test, а не маскируются точными на вид числами.

## Связанные темы

- [Requirements](fundamentals/requirements.md)
- [Capacity estimation](fundamentals/capacity-estimation.md)
- [Failure handling](fundamentals/failure-handling.md)

## Как читать схему, а не список технологий

Учебный пример: «избранное для 10 млн пользователей». Инвариант — одна связь user/item. API PUT/DELETE задаёт желаемое состояние; SQL unique constraint удерживает его при конкуренции. Шард по user_id делает список локальным; счётчик по item — асинхронная производная модель. Две одинаковые PUT не создают два события, потому что событие пишется только при новой вставке, но consumer (потребитель работы или контракта) всё равно устраняет повтор доставки.

```mermaid
flowchart LR
    C[Требование и инвариант] --> Contract[API и результат повтора]
    Contract --> Data[Модель и атомарная граница]
    Data --> Path[Запись, чтение и подтверждение]
    Path --> Fault[Отказ после каждого шага]
    Fault --> Evidence[Расчёт, измерение, проверка]
    Evidence --> C
```

Это порядок рассуждения при проектировании, не обязательный порядок изучения базы. Любую тему можно открыть отдельно. Сильное объяснение отвечает, что произойдёт после потерянного ответа и почему система восстановится, а не только называет Kafka/Redis.

## Источник механизма

[Google SRE: Handling Overload](https://sre.google/sre-book/handling-overload/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему нельзя начинать с выбора технологий?
2. Как проверить полноту дизайна?

<details>
<summary>Ориентиры для ответа</summary>

1. Без инварианта неизвестно, какие гарантии и расходы оправданы.
2. Пройти каждый durable/сетевой шаг с timeout, duplicate и crash и объяснить видимый результат.

</details>
