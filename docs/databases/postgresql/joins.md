---
title: Joins
description: Логические joins, физические алгоритмы и типичные ошибки.
tags: [databases, postgresql, sql]
updated: 2026-09-10
---

# Joins

SQL join определяет логический результат, а planner выбирает физический алгоритм. Один и тот же `INNER JOIN` может выполняться nested loop, hash join или merge join.

## Логическая семантика

- `INNER JOIN` оставляет совпавшие пары.
- `LEFT/RIGHT/FULL OUTER JOIN` сохраняет строки одной или обеих сторон, подставляя `NULL`.
- `CROSS JOIN` строит декартово произведение.
- `LATERAL` позволяет правому subquery ссылаться на строки слева.
- `EXISTS` выражает semi-join «есть хотя бы одно совпадение» без размножения строк.

Predicate правой таблицы в `WHERE` после `LEFT JOIN` часто превращает результат в inner-like:

```sql
-- сохраняет customers без paid orders
SELECT c.id, o.id
FROM customers AS c
LEFT JOIN orders AS o
  ON o.customer_id = c.id
 AND o.status = 'paid';
```

Сравнения с `NULL` дают unknown; используйте `IS NULL`, `IS NOT NULL` или при нужной semantics `IS NOT DISTINCT FROM`.

## Физические алгоритмы

- Nested Loop хорош для малого outer input и быстрого parameterized lookup внутренней стороны; без индекса может стать квадратичным.
- Hash Join строит hash table для одной стороны и эффективен для equality joins; недостаточный `work_mem` приводит к batches/disk I/O.
- Merge Join требует отсортированных inputs и поддерживает equality/некоторые range patterns; сортировку могут дать indexes или explicit Sort nodes.

Planner выбирает join order по estimates. Ошибка cardinality на раннем узле умножается выше по дереву, поэтому проверяйте statistics и actual rows.

## Типичные ошибки

- join по неполному composite key создаёт дубликаты;
- `SELECT DISTINCT` маскирует неправильную cardinality;
- `NOT IN (subquery)` с `NULL` может вернуть ни одной строки — `NOT EXISTS` обычно выражает намерение яснее;
- функция/cast на join key может мешать обычному index condition;
- eager join многих one-to-many relations перемножает строки до aggregation.

## Источники

- [Table expressions](https://www.postgresql.org/docs/18/queries-table-expressions.html)
- [Planner join control](https://www.postgresql.org/docs/18/explicit-joins.html)
