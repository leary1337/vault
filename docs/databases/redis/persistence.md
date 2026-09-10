---
title: Persistence
description: RDB, AOF, fsync, restart и backup trade-offs.
tags: [databases, redis, durability]
updated: 2026-09-10
---

# Persistence Redis

Redis Open Source поддерживает RDB snapshots, AOF, их комбинацию или работу без persistence. Выбор начинается с допустимой потери данных и recovery time, а не с default configuration.

## RDB

RDB — point-in-time snapshot. Он компактен, удобен для backup и обычно быстро загружается, но crash между snapshots теряет изменения после последнего снимка. `BGSAVE` fork-ает child; при большом dataset и активной записи copy-on-write увеличивает RSS и может вызвать latency spike.

## AOF

AOF записывает write commands и восстанавливает dataset replay-ем. Политики fsync:

- `always` — fsync каждого write, максимальная latency и более сильная local durability;
- `everysec` — типичный компромисс, возможна потеря примерно последних секунд при аварии;
- `no` — решение о flush оставлено ОС.

С Redis 7 AOF состоит из base и incremental files, управляемых manifest. Rewrite компактизирует history, но тоже использует background child и ресурсы. Если включены AOF и RDB, restart использует более полный AOF dataset.

## Что persistence не решает

- asynchronous replica failover всё ещё может потерять acknowledged write;
- ошибочный `DEL` корректно попадёт в AOF/replicas;
- локальный файл не защищает от потери host/volume;
- corrupted или непроверенный backup не даёт гарантированного recovery.

Архивируйте snapshots/AOF согласно threat model, шифруйте и ограничивайте доступ, регулярно выполняйте restore test. Наблюдайте последний успешный save, AOF rewrite/fsync status, fork time, disk space и loading time.

Cache с воспроизводимыми данными часто может работать без persistence, но restart тогда создаёт cold-cache surge — capacity primary storage должна его выдержать.

## Источники

- [Redis persistence](https://redis.io/docs/latest/operate/oss_and_stack/management/persistence/)
- [Latency caused by fork](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency/)
