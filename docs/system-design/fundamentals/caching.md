---
title: Caching в System Design
description: Что кэшировать, где и как ограничить staleness.
tags: [system-design, caching]
updated: 2026-10-06
---

# Caching в System Design

Кэш — удаляемая копия для ускорения; его потеря не должна уничтожить источник данных.

Cache добавляют после определения expensive repeated read и допустимой staleness, а не как обязательный прямоугольник на схеме.

## Где кэшировать

- browser/CDN для public/versioned content;
- reverse proxy для HTTP responses с корректным `Cache-Control`/`Vary`;
- local process cache для минимальной latency (срок ответа), но с per-instance divergence;
- distributed cache для общего working set;
- database buffer/page cache — уже существующий слой, который тоже учитывается.

## Решения

Определите key (tenant + entity + schema version), value size, TTL/jitter, maxmemory/eviction, invalidation и behavior при cache outage. Cache-aside прост, но имеет stale repopulation race; write-through/write-behind меняют write path и durability (сохранность подтверждённых данных при заявленных отказах).

Stampede (множество одинаковых одновременных загрузок) уменьшают singleflight, soft TTL (время жизни записи), early refresh и bounded (с явным конечным пределом) loader lease (временное право владения). Cache penetration — negative caching/validation/Bloom filter. Hot key (ключ с непропорционально высокой нагрузкой) требует local replicas/splitting, а не только больше cache nodes.

## Проверка

Hit ratio измеряйте по use case и bytes/cost, не только requests. Рассчитайте database load при cold start (запуск с непрогретыми данными/кэшем) и полном cache miss. Fail-open может обрушить primary, fail-closed — сделать cache частью availability (доступность заявленной операции); выберите сознательно.

Не используйте stale cache как authoritative (владеющий достоверным состоянием) permission/balance без версионирования и risk acceptance. Подробнее: [cache-aside pattern](../../backend-patterns/cache-aside.md) и [Redis caching](../../databases/redis/caching.md).

## На конкретном примере

При 20 000 GET/s и hit ratio 95% DB получает 1 000/s. Кэш исчез — 20 000/s. Разработчик обязан показать предел загрузок, объединение одновременных miss и допустимый отказ части запросов.

Cache key карточки включает tenant и версию сериализации. Ключ только `ad:42` опасен, если доступ зависит от tenant/пользователя. Можно кэшировать публичное содержимое отдельно от проверки прав, но нельзя выдать private поля всем посетителям из общего response cache.

## Источник механизма

[Redis: cache invalidation](https://redis.io/docs/latest/develop/reference/client-side-caching/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему hit ratio недостаточно?
2. Где проверять доступ при response cache?

<details>
<summary>Ориентиры для ответа</summary>

1. Одинаковый процент скрывает разную цену запросов, горячие ключи и bytes.
2. В корректном ключе/контракте либо отдельно перед выдачей; кэш не должен обходить authorization.

</details>
