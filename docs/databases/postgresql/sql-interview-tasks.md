---
title: SQL-задачи
description: "Запросы с понятным результатом: последние строки, отсутствие заказов, суммы и очередь задач."
tags: [databases, postgresql, sql, interviews]
updated: 2026-10-06
---

# SQL-задачи

SQL-задача проверяет смысл результата: что считать последним, как обрабатывать равенства и NULL, как не перемножить строки и что происходит при конкуренции.

У каждой задачи сначала определите смысл результата: одну строку или все равные первые места, включает ли набор `NULL`, может ли другой клиент менять данные. Таблицы для запуска первых двух задач приведены в разделе с данными. Остальные фрагменты показывают отдельные модели, их схема задаётся отдельно.

## Последний заказ каждого клиента

```sql
SELECT DISTINCT ON (customer_id)
       customer_id, id, created_at, total
FROM orders
ORDER BY customer_id, created_at DESC, id DESC;
```

`DISTINCT ON` оставляет первую строку каждого клиента в заданном порядке. Дата сортируется по убыванию, при равенстве побеждает больший id. Для нескольких строк клиента используйте `row_number()`: он нумерует их в том же порядке, затем условие выбирает первые N. Индекс `(customer_id,created_at DESC,id DESC)` может убрать отдельную сортировку.

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

Оконная сумма не объединяет строки в одну: она добавляет текущий итог к каждой записи. `PARTITION BY` начинает счёт отдельно для каждого счёта, `ORDER BY` задаёт порядок, `ROWS ... CURRENT ROW` включает все предыдущие строки и текущую. Уникальный id разрешает одинаковое время, поэтому промежуточный баланс однозначен.

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

`row_number()` нумерует строки одинакового email по времени и id. Строка с номером 1 остаётся, остальные удаляются. Затем ограничение уникальности защищает от новых дублей; сама однократная очистка не мешает другому клиенту создать следующий.

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

Команда выбирает свободные готовые задачи и в той же транзакции отмечает их running. Но падение после выдачи оставит такую задачу зависшей: нужен срок владения и возврат просроченных задач. Постоянно занятые строки могут долго пропускаться. Повторный внешний эффект защищается отдельно; `SKIP LOCKED` намеренно не показывает полный согласованный набор очереди.

## Перед собеседованием

Для каждого запроса проверьте [план](explain.md), [изоляцию](isolation-levels.md), [индекс](indexes.md) и число строк результата. Несколько совпадений JOIN могут умножить строки; порядок без уникального дополнительного ключа может выбрать разные записи.

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

`row_number` возвращает не более N выбранных строк, а `dense_rank` по дате может включить много строк одного места. `WHERE` фильтрует строки до группировки, `HAVING` — готовые группы. `count(column)` пропускает `NULL`, `count(*)` считает строки. Сумма пустого набора — `NULL`; заменять её на 0 через `coalesce` стоит только когда это соответствует смыслу отсутствия данных.

## Источники

- [Window functions](https://www.postgresql.org/docs/18/tutorial-window.html)
- [SELECT](https://www.postgresql.org/docs/18/sql-select.html)
- [Data manipulation](https://www.postgresql.org/docs/18/dml.html)

## Проверь себя

1. **Почему выбор первых двух мест иногда даёт больше двух строк?**

   <details>
   <summary>Ответ</summary>

   Rank или dense_rank включает все строки одинакового места. Row_number ограничивает число строк; сначала уточните смысл первых мест.

   </details>

2. **Почему HAVING count(*)>=2 нельзя заменить WHERE?**

   <details>
   <summary>Ответ</summary>

   Размер группы известен после группировки. WHERE фильтрует отдельные строки до неё.

   </details>
