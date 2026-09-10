---
title: Репликация Redis
description: Async replication, partial resync, WAIT и consistency limits.
tags: [databases, redis, replication]
updated: 2026-09-10
---

# Репликация Redis

Redis replication обычно asynchronous: primary подтверждает write, не ожидая replicas. Реплики помогают чтению, recovery и HA, но между acknowledgement и replication остаётся окно потери данных при failover.

## Synchronization

Primary хранит replication ID, offset и backlog последних изменений. После короткого disconnect replica просит partial resynchronization (`PSYNC`) и получает недостающий suffix, если нужный offset ещё в backlog. Иначе требуется full resync: snapshot dataset плюс накопившийся stream изменений.

Размер backlog должен покрывать типичное окно disconnect × write throughput с запасом. Full resync больших datasets нагружает CPU, memory, disk/network и способен вызвать каскадный latency incident.

## Reads и acknowledged copies

Replica read может быть stale: учитывайте replication lag и read-after-write. По умолчанию replica остаётся read-only для clients, но это не превращает её в immutable storage.

`WAIT replicas timeout` ждёт подтверждения предыдущих writes указанным числом replicas и уменьшает вероятность потери, но официальная документация прямо отмечает: это не превращает Redis в strongly consistent CP system. Failover и persistence configuration всё ещё влияют на сохранность. В актуальных версиях также есть `WAITAOF` для ожидания fsync на local/replica instances; он улучшает durability конкретной записи, но не заменяет полный consistency design.

`min-replicas-to-write` и `min-replicas-max-lag` могут остановить writes при недостатке достаточно свежих replicas. Это ограничивает риск, но снижает availability и основано на наблюдаемом lag, а не на consensus commit.

## Operations

Наблюдайте `INFO replication`: role, connected replicas, offsets, lag, backlog и sync state. Проверяйте network bandwidth, full-sync frequency, diskless/disk-based sync choice и время promotion. Replica и persistence не заменяют независимый backup: логическая ошибка реплицируется.

## Источники

- [Redis replication](https://redis.io/docs/latest/operate/oss_and_stack/management/replication/)
- [WAIT](https://redis.io/docs/latest/commands/wait/)
- [WAITAOF](https://redis.io/docs/latest/commands/waitaof/)
