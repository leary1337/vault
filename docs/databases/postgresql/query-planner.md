---
title: Query planner
description: Statistics, cost model, join order и plan cache.
tags: [databases, postgresql, performance]
updated: 2026-10-06
---

# Query planner

Планировщик оценивает способы выполнения по статистике. Если ожидает 10 строк, а получает миллион, выбранный алгоритм может стать очень дорогим.

Planner перечисляет допустимые paths и выбирает план с наименьшей оценочной cost. Cost — безразмерная модель, а не миллисекунды; её компоненты зависят от оценённого числа rows, I/O, CPU, parallelism и параметров сервера.

## Статистика

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

## Перекос распределения

```sql
CREATE TABLE plan_orders(id integer PRIMARY KEY,tenant_id integer NOT NULL);
INSERT INTO plan_orders
SELECT n,CASE WHEN n<=90000 THEN 1 ELSE n END
FROM generate_series(1,100000) AS n;
CREATE INDEX plan_orders_tenant_idx ON plan_orders(tenant_id);
ANALYZE plan_orders;
PREPARE find_tenant(integer) AS SELECT * FROM plan_orders WHERE tenant_id=$1;
EXPLAIN EXECUTE find_tenant(1);
EXPLAIN EXECUTE find_tenant(99999);
DEALLOCATE find_tenant;
```

Для tenant 1 подходят 90000 строк, для 99999 одна. Первая ситуация может предпочесть Seq Scan, вторая Index Scan. PostgreSQL при auto сначала использует custom plans и затем сравнивает общий план со средней стоимостью custom. Prepared statement не всегда generic. Для диагностики в отдельной сессии сравните force_custom_plan и force_generic_plan через plan_cache_mode; это эксперимент, не глобальное исправление.

Коррелированные поля страны и города требуют extended statistics; они помогают внутри таблицы, но не исправляют автоматически любую оценку join нескольких таблиц. Statistics target увеличивает детализацию и стоимость ANALYZE. Не превращайте отключение Seq Scan в постоянный обход неправильной статистики.

## Источники

- [Planner statistics](https://www.postgresql.org/docs/18/planner-stats.html)
- [Query planning configuration](https://www.postgresql.org/docs/18/runtime-config-query.html)
- [Prepared statements](https://www.postgresql.org/docs/18/sql-prepare.html)

## Проверь себя

1. **Почему одному SQL нужны разные планы для разных tenants?**

   <details>
   <summary>Ответ</summary>

   Одна строка и 90% таблицы имеют разную стоимость index/heap чтения.

   </details>

2. **cost=100 означает 100 ms?**

   <details>
   <summary>Ответ</summary>

   Нет, это относительная стоимость модели.

   </details>
