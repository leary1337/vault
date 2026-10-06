---
title: Capacity estimation
description: QPS, storage, bandwidth, concurrency и headroom.
tags: [system-design, capacity]
updated: 2026-10-06
---

# Capacity estimation

Оценка ёмкости — арифметика с явными допущениями, позволяющая найти дорогой ресурс.

Оценка порядка величины обнаруживает bottleneck и проверяет feasibility. Не выдавайте неизвестную точность за факт: фиксируйте assumptions и диапазоны.

## Базовые формулы

```text
average QPS = operations per day / 86,400
concurrency ≈ arrival rate × average time in system
raw storage = records/s × bytes/record × retention seconds
network = requests/s × bytes/request/response
```

Затем примените peak factor, replication, indexes/metadata, compression, headroom (запас ресурса сверх обычной нагрузки) и growth. Для очереди: `backlog growth = arrival rate - service rate`; если положительно долго, buffer лишь откладывает отказ.

## Пример

100 млн events/day ≈ 1,160 events/s average. При peak ×8 — 9,300/s. Payload (полезное содержимое запроса или события) 1 KiB даёт около 8.6 TiB raw за 100 дней; RF=3 — 25.8 TiB до compression/segment/index overhead. Consumer (потребитель работы или контракта) outage 2 часа на peak создаёт ~67 млн events backlog (накопившаяся необработанная работа).

Проверьте skew: 1% keys может создавать 80% traffic. Среднее распределение по shards не защищает hot partition (раздел журнала или данных; при network partition — разрыв связи).

## Что связать с design

- DB connection count = pool × application replicas, не один pool;
- timeout × QPS (число запросов в секунду) задаёт верхнюю in-flight нагрузку;
- cache hit ratio переводите в remaining DB QPS;
- failover capacity должна выдержать потерю node/zone и recovery traffic;
- retention/delete/backup влияют на disk I/O, не только bytes.

После rough estimate проведите benchmark/load test на реалистичном data shape. Обновляйте таблицу assumptions фактическими метриками.

## На конкретном примере

```text
Дано: 10 млн requests/day, пик ×10, response=20 KiB
Среднее: 10 000 000 / 86 400 ≈ 116 requests/s
Пик: 1 160 requests/s
Трафик на пике: 1 160 × 20 KiB ≈ 23.8 MB/s
При среднем времени 80 ms: около 93 активных запросов на пике
```

Последняя формула использует среднее время в устойчивой системе. Подставить p99 (время, в которое укладывается 99% наблюдений)=500 ms и назвать результат средним числом запросов неправильно. Для защиты concurrency берём измеренное распределение, лимит очереди и worst-case deadline (крайний срок завершения) отдельно. После потери одной из трёх равных реплик две оставшиеся получают в 1,5 раза больше нагрузки ещё до восстановления данных.

## Источник механизма

[Google SRE: Handling Overload, границы QPS](https://sre.google/sre-book/handling-overload/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Когда применима формула concurrency=rate×time?
2. Что забывают в storage estimate?

<details>
<summary>Ориентиры для ответа</summary>

1. Для согласованных средних величин устойчивого потока.
2. Индексы, реплики, резерв, версии, backup и временную копию при migration.

</details>
