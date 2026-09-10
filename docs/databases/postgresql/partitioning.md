---
title: Партиционирование
description: Range, list и hash partitions, pruning и operational trade-offs.
tags: [databases, postgresql, performance]
updated: 2026-09-10
---

# Партиционирование

Declarative partitioning делит одну logical table на physical partitions по range, list или hash key. Оно полезно, когда queries/retention действительно совпадают с ключом, а не как автоматический способ «ускорить большую таблицу».

```sql
CREATE TABLE events (
    tenant_id bigint NOT NULL,
    occurred_at timestamptz NOT NULL,
    payload jsonb NOT NULL
) PARTITION BY RANGE (occurred_at);

CREATE TABLE events_2026_09 PARTITION OF events
FOR VALUES FROM ('2026-09-01') TO ('2026-10-01');
```

## Pruning

Planner/executor исключает partitions, границы которых несовместимы с predicate. Predicate должен быть выражен через partition key так, чтобы pruning мог его использовать; cast/function и generic parameter plan иногда ухудшают результат. Проверяйте `EXPLAIN` и `Subplans Removed`, а не только наличие clause.

## Польза

- быстрый retention через detach/drop partition вместо массового `DELETE`;
- smaller local indexes и vacuum domains;
- pruning больших диапазонов;
- разные tablespaces/settings для жизненного цикла данных.

## Цена и ограничения

- нужно заранее создавать/прикреплять partitions и обрабатывать default partition;
- слишком много partitions увеличивает planning time и memory;
- unique/primary constraint на partitioned table должен включать все partition key columns, чтобы уникальность можно было обеспечить локальными indexes;
- cross-partition `UPDATE` фактически перемещает row;
- schema/index changes и `ATTACH/DETACH` имеют lock implications;
- autovacuum не выполняет `ANALYZE` partitioned parent автоматически только из-за изменений children — планируйте обновление parent statistics.

Подбирайте granularity по retention, объёму, query predicates и operational cadence. «Одна partition на tenant» плохо масштабируется при тысячах tenants; hash subpartitioning тоже добавляет управление.

## Источники

- [Table partitioning](https://www.postgresql.org/docs/18/ddl-partitioning.html)
- [CREATE TABLE](https://www.postgresql.org/docs/18/sql-createtable.html)
