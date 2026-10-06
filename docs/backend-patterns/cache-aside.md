---
title: Cache-aside
description: Lazy cache population и явная invalidation.
tags: [backend, patterns, caching]
updated: 2026-10-06
---

# Cache-aside


Cache-aside — чтение сначала из кэша, а при промахе из основного хранилища.

## Проблема

Повторные reads перегружают authoritative (владеющий достоверным состоянием) store или не укладываются в latency (срок ответа) SLO (цель качества сервиса за заданное окно).

## Как работает

Read проверяет cache; miss загружает source of truth (основной достоверный источник данных) и записывает value с TTL (время жизни записи). Write сначала commit-ит source, затем invalidates cache. Singleflight, soft TTL и jitter уменьшают stampede (множество одинаковых одновременных загрузок).

## Гарантии и границы

Cache miss возвращает authoritative value, если source доступен. TTL ограничивает жизнь entry после записи, но не гарантирует строгий read-after-write или отсутствие stale repopulation race.

## Ошибки и отказы

- reader кладёт старое значение после write invalidation;
- mass expiry создаёт stampede;
- cache outage перегружает primary;
- negative lookups пробивают cache;
- один hot key (ключ с непропорционально высокой нагрузкой) перегружает shard (часть данных у отдельного владельца);
- сериализованная schema меняется несовместимо.

## Компромиссы

Lazy population кэширует только востребованное, но первый read медленный и consistency (согласованность наблюдаемых значений и порядка) сложнее. Короткий TTL уменьшает staleness и hit ratio; длинный делает обратное. Invalidation events ускоряют convergence, но сами могут потеряться.

## Когда не применять

Не кэшируйте highly volatile/rare data без измеренной пользы. Для correctness-critical authorization/balance stale cache может быть недопустим или использоваться только как hint.

## Пример

Key включает namespace, tenant, entity ID и schema version. При miss local [singleflight](singleflight.md) загружает DB; TTL получает jitter. При Redis error handler fail-open в DB с concurrency limit. Подробности: [Redis caching](../databases/redis/caching.md).

## Разобранный пример

Гонка: A прочитал DB v7; B записал v8 и удалил кэш; A положил v7 после удаления. TTL=60 s позволяет старому значению жить ещё минуту от последней вставки, даже если обновление уже произошло. Простая invalidation не даёт строгого чтения после записи.

Для гарантии своей записи клиент передаёт `min_version=8`: кэш ниже версии пропускается, чтение идёт в источник, способный обслужить эту версию. Для строгих прав/денег лучше сразу читать источник истины. Версия в имени ключа работает, только если клиент достоверно знает текущую версию: поиск этого номера сам требует согласованного чтения.

Учебный пример: 10 000 GET/с и hit ratio 99% дают 100 запросов/с к БД; потеря кэша даёт 10 000/с. План отказа обязан ограничить эти загрузки, а не обещать, что Redis «не влияет на доступность».

## Источник механизма

[Redis: invalidation client-side cache](https://redis.io/docs/latest/develop/reference/client-side-caching/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему удаление кэша после commit (фиксация результата, который считается подтверждённым) не исключает старое значение?
2. Как обеспечить read-your-writes?

<details>
<summary>Ориентиры для ответа</summary>

1. Параллельный reader может положить ранее прочитанную версию после удаления.
2. Проверять минимальную версию и читать достаточно свежий источник.

</details>
