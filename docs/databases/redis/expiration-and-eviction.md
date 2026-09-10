---
title: Expiration и eviction
description: TTL semantics, active expiration и maxmemory policies.
tags: [databases, redis, memory]
updated: 2026-09-10
---

# Expiration и eviction

Expiration удаляет key по заданному времени жизни. Eviction освобождает память при превышении `maxmemory`. Это независимые механизмы: key без TTL может быть evicted политикой `allkeys-*`, а expired key может исчезнуть до достижения memory limit.

## TTL semantics

```text
SET session:42 payload EX 1800
TTL session:42
```

Timeout хранится как абсолютное время. Redis удаляет expired keys пассивно при обращении и активно через периодическую выборку. Поэтому физическое освобождение памяти может не совпасть с точной миллисекундой, хотя логически expired key недоступен.

Команда, полностью заменяющая value (`SET`), обычно снимает прежний TTL, если явно не сохранить/задать его. Изменение содержимого без замены key, например `HSET` или `INCR`, сохраняет TTL. Проверяйте semantics конкретной команды; `EXPIRE` поддерживает условия `NX`, `XX`, `GT`, `LT`.

## maxmemory policies

- `noeviction` отклоняет новые memory-growing writes;
- `allkeys-lru`, `allkeys-lfu`, `allkeys-lrm`, `allkeys-random` выбирают среди всех keys;
- `volatile-lru`, `volatile-lfu`, `volatile-lrm`, `volatile-random`, `volatile-ttl` — только среди keys с TTL.

`volatile-*` фактически ведёт себя как `noeviction`, если подходящих expiring keys нет. LRU/LFU/LRM реализованы приближённо, поэтому выбор не является строгим глобальным минимумом.

## Capacity

Не ставьте `maxmemory` равным всей RAM. Оставьте headroom для процесса, allocator fragmentation, client/output buffers, replication/AOF buffers и copy-on-write во время fork. Часть buffer memory не учитывается в eviction threshold; ориентируйтесь на `used_memory`, `used_memory_rss`, fragmentation и `mem_not_counted_for_evict`.

Eviction в system-of-record deployment означает потерю данных. Не смешивайте volatile cache и non-evictable state в одном instance, если единая policy не выражает требования обоих workloads.

## Источники

- [EXPIRE](https://redis.io/docs/latest/commands/expire/)
- [Key eviction](https://redis.io/docs/latest/develop/reference/eviction/)
- [Memory optimization](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/memory-optimization/)
