---
title: Thundering herd
description: Диагностика синхронных cache misses, expirations, reconnects и wake-ups.
tags: [production, cache, concurrency]
updated: 2026-10-06
---

# Thundering herd

Стадо — множество клиентов одновременно запускает одну и ту же работу после общего события.

## Симптомы

Короткие резкие пики одинаковой работы перегружают database/API/CPU после cache expiry, restart, reconnect или scheduled boundary; множество callers ждут один и тот же result.

## Возможные причины

Одинаковый TTL (время жизни записи), cold cache/deploy, hot key (ключ с непропорционально высокой нагрузкой), cache outage, synchronized cron, reconnect без jitter, broadcast wake-up, lock expiry или retry после общего timeout.

## Что измерить

Request/miss/load rate по normalized key class, concurrent fills, cache hit/eviction/expiry, downstream amplification, lock/singleflight wait, scheduled timestamps и recovery slope.

## Проверка гипотез

Сопоставьте spike с expiry/deploy/schedule. Определите, одинаковый ли key/work у calls и кто должен координировать fill. Проверьте, herd локален instance-у или fleet-wide; local singleflight не защищает общий backend от многих replicas.

## Инструменты

Cache metrics/key sampling без PII (персональные данные), traces producer/waiters, scheduler/deploy events, downstream QPS (число запросов в секунду), Redis hot-key/latency tooling и concurrency profiles.

## Как уменьшить ущерб

Serve stale if safe, rate/load shed, ограничить concurrent fills, singleflight/lease, постепенно warm cache, добавить jitter к refresh/reconnect и временно увеличить dependency capacity. Distributed lock без fencing/TTL design может создать новый failure.

## Механизм причины

Найдите общий synchronization event и отсутствие coordination/randomization/bound: какая работа дублировалась, сколько раз и почему cache/dependency получил burst.

## Предотвращение

TTL jitter, stale-while-revalidate, proactive refresh, negative caching с осторожностью, local + distributed request coalescing, warm-up/ramp-up, hot-key sharding и randomized schedules. См. [singleflight](../backend-patterns/singleflight.md) и [cache-aside](../backend-patterns/cache-aside.md).

## Разбор с числами

Учебный пример: TTL hot key истёк, 1 000 requests/s, DB loader 200 ms. До появления нового значения примерно 200 одинаковых загрузок в одном процессе без coalescing. Local singleflight уменьшает их до одной, но при 50 processes остаётся до 50 загрузок.

Свидетельства: miss spike совпал с expiry, однотипный key в sampled traces, DB QPS растёт без роста user RPS. Альтернатива — новый уникальный traffic: keys разные, singleflight почти не поможет. Различаем по sampled key class без вывода PII.

Для разрешённых stale данных soft TTL запускает refresh в фоне, hard TTL ограничивает максимальную жизнь. Refresh имеет bounded (с явным конечным пределом) lifetime, jitter и concurrency limit. Для прав доступа stale fallback может быть недопустим. Запланированная очистка всего кэша в полночь воспроизводит herd каждый день; постепенный warm-up/ramp-up безопаснее.

## Источник механизма

[Go singleflight](https://pkg.go.dev/golang.org/x/sync/singleflight). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему local singleflight не полностью защищает fleet?
2. Когда нельзя serve stale?

<details>
<summary>Ориентиры для ответа</summary>

1. Каждый процесс имеет отдельную Group.
2. Если устаревшее значение нарушает права, деньги или другой строгий invariant (правило, которое система обязана сохранять).

</details>
