---
title: Структуры данных Redis
description: String, Hash, List, Set, Sorted Set и Streams.
tags: [databases, redis, data-structures]
updated: 2026-10-06
---

# Структуры данных Redis

Тип Redis выбирают по операциям: счётчик, множество уникальных значений, рейтинг или очередь. Одна атомарная команда безопаснее нескольких отдельных чтений и записей.

Выбирайте структуру по нужным atomic operations, а не по сходству с типом языка. Один key хранит значение одного типа; команда несовместимого типа возвращает `WRONGTYPE`.

| Тип | Полезные операции | Типичные задачи |
| --- | --- | --- |
| String | `GET`, `SET`, `INCR`, bit operations | cache blob, counter, flag |
| Hash | `HGET`, `HSET`, `HINCRBY` | компактный объект и частичные updates |
| List | `LPUSH/RPUSH`, `LPOP/RPOP`, blocking pops | deque, простая transient queue |
| Set | `SADD`, `SISMEMBER`, union/intersection | membership, unique tags |
| Sorted Set | `ZADD`, rank/range by score | leaderboard, delayed schedule |
| Stream | `XADD`, `XREAD`, consumer groups | append log и tracked consumption |

## Правила моделирования

Команды одного Redis server выполняются атомарно относительно других commands, но последовательность нескольких round trips — нет. Для составного изменения используйте подходящую одну команду, `MULTI/EXEC` + `WATCH`, Lua/function или пересмотрите model. Redis transaction группирует выполнение commands, но не предоставляет SQL-style rollback после runtime error.

Не читайте большую collection целиком в request path: `KEYS`, `LRANGE 0 -1`, `SMEMBERS` и огромные replies способны вызвать latency/traffic spike. Используйте `SCAN`-семейство для incremental iteration, но оно даёт weak iteration guarantees и может вернуть duplicates при concurrent changes.

## Streams

Stream entry имеет ordered ID и fields. `XREADGROUP` распределяет новые entries между consumers группы; delivered, но не acknowledged entries остаются в Pending Entries List. Consumer должен `XACK` только после успешной обработки, уметь повторно обрабатывать duplicate и reclaim-ить зависшие entries (`XAUTOCLAIM`). Ограничивайте growth через trimming и наблюдайте PEL/lag.

Redis Streams не равен durable event log автоматически: retention, persistence, replication, failover и consumer idempotency определяют фактические guarantees.

## Память

Размер key/value включает allocator и object overhead, а не только payload. Множество крошечных keys может стоить дороже одного hash; одна гигантская collection создаёт hot key и дорогие operations. Измеряйте `MEMORY USAGE`, `INFO memory`, latency и distribution размеров.

## Команды и результат

```text
SET demo:counter 0
INCR demo:counter
# 1
HSET demo:user:7 name Анна city Москва
HGET demo:user:7 city
# Москва
SADD demo:tags go go sql
SCARD demo:tags
# 2
ZADD demo:rating 100 anna 120 boris
ZRANGE demo:rating 0 -1 REV WITHSCORES
# boris 120 anna 100
```

Рейтинг сортирует по score; равенства разрешаются по member, а не порядку прихода. String INCR ограничен допустимым целым форматом и диапазоном, не произвольной точностью.

Streams с consumer group:

```text
XGROUP CREATE demo:events workers 0 MKSTREAM
XADD demo:events * event_id e-1 kind paid
XREADGROUP GROUP workers w-1 COUNT 1 STREAMS demo:events >
# запомните возвращённый stream ID
XPENDING demo:events workers
XACK demo:events workers <полученный-ID>
```

XREADGROUP выдаёт запись и помещает её в PEL. XACK удаляет pending marker, но **не** саму запись stream. Crash после side effect до XACK требует идемпотентности и reclaim. MULTI/EXEC обеспечивает последовательное выполнение блока, но runtime error команды не откатывает остальные; WATCH даёт условное выполнение при неизменности наблюдаемых ключей. Lua атомарен относительно других команд, однако долгий script задерживает их.

## Источники

- [Redis data types](https://redis.io/docs/latest/develop/data-types/)
- [Redis Streams](https://redis.io/docs/latest/develop/data-types/streams/)
- [Transactions](https://redis.io/docs/latest/develop/using-commands/transactions/)

## Проверь себя

1. **XACK удаляет stream entry?**

   <details>
   <summary>Ответ</summary>

   Нет, подтверждает pending-доставку; retention/trimming управляется отдельно.

   </details>

2. **Почему MULTI/EXEC не эквивалент SQL-транзакции?**

   <details>
   <summary>Ответ</summary>

   Нет rollback уже выполненных команд после runtime error; другие гарантии и durability.

   </details>
