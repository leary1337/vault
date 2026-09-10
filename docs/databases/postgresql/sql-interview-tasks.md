---
title: SQL-задачи
description: Практические задачи на joins, windows, aggregation и concurrency.
tags: [databases, postgresql, sql, interviews]
updated: 2026-09-10
---

# SQL-задачи

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

## Источники

- [Window functions](https://www.postgresql.org/docs/18/tutorial-window.html)
- [SELECT](https://www.postgresql.org/docs/18/sql-select.html)
- [Data manipulation](https://www.postgresql.org/docs/18/dml.html)
