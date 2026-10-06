---
title: Кэширование
description: Cache-aside, invalidation, stampede и cache penetration.
tags: [databases, redis, caching]
updated: 2026-10-06
---

# Кэширование с Redis

Кэш — копия, которую можно восстановить из основного хранилища. Он ускоряет чтение, но может устареть; приложение должно заранее знать, насколько старая цена или описание допустимы.

Cache улучшает latency и снижает нагрузку source of truth, но добавляет stale data и новый failure mode. Приложение должно корректно работать при miss, timeout и частичной недоступности Redis.

## Cache-aside

1. Прочитать key из Redis.
2. При miss прочитать primary storage.
3. Записать значение в Redis с TTL.
4. При изменении сначала commit source of truth, затем удалить cache key.

Удаление после commit обычно безопаснее записи готового cache value: следующий reader загрузит авторитетное состояние. Но race остаётся — медленный reader мог прочитать старое значение до commit и положить его после invalidation. Решения зависят от требований: versioned keys/values, compare-before-write, event-driven invalidation, короткий TTL или согласованный write-through protocol.

TTL ограничивает жизнь записи с момента заполнения, если каждый cache entry получает срок; возраст данных дополнительно зависит от длительности загрузки. Добавляйте небольшой random jitter, чтобы множество keys не истекло одновременно.

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

## Гонка загрузки и удаления

```mermaid
sequenceDiagram
    participant R as Читатель
    participant DB as База
    participant W as Писатель
    participant C as Redis
    R->>DB: Прочитать цену
    DB-->>R: 100
    W->>DB: COMMIT цены 120
    W->>C: DEL cache
    R->>C: SET старой цены 100
```

Удаление после commit не исключает позднюю запись старого reader. TTL ограничивает срок **с момента заполнения**, а не обязательно время от последнего изменения БД: если загрузчик завис на час, он может записать старую копию с новым TTL. Ограничивайте возраст загрузки и ожидание, либо проверяйте монотонную версию при записи. Удалённый ключ сам не содержит версии: compare должен иметь отдельное достоверное состояние, а не сравнивать только с отсутствующим value.

```text
SET ad:42 '{"version":7,"price":120}' EX 30
GET ad:42
```

GET вернёт JSON, пока TTL не истёк и ключ не вытеснен. Формат version позволяет проверять порядок, но сам SET не делает условную запись. singleflight объединяет запросы лишь в одном процессе; при 30 pods всё ещё может быть 30 загрузчиков. При падении кэша ограничьте запросы к БД, иначе fail-open перегрузит её.

## Источники

- [Redis cache-aside](https://redis.io/docs/latest/develop/use-cases/cache-aside/)
- [Client-side caching](https://redis.io/docs/latest/develop/clients/client-side-caching/)

## Проверь себя

1. **Почему DEL после commit не гарантирует свежесть?**

   <details>
   <summary>Ответ</summary>

   Старый reader может записать значение после удаления.

   </details>

2. **Почему TTL не всегда ограничивает возраст данных 30 секундами?**

   <details>
   <summary>Ответ</summary>

   Долгая загрузка могла прочитать данные задолго до нового SET; срок начинается при заполнении.

   </details>
