---
title: Cache-aside
description: Lazy cache population и явная invalidation.
tags: [backend, patterns, caching]
updated: 2026-09-10
---

# Cache-aside

## Problem

Повторные reads перегружают authoritative store или не укладываются в latency SLO.

## Mechanism

Read проверяет cache; miss загружает source of truth и записывает value с TTL. Write сначала commit-ит source, затем invalidates cache. Singleflight, soft TTL и jitter уменьшают stampede.

## Guarantees

Cache miss возвращает authoritative value, если source доступен. TTL ограничивает жизнь entry после записи, но не гарантирует строгий read-after-write или отсутствие stale repopulation race.

## Failure modes

- reader кладёт старое значение после write invalidation;
- mass expiry создаёт stampede;
- cache outage перегружает primary;
- negative lookups пробивают cache;
- один hot key перегружает shard;
- сериализованная schema меняется несовместимо.

## Trade-offs

Lazy population кэширует только востребованное, но первый read медленный и consistency сложнее. Короткий TTL уменьшает staleness и hit ratio; длинный делает обратное. Invalidation events ускоряют convergence, но сами могут потеряться.

## When not to use

Не кэшируйте highly volatile/rare data без измеренной пользы. Для correctness-critical authorization/balance stale cache может быть недопустим или использоваться только как hint.

## Example

Key включает namespace, tenant, entity ID и schema version. При miss local [singleflight](singleflight.md) загружает DB; TTL получает jitter. При Redis error handler fail-open в DB с concurrency limit. Подробности: [Redis caching](../databases/redis/caching.md).
