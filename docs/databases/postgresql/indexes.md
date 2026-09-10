---
title: Индексы
description: Типы индексов, составные и покрывающие индексы и их стоимость.
tags: [databases, postgresql, performance]
updated: 2026-09-10
---

# Индексы PostgreSQL

Индекс ускоряет часть чтений ценой дополнительного места, WAL, random I/O и работы при `INSERT`, `UPDATE`, `DELETE` и vacuum. Создавайте его под форму запроса и подтверждайте пользу через [EXPLAIN](explain.md) и production statistics.

## Основные типы

| Тип | Типичная задача |
| --- | --- |
| B-tree | equality, ranges, sorting, prefix/pattern при подходящей operator class |
| Hash | только equality; редко даёт преимущество перед B-tree |
| GIN | составные значения: arrays, `jsonb`, full-text; быстрая проверка membership, дорогая запись |
| GiST | extensible search tree: ranges, geometry, nearest-neighbor в подходящих opclasses |
| SP-GiST | partitioned search structures: tries, quadtrees и подходящие non-balanced data |
| BRIN | компактное summary по block ranges; выгоден для очень больших физически коррелированных данных |

Тип сам по себе ничего не гарантирует: доступные operators задаёт operator class.

## Составные индексы и порядок колонок

```sql
CREATE INDEX orders_customer_created_idx
ON orders (customer_id, created_at DESC, id DESC);
```

B-tree наиболее эффективен, когда ограничения на leading columns сокращают scan. Равенства слева и затем range/order — полезная отправная точка, но не механическое правило. PostgreSQL может применить skip scan или использовать часть индекса, однако стоимость зависит от числа distinct values и statistics.

## Специализированные варианты

```sql
CREATE INDEX users_lower_email_idx ON users (lower(email));

CREATE INDEX jobs_ready_idx ON jobs (priority, id)
WHERE status = 'ready';

CREATE INDEX orders_lookup_idx ON orders (customer_id, created_at)
INCLUDE (status, total);
```

- Expression index помогает только когда выражение запроса совпадает по смыслу с индексируемым.
- Partial index мал и дешёв, но planner должен доказать, что predicate запроса влечёт predicate индекса; произвольный parameterized clause может этому мешать.
- `INCLUDE` хранит payload для index-only scan, но included columns не участвуют в поиске/uniqueness и увеличивают индекс.
- Index-only scan также требует all-visible bit для heap page; иначе executor проверяет heap.

## Selectivity, cardinality и цена

Cardinality — число строк или distinct values; selectivity — доля строк, удовлетворяющая условию. Низкая selectivity часто делает sequential scan дешевле множества heap fetches. Correlation физического порядка с ключом влияет на стоимость range scan.

Слишком много индексов:

- усиливает WAL и write latency;
- снижает шанс HOT update;
- расходует cache и disk;
- удлиняет vacuum и recovery;
- может bloating при churn.

Смотрите `pg_stat_user_indexes`, размер через `pg_relation_size`, реальные планы и write profile. Не удаляйте индекс только из-за нулевого счётчика после недавнего restart или если он поддерживает constraint.

## Источники

- [Indexes](https://www.postgresql.org/docs/18/indexes.html)
- [Index types](https://www.postgresql.org/docs/18/indexes-types.html)
- [Index-only scans and covering indexes](https://www.postgresql.org/docs/18/indexes-index-only-scans.html)
