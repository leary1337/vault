---
title: Блокировки PostgreSQL
description: Row и table locks, advisory locks, deadlocks и optimistic concurrency.
tags: [databases, postgresql, locks]
updated: 2026-10-06
---

# Блокировки PostgreSQL

Блокировка заставляет конкурирующую операцию ждать: два списания одного остатка должны согласовать запись. До конца транзакции lock удерживает ресурсы, даже когда приложение уже ждёт внешний HTTP-запрос.

MVCC отвечает за видимость версий, но изменения схемы, конкурирующие writers и прикладные critical sections требуют locks. Обычный `SELECT` получает table-level `ACCESS SHARE`; его блокирует только `ACCESS EXCLUSIVE`, а блокировки строк обычному чтению не мешают.

## Режимы блокировок строк

| Clause | Блокирует конкурентный lock |
| --- | --- |
| `FOR UPDATE` | все четыре row-level mode |
| `FOR NO KEY UPDATE` | `FOR UPDATE`, `FOR NO KEY UPDATE`, `FOR SHARE` |
| `FOR SHARE` | `FOR UPDATE`, `FOR NO KEY UPDATE` |
| `FOR KEY SHARE` | только `FOR UPDATE` |

`DELETE` получает `FOR UPDATE`. `UPDATE` получает `FOR UPDATE`, если меняет определённые key columns, пригодные для foreign key, иначе более слабый `FOR NO KEY UPDATE`; набор колонок является implementation detail и может измениться.

```sql
BEGIN;
SELECT balance FROM accounts WHERE id = 42 FOR UPDATE;
UPDATE accounts SET balance = balance - 100 WHERE id = 42;
COMMIT;
```

`NOWAIT` сразу возвращает ошибку вместо ожидания row lock. `SKIP LOCKED` пропускает занятые строки и даёт несогласованный общий view, поэтому полезен для нескольких queue consumers, но не для обычных отчётов.

```sql
SELECT id
FROM jobs
WHERE status = 'ready'
ORDER BY id
FOR UPDATE SKIP LOCKED
LIMIT 10;
```

## Блокировки таблиц

PostgreSQL имеет восемь режимы блокировки таблиц от `ACCESS SHARE` до `ACCESS EXCLUSIVE`. Названия `ROW SHARE` и `ROW EXCLUSIVE` исторические: это всё table locks. DML автоматически берёт `ROW EXCLUSIVE`, обычный `CREATE INDEX` — `SHARE`, `CREATE INDEX CONCURRENTLY` — более слабые modes на разных этапах, многие DDL — `ACCESS EXCLUSIVE`. Проверяйте lock level конкретной команды перед миграцией.

## Взаимные блокировки и диагностика

PostgreSQL строит wait graph и после `deadlock_timeout` обнаруживает cycle, затем abort-ит одну transaction с `40P01`. Защита — единый порядок захвата ресурсов, короткие transaction и retry всей transaction.

```sql
SELECT a.pid,
       a.query,
       a.wait_event_type,
       a.wait_event,
       pg_blocking_pids(a.pid) AS blockers
FROM pg_stat_activity AS a
WHERE cardinality(pg_blocking_pids(a.pid)) > 0;
```

`pg_locks` показывает granted/waiting locks; соединяйте его с `pg_stat_activity`. `lock_timeout` ограничивает ожидание lock, а `statement_timeout` — весь statement.

## Advisory locks и оптимистическая проверка версии

Advisory lock имеет смысл только по договорённости приложения. Session-level lock переживает rollback и освобождается явно/при разрыве session; transaction-level `pg_advisory_xact_lock` автоматически освобождается в конце transaction и обычно безопаснее.

Optimistic concurrency не держит lock между чтением и записью:

```sql
UPDATE documents
SET body = $1, version = version + 1
WHERE id = $2 AND version = $3;
```

Ноль изменённых строк означает конфликт; клиент перечитывает данные или сообщает пользователю. Это не универсальная замена isolation: инварианты между несколькими строками требуют другого механизма. Продолжение: [isolation levels](isolation-levels.md) и [transactions](transactions.md).

## Воспроизвести deadlock

```sql
CREATE TABLE lock_demo(id integer PRIMARY KEY,value integer NOT NULL);
INSERT INTO lock_demo VALUES (1,0),(2,0);
```

| Шаг | A | B |
| --- | --- | --- |
| 1 | BEGIN; UPDATE lock_demo SET value=value+1 WHERE id=1 | |
| 2 | | BEGIN; UPDATE lock_demo SET value=value+1 WHERE id=2 |
| 3 | UPDATE lock_demo SET value=value+1 WHERE id=2 → ждёт | |
| 4 | | UPDATE lock_demo SET value=value+1 WHERE id=1 → ждёт |

После обнаружения цикла одна транзакция получает 40P01; приложение делает rollback и повтор целиком. Если обе захватывают id=1 затем id=2, цикл предотвращён. deadlock_timeout задаёт задержку проверки цикла, а не максимальное время любого ожидания.

```mermaid
flowchart LR
    A[A удерживает строку 1] -->|ждёт строку 2| B[B удерживает строку 2]
    B -->|ждёт строку 1| A
```

Для очереди захват и изменение статуса выполняются в одной короткой транзакции. Crash после commit выдачи требует lease/reaper и повтор: SKIP LOCKED не даёт exactly-once обработки. Ожидающий эксклюзивный DDL lock способен сформировать очередь запросов; ограничение lock_timeout помогает прервать миграцию, которая не получила lock вовремя.

## Источники

- [Explicit locking](https://www.postgresql.org/docs/18/explicit-locking.html)
- [Lock monitoring](https://www.postgresql.org/docs/18/view-pg-locks.html)
- [Client connection defaults and timeouts](https://www.postgresql.org/docs/18/runtime-config-client.html)

## Проверь себя

1. **Чем deadlock отличается от долгого ожидания?**

   <details>
   <summary>Ответ</summary>

   Есть цикл; длинная очередь без цикла сама не вызовет 40P01.

   </details>

2. **Что не решает SKIP LOCKED?**

   <details>
   <summary>Ответ</summary>

   Падение после выдачи работы, повтор side effect и starvation.

   </details>
