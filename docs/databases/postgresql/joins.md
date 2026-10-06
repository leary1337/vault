---
title: Joins
description: Логические joins, физические алгоритмы и типичные ошибки.
tags: [databases, postgresql, sql]
updated: 2026-10-06
---

# Joins

JOIN соединяет строки по условию. Три заказа клиента дают три строки результата с этим клиентом; это ожидаемая кратность.

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
- Merge Join требует отсортированных inputs и использует подходящее merge-joinable равенство; сортировку могут дать indexes или explicit Sort nodes.

Planner выбирает join order по estimates. Ошибка cardinality на раннем узле умножается выше по дереву, поэтому проверяйте statistics и actual rows.

## Типичные ошибки

- join по неполному composite key создаёт дубликаты;
- `SELECT DISTINCT` маскирует неправильную cardinality;
- `NOT IN (subquery)` с `NULL` может вернуть ни одной строки — `NOT EXISTS` обычно выражает намерение яснее;
- функция/cast на join key может мешать обычному index condition;
- eager join многих one-to-many relations перемножает строки до aggregation.

## LEFT JOIN и NULL

```sql
CREATE TABLE join_customers(id integer PRIMARY KEY);
CREATE TABLE join_orders(id integer PRIMARY KEY,customer_id integer,status text);
INSERT INTO join_customers VALUES (1),(2);
INSERT INTO join_orders VALUES (10,1,'paid'),(11,1,'new');
SELECT c.id AS customer,o.id AS paid_order
FROM join_customers c LEFT JOIN join_orders o
ON o.customer_id=c.id AND o.status='paid' ORDER BY c.id;
-- (1,10), (2,NULL)
```

Перенесите status='paid' в WHERE: строка (2,NULL) исчезнет, потому что условие даёт unknown, а WHERE сохраняет только true. Если нужны клиенты с хотя бы одним paid-заказом, EXISTS не размножает строки.

```sql
SELECT 2 NOT IN (SELECT customer_id FROM join_orders
                 UNION ALL SELECT NULL::integer);
-- NULL (unknown), не true
```

NOT EXISTS не имеет этой ловушки списка с NULL. Две независимые one-to-many связи способны перемножить строки и завысить SUM; сначала агрегируйте стороны на правильной кратности.

В PostgreSQL Merge Join требует подходящего merge-joinable равенства. Дополнительный range predicate может проверяться как фильтр; это не означает поддержку произвольного диапазонного соединения. Hash Join также требует подходящего equality-условия.

## Источники

- [Table expressions](https://www.postgresql.org/docs/18/queries-table-expressions.html)
- [Planner join control](https://www.postgresql.org/docs/18/explicit-joins.html)

## Проверь себя

1. **Зачем правый фильтр в ON при LEFT JOIN?**

   <details>
   <summary>Ответ</summary>

   Чтобы сохранить левую строку без подходящего правого совпадения.

   </details>

2. **Почему SUM после двух JOIN завышена?**

   <details>
   <summary>Ответ</summary>

   Связи one-to-many перемножили строки; сначала нужно определить и сохранить кратность.

   </details>
