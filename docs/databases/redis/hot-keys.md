---
title: Hot keys и big keys
description: Диагностика и снижение неравномерной нагрузки Redis.
tags: [databases, redis, performance]
updated: 2026-10-06
---

# Hot keys и big keys

Горячий ключ часто читают или меняют; большой ключ содержит много данных. Первый перегружает владельца частотой операций, второй — длительностью операций и размером ответа.

Hot key получает непропорционально много commands/bytes и ограничивает один node или slot. Big key содержит большой value/collection и создаёт долгие команды, сетевые bursts, fork copy-on-write и медленную slot migration. Один key может быть одновременно hot и big, но лечатся проблемы по-разному.

## Диагностика

Сопоставьте:

- per-node CPU, network, ops/sec и latency;
- `INFO commandstats`, `LATENCY DOCTOR`, `SLOWLOG`;
- client-side tracing/metrics с безопасным low-cardinality key prefix;
- `redis-cli --bigkeys`/`--memkeys` или incremental `SCAN` вне peak;
- `redis-cli --hotkeys` при LFU-compatible configuration;
- distribution Cluster slots и размер replies.

`MONITOR` транслирует поток всех commands, создаёт overhead и раскрывает arguments; не используйте его как обычный production profiler. `KEYS *` на большой базе блокирует server.

## Снижение hot reads

- короткий local cache/request coalescing;
- client-side caching с invalidation;
- replica reads, если допустима staleness;
- precomputation и меньшее значение/reply;
- копии read-only value под несколькими shard keys с явной invalidation strategy.

Последний вариант распределяет reads, но усложняет writes и consistency.

## Снижение hot writes

Один точный counter/leaderboard member нельзя линейно масштабировать простым копированием. Возможны sharded counters с периодической aggregation, batching, rate limiting перед Redis или redesign требования к точности. Hash tag может случайно собрать разные горячие keys в один slot — проверяйте фактическую topology.

## Big keys

Разбейте unbounded collection по времени/tenant/bucket, ограничьте Stream/List/Sorted Set, используйте incremental commands (`SCAN`, `HSCAN`, `SSCAN`, `ZSCAN`) и асинхронное `UNLINK` для удаления больших keys, когда semantics допускает. Любое разбиение меняет atomicity и query pattern — сначала определите инварианты.

Следите за p99, event-loop utilization, evicted keys, output buffers, replica lag и reshard duration. Средняя latency скрывает hot-key incidents.

## Диагностика с ожидаемым смыслом

```text
INFO commandstats
SLOWLOG GET 10
MEMORY USAGE demo:large
SCAN 0 MATCH demo:* COUNT 100
```

commandstats помогает найти дорогой тип команд, но не доказывает какой key виноват. SLOWLOG измеряет исполнение команды, не всё сетевое ожидание клиента: медленный GET большого value может упираться в передачу. MEMORY USAGE возвращает оценку bytes, а не payload length. SCAN вернёт cursor и порцию; продолжайте до cursor 0, дедуплицируйте keys. COUNT — подсказка, не гарантия ровно 100 элементов.

Для одного ключа с 100000 reads/s local cache на 20 instances с TTL 1s может сильно сократить backend reads, но добавляет staleness. Для точного счётчика writes нельзя так же копировать состояние без согласования; шардированные счётчики дают сумму с задержкой или дорогой сборкой.

UNLINK отделяет удаление key из пространства имён от фонового освобождения памяти; освобождение не моментальное. Перенос большого key в Cluster всё ещё стоит сети и времени. Ограничивайте размер коллекций в модели, а не только настраивайте timeout клиента.

## Источники

- [Redis latency monitoring](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency-monitor/)
- [Diagnosing latency](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency/)
- [SCAN](https://redis.io/docs/latest/commands/scan/)

## Проверь себя

1. **Почему SLOWLOG пуст, а p99 высокий?**

   <details>
   <summary>Ответ</summary>

   Сеть, большой ответ, очередь клиента или соединения могут быть вне измеренного исполнения команды.

   </details>

2. **COUNT 100 в SCAN гарантирует 100 keys?**

   <details>
   <summary>Ответ</summary>

   Нет, это hint; возможны пустые порции и дубли при изменениях.

   </details>
