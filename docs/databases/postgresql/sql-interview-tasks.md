---
title: SQL-задачи
description: Практические задачи на joins, windows, aggregation и concurrency.
tags: [databases, postgresql, sql, interviews]
updated: 2026-10-06
---

# SQL-задачи

SQL-задача проверяет смысл результата: что считать последним, как обрабатывать равенства и NULL, как не перемножить строки и что происходит при конкуренции.

Ниже важен не только результат, но и предположения о `NULL`, duplicates, ties, indexes и concurrent changes.

## Последний заказ каждого клиента

```sql
SELECT DISTINCT ON (customer_id)
       customer_id, id, created_at, total
FROM orders
ORDER BY customer_id, created_at DESC, id DESC;
```

Для top N используйте `row_number()` с тем же deterministic order. Индекс `(customer_id, created_at DESC, id DESC)` может уменьшить работу.

## Клиенты без заказов

```sql
SELECT c.id
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1 FROM orders AS o WHERE o.customer_id = c.id
);
```

Объясните отличие от `NOT IN` при наличии `NULL`.

## Накопительный итог

```sql
SELECT account_id,
       occurred_at,
       id,
       amount,
       sum(amount) OVER (
           PARTITION BY account_id
           ORDER BY occurred_at, id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS balance
FROM ledger;
```

Явный `ROWS` и unique tie-breaker устраняют неоднозначность peers.

## Удаление дублей с сохранением одной строки

```sql
WITH ranked AS (
    SELECT id,
           row_number() OVER (
               PARTITION BY email
               ORDER BY created_at, id
           ) AS rn
    FROM users
)
DELETE FROM users AS u
USING ranked AS r
WHERE u.id = r.id AND r.rn > 1;
```

После cleanup закрепите правило `UNIQUE`, иначе race вернёт дубли.

## Worker queue без двойной выдачи

```sql
WITH picked AS (
    SELECT id
    FROM jobs
    WHERE status = 'ready'
    ORDER BY priority DESC, id
    FOR UPDATE SKIP LOCKED
    LIMIT 10
)
UPDATE jobs AS j
SET status = 'running', started_at = clock_timestamp()
FROM picked AS p
WHERE j.id = p.id
RETURNING j.*;
```

Обсудите retry, lease/reaper для умершего worker, starvation и то, почему `SKIP LOCKED` подходит очереди, но даёт inconsistent view.

## Перед собеседованием

Умейте читать plan, объяснять [изоляцию](isolation-levels.md), выбирать [индекс](indexes.md), замечать fan-out joins и писать запросы с window functions без скрытого nondeterminism.

## Данные и ожидаемые результаты

Для первых двух задач:

```sql
CREATE TABLE customers(id bigint PRIMARY KEY);
CREATE TABLE orders(
    id bigint PRIMARY KEY,customer_id bigint REFERENCES customers,
    created_at timestamptz NOT NULL,total numeric(12,2) NOT NULL
);
INSERT INTO customers VALUES (1),(2),(3);
INSERT INTO orders VALUES
(10,1,'2026-10-01 UTC',100),(11,1,'2026-10-01 UTC',200),
(12,2,'2026-10-02 UTC',300);
```

DISTINCT ON выше выбирает заказ 11 клиента 1 и заказ 12 клиента 2; клиент 3 попадёт в NOT EXISTS. id DESC однозначно разрешает одинаковые даты.

```sql
WITH ranked AS (
    SELECT *,row_number() OVER (
        PARTITION BY customer_id ORDER BY created_at DESC,id DESC
    ) AS rn FROM orders
)
SELECT customer_id,id,total FROM ranked WHERE rn<=2
ORDER BY customer_id,rn;
-- (1,11,200), (1,10,100), (2,12,300)

SELECT customer_id,count(*) AS orders_count,avg(total) AS average_total
FROM orders GROUP BY customer_id HAVING count(*)>=2;
-- customer_id=1, orders_count=2, average_total=150
```

row_number даёт не более N строк; dense_rank по дате может дать больше при ties. WHERE фильтрует до группировки, HAVING после. count(column) пропускает NULL, count(*) считает строки. sum пустого набора возвращает NULL: coalesce уместен только если ноль выражает смысл отсутствия данных. Примеры ledger/users/jobs выше — отдельные модели; определите для них схему и ограничения, они не используют эти таблицы.

## Источники

- [Window functions](https://www.postgresql.org/docs/18/tutorial-window.html)
- [SELECT](https://www.postgresql.org/docs/18/sql-select.html)
- [Data manipulation](https://www.postgresql.org/docs/18/dml.html)

## Проверь себя

1. **Как top-2 может вернуть больше двух строк?**

   <details>
   <summary>Ответ</summary>

   Rank/dense_rank по значению включает ties; нужно заранее определить смысл top.

   </details>

2. **Почему HAVING count(*)>=2 не заменить WHERE?**

   <details>
   <summary>Ответ</summary>

   Размер группы известен только после агрегации.

   </details>
