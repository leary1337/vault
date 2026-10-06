---
title: Sharding
description: Partition keys, routing, hotspots и online resharding.
tags: [distributed-systems, sharding]
updated: 2026-10-06
---

# Sharding

Sharding распределяет разные части данных между узлами; replica (копия данных на другом узле) хранит копию, shard (часть данных у отдельного владельца) — другую часть.

Sharding делит dataset между nodes, чтобы storage/write throughput (скорость успешной обработки) не ограничивались одной машиной. Цена — distributed queries, cross-shard invariants, resharding и новый routing layer.

## Стратегии

- Hash sharding равномерно распределяет случайные keys, но плохо поддерживает range scan и меняет много mappings при простом modulo.
- Range sharding сохраняет locality/ranges, но монотонный key создаёт write hotspot на последнем range.
- Directory-based routing хранит явную map key/range → shard и гибко перемещает данные, но metadata service становится critical control plane.
- Geo/tenant sharding соответствует ownership/compliance, но load между tenants/regions неравномерен.

Partition (раздел журнала или данных; при network partition — разрыв связи) key должен присутствовать в frequent queries, иметь достаточную cardinality (число разных значений или временных рядов) и распределять bytes/QPS, а не только row count. Один celebrity tenant/key способен перегрузить shard при формально равномерном количестве keys.

## Cross-shard cost

Scatter-gather отправляет запрос всем shards: tail latency (срок ответа) равна медленной стороне, а fan-out (раздача одного действия многим получателям) умножает traffic. Global secondary index сам становится distributed replicated system. Unique constraint, foreign key, join и transaction проще, когда связанные данные colocated.

Не выдавайте globally unique auto-increment с каждого shard без схемы. UUID, Snowflake-like ID или выделитель диапазонов имеют разные ordering/coordination trade-offs.

## Resharding

Online move требует согласованного protocol:

1. зафиксировать source/target и movement epoch (номер поколения);
2. скопировать snapshot;
3. догнать concurrent writes через log/dual routing;
4. атомарно переключить routing metadata;
5. выдержать старые clients/requests;
6. проверить и удалить source после safety window.

Наивный dual write создаёт divergence. Routing responses должны содержать version/redirect, а operations быть idempotent (без второго эффекта при повторе одного намерения). Capacity держит headroom (запас ресурса сверх обычной нагрузки) на потерю shard и migration traffic.

## Источники

- [Amazon Dynamo paper](https://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf)
- [Spanner paper](https://research.google/pubs/spanner-googles-globally-distributed-database/)

## Механизм на примере

Таблица 2 TB и нагрузка 20 000 writes/s не говорят, что нужны ровно десять shards: один tenant может давать половину нагрузки. Оцениваем распределение bytes/QPS и транзакционную близость. Для избранного `user_id` локализует список, но count популярного item требует другой модели.

Перенос shard: snapshot на позиции L → копирование → применение журнала после L → краткая остановка/ограждение старой записи → финальный catch-up → смена route epoch → перенаправление старых клиентов → проверка. Без точки, после которой старый owner не принимает writes, возможны две расходящиеся истории.

Глобальная уникальность email по user_id shards требует отдельной власти email/reservation либо единого шардируемого пространства по email. Проверка всех shards с последующей вставкой не атомарна. Cross-shard scatter на 100 узлов делает каждый запрос 100 запросами и наследует худший tail.

## Проверь себя

1. Чем shard отличается от replica?
2. Почему online copy недостаточно?

<details>
<summary>Ориентиры для ответа</summary>

1. Shard содержит часть набора, replica — копию той же части.
2. Во время него приходят новые изменения, нужны catch-up и fencing (отклонение действий старого владельца самим ресурсом) cutover.

</details>
