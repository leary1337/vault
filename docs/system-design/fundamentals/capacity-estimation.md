---
title: Capacity estimation
description: QPS, storage, bandwidth, concurrency и headroom.
tags: [system-design, capacity]
updated: 2026-09-10
---

# Capacity estimation

Оценка порядка величины обнаруживает bottleneck и проверяет feasibility. Не выдавайте неизвестную точность за факт: фиксируйте assumptions и диапазоны.

## Базовые формулы

```text
average QPS = operations per day / 86,400
concurrency ≈ arrival rate × average time in system
raw storage = records/s × bytes/record × retention seconds
network = requests/s × bytes/request/response
```

Затем примените peak factor, replication, indexes/metadata, compression, headroom и growth. Для очереди: `backlog growth = arrival rate - service rate`; если положительно долго, buffer лишь откладывает отказ.

## Пример

100 млн events/day ≈ 1,160 events/s average. При peak ×8 — 9,300/s. Payload 1 KiB даёт около 8.6 TiB raw за 100 дней; RF=3 — 25.8 TiB до compression/segment/index overhead. Consumer outage 2 часа на peak создаёт ~67 млн events backlog.

Проверьте skew: 1% keys может создавать 80% traffic. Среднее распределение по shards не защищает hot partition.

## Что связать с design

- DB connection count = pool × application replicas, не один pool;
- timeout × QPS задаёт верхнюю in-flight нагрузку;
- cache hit ratio переводите в remaining DB QPS;
- failover capacity должна выдержать потерю node/zone и recovery traffic;
- retention/delete/backup влияют на disk I/O, не только bytes.

После rough estimate проведите benchmark/load test на реалистичном data shape. Обновляйте таблицу assumptions фактическими метриками.
