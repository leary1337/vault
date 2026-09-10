---
title: Query planner
description: Statistics, cost model, join order и plan cache.
tags: [databases, postgresql, performance]
updated: 2026-09-10
---

# Query planner

Planner перечисляет допустимые paths и выбирает план с наименьшей оценочной cost. Cost — безразмерная модель, а не миллисекунды; её компоненты зависят от оценённого числа rows, I/O, CPU, parallelism и параметров сервера.

## Statistics

`ANALYZE` собирает samples и хранит в `pg_statistic`/`pg_stats`:

- estimated distinct count;
- most common values и frequencies;
- histogram bounds;
- null fraction;
- physical correlation.

Независимые column statistics ошибаются при корреляции. `CREATE STATISTICS` добавляет extended statistics для dependencies, multivariate distinct counts и most-common combinations.

```sql
CREATE STATISTICS orders_customer_status_stats
    (dependencies, mcv)
ON customer_id, status
FROM orders;

ANALYZE orders;
```

Если estimated rows сильно расходятся с actual rows, сначала проверяйте свежесть/качество statistics и распределение данных, а не отключайте scan или join method.

## Что влияет на план

- predicates и доступные indexes/operator classes;
- `ORDER BY`, `LIMIT`, grouping и required output;
- `work_mem` для sort/hash, parallel settings;
- `random_page_cost`, `seq_page_cost`, effective cache assumptions;
- join order и число tables;
- parameter values и custom/generic prepared plan.

Planner не знает реальную текущую cache residency, будущую конкуренцию или прикладную стоимость tail latency. Configuration parameters калибруют модель к storage/workload; менять их под один запрос опасно.

## Диагностика

1. Получите безопасный [`EXPLAIN (ANALYZE, BUFFERS)`](explain.md).
2. Найдите первый узел снизу, где estimate расходится с actual.
3. Проверьте stale statistics, skew, correlation, casts/functions и predicates.
4. Сократите объём данных раньше, добавьте подходящий index или перепишите запрос.
5. Повторите измерение на репрезентативных данных.

## Источники

- [Planner statistics](https://www.postgresql.org/docs/18/planner-stats.html)
- [Query planning configuration](https://www.postgresql.org/docs/18/runtime-config-query.html)
- [Prepared statements](https://www.postgresql.org/docs/18/sql-prepare.html)
