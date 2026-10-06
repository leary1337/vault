---
title: Sharding в System Design
description: Partition key, routing, cross-shard cost и resharding.
tags: [system-design, sharding]
updated: 2026-10-06
---

# Sharding в System Design

Шардирование делит данные; ключ определяет, какие операции локальны, а какие пойдут на много узлов.

Sharding нужен, когда подтверждённый storage/write/working-set bottleneck не помещается на один node и simpler vertical scaling/partitioning исчерпаны.

## Ключ шардирования

Хороший key:

- присутствует в частых requests;
- распределяет QPS (число запросов в секунду) и bytes, а не только количество rows;
- colocate-ит данные одного transaction/aggregate;
- имеет route без scatter-gather;
- допускает split горячего tenant/key.

Hash даёт равномерность, range — range locality/retention, directory — гибкое placement. Tenant sharding упрощает isolation/migration, но большие tenants требуют отдельной стратегии.

## Цена

Cross-shard (часть данных у отдельного владельца) join, unique constraint, transaction, secondary index и aggregation становятся distributed workflows. Scatter-gather умножает load и наследует tail самого медленного shard. Global ID должен иметь отдельную scheme.

Online resharding — copy + change capture + versioned routing + cutover + verification; naive dual write расходится. Держите headroom (запас ресурса сверх обычной нагрузки) для migration и потери node.

Сначала измерьте hot keys и skew. Иногда достаточно partitioned table, read replica (копия данных на другом узле), cache или переноса одного workload. Подробнее: [distributed sharding](../../distributed-systems/sharding.md).

## На конкретном примере

Избранное шардируем по user_id, чтобы список и обновления одной связи были локальны. Подсчёт добавлений item всеми users требует производного агрегата. Выбор item_id сделал бы обратную задачу локальной, но список пользователя — scatter по shards.

Переезд shard требует snapshot + changes + cutover epoch (номер поколения) + запрет старых writes. При переносе храним обе копии, значит нужен запас диска и сетевого потока. Global unique constraint не появляется от десяти локальных unique indexes; для глобального ключа нужен единый owner/reservation.

## Источник механизма

[Dynamo: partitioning](https://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Что определяет partition (раздел журнала или данных; при network partition — разрыв связи) key?
2. Как понять, что sharding преждевременен?

<details>
<summary>Ориентиры для ответа</summary>

1. Локальность запросов, транзакций и горячих областей.
2. Нет измеренного предела одного узла или можно проще изменить query/index/cache/workload.

</details>
