---
title: Структуры данных Redis
description: String, Hash, List, Set, Sorted Set и Streams.
tags: [databases, redis, data-structures]
updated: 2026-09-10
---

# Структуры данных Redis

Выбирайте структуру по нужным atomic operations, а не по сходству с типом языка. Один key хранит значение одного типа; команда несовместимого типа возвращает `WRONGTYPE`.

| Тип | Полезные операции | Типичные задачи |
| --- | --- | --- |
| String | `GET`, `SET`, `INCR`, bit operations | cache blob, counter, flag |
| Hash | `HGET`, `HSET`, `HINCRBY` | компактный объект и частичные updates |
| List | `LPUSH/RPUSH`, `LPOP/RPOP`, blocking pops | deque, простая transient queue |
| Set | `SADD`, `SISMEMBER`, union/intersection | membership, unique tags |
| Sorted Set | `ZADD`, rank/range by score | leaderboard, delayed schedule |
| Stream | `XADD`, `XREAD`, consumer groups | append log и tracked consumption |

## Modeling rules

Команды одного Redis server выполняются атомарно относительно других commands, но последовательность нескольких round trips — нет. Для составного изменения используйте подходящую одну команду, `MULTI/EXEC` + `WATCH`, Lua/function или пересмотрите model. Redis transaction группирует выполнение commands, но не предоставляет SQL-style rollback после runtime error.

Не читайте большую collection целиком в request path: `KEYS`, `LRANGE 0 -1`, `SMEMBERS` и огромные replies способны вызвать latency/traffic spike. Используйте `SCAN`-семейство для incremental iteration, но оно даёт weak iteration guarantees и может вернуть duplicates при concurrent changes.

## Streams

Stream entry имеет ordered ID и fields. `XREADGROUP` распределяет новые entries между consumers группы; delivered, но не acknowledged entries остаются в Pending Entries List. Consumer должен `XACK` только после успешной обработки, уметь повторно обрабатывать duplicate и reclaim-ить зависшие entries (`XAUTOCLAIM`). Ограничивайте growth через trimming и наблюдайте PEL/lag.

Redis Streams не равен durable event log автоматически: retention, persistence, replication, failover и consumer idempotency определяют фактические guarantees.

## Memory

Размер key/value включает allocator и object overhead, а не только payload. Множество крошечных keys может стоить дороже одного hash; одна гигантская collection создаёт hot key и дорогие operations. Измеряйте `MEMORY USAGE`, `INFO memory`, latency и distribution размеров.

## Источники

- [Redis data types](https://redis.io/docs/latest/develop/data-types/)
- [Redis Streams](https://redis.io/docs/latest/develop/data-types/streams/)
- [Transactions](https://redis.io/docs/latest/develop/using-commands/transactions/)
