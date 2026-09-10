---
title: Caching в System Design
description: Что кэшировать, где и как ограничить staleness.
tags: [system-design, caching]
updated: 2026-09-10
---

# Caching в System Design

Cache добавляют после определения expensive repeated read и допустимой staleness, а не как обязательный прямоугольник на схеме.

## Где кэшировать

- browser/CDN для public/versioned content;
- reverse proxy для HTTP responses с корректным `Cache-Control`/`Vary`;
- local process cache для минимальной latency, но с per-instance divergence;
- distributed cache для общего working set;
- database buffer/page cache — уже существующий слой, который тоже учитывается.

## Design decisions

Определите key (tenant + entity + schema version), value size, TTL/jitter, maxmemory/eviction, invalidation и behavior при cache outage. Cache-aside прост, но имеет stale repopulation race; write-through/write-behind меняют write path и durability.

Stampede уменьшают singleflight, soft TTL, early refresh и bounded loader lease. Cache penetration — negative caching/validation/Bloom filter. Hot key требует local replicas/splitting, а не только больше cache nodes.

## Проверка

Hit ratio измеряйте по use case и bytes/cost, не только requests. Рассчитайте database load при cold start и полном cache miss. Fail-open может обрушить primary, fail-closed — сделать cache частью availability; выберите сознательно.

Не используйте stale cache как authoritative permission/balance без версионирования и risk acceptance. Подробнее: [cache-aside pattern](../../backend-patterns/cache-aside.md) и [Redis caching](../../databases/redis/caching.md).
