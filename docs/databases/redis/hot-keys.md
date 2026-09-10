---
title: Hot keys и big keys
description: Диагностика и снижение неравномерной нагрузки Redis.
tags: [databases, redis, performance]
updated: 2026-09-10
---

# Hot keys и big keys

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

## Источники

- [Redis latency monitoring](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency-monitor/)
- [Diagnosing latency](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency/)
- [SCAN](https://redis.io/docs/latest/commands/scan/)
