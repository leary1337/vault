---
title: Кэширование
description: Cache-aside, invalidation, stampede и cache penetration.
tags: [databases, redis, caching]
updated: 2026-09-10
---

# Кэширование с Redis

Cache улучшает latency и снижает нагрузку source of truth, но добавляет stale data и новый failure mode. Приложение должно корректно работать при miss, timeout и частичной недоступности Redis.

## Cache-aside

1. Прочитать key из Redis.
2. При miss прочитать primary storage.
3. Записать значение в Redis с TTL.
4. При изменении сначала commit source of truth, затем удалить cache key.

Удаление после commit обычно безопаснее записи готового cache value: следующий reader загрузит авторитетное состояние. Но race остаётся — медленный reader мог прочитать старое значение до commit и положить его после invalidation. Решения зависят от требований: versioned keys/values, compare-before-write, event-driven invalidation, короткий TTL или согласованный write-through protocol.

TTL ограничивает staleness только если каждый cache entry действительно его получает. Добавляйте небольшой random jitter, чтобы множество keys не истекло одновременно.

## Stampede

Популярный key при expiry заставляет сотни requests одновременно обратиться к БД. Возможные меры:

- request coalescing/singleflight на instance;
- короткий distributed lease для одного loader с bounded wait/fallback;
- soft TTL: отдать ещё допустимое stale value, один worker refresh-ит;
- probabilistic early refresh и TTL jitter;
- заранее прогреть действительно критичные keys.

Lock для refresh не должен превращать cache miss в долгий outage: ограничьте ожидание и учитывайте падение loader.

## Penetration и negative caching

Запросы несуществующих IDs всегда проходят мимо cache. Кэшируйте «not found» на короткое время, проверяйте input/authorization до storage и при огромном известном keyspace рассмотрите Bloom filter. Bloom filter имеет false positives и требует стратегии rebuild/update; он не доказывает наличие записи.

## Failure policy

- Fail-open: при Redis error идти в БД; защищайте её concurrency limit/circuit breaker, иначе cache outage становится DB outage.
- Fail-closed: подходит security/rate-limit state только если отказ запроса безопаснее обхода правила.
- Stale-on-error: полезен для допустимо устаревших данных при явно ограниченном stale window.

Наблюдайте hit ratio по use case, не глобально; также load latency, evictions, timeouts, stale serving и нагрузку backend при miss.

## Источники

- [Redis cache-aside](https://redis.io/docs/latest/develop/use-cases/cache-aside/)
- [Client-side caching](https://redis.io/docs/latest/develop/clients/client-side-caching/)
