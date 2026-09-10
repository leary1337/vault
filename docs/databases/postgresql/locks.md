---
title: Блокировки PostgreSQL
description: Row и table locks, advisory locks, deadlocks и optimistic concurrency.
tags: [databases, postgresql, locks]
updated: 2026-09-10
---

# Блокировки PostgreSQL

MVCC отвечает за видимость версий, но изменения схемы, конкурирующие writers и прикладные critical sections требуют locks. Обычный `SELECT` получает table-level `ACCESS SHARE`; его блокирует только `ACCESS EXCLUSIVE`, а row locks обычному чтению не мешают.

## Row-level modes

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

## Table locks

PostgreSQL имеет восемь table-level modes от `ACCESS SHARE` до `ACCESS EXCLUSIVE`. Названия `ROW SHARE` и `ROW EXCLUSIVE` исторические: это всё table locks. DML автоматически берёт `ROW EXCLUSIVE`, обычный `CREATE INDEX` — `SHARE`, `CREATE INDEX CONCURRENTLY` — более слабые modes на разных этапах, многие DDL — `ACCESS EXCLUSIVE`. Проверяйте lock level конкретной команды перед миграцией.

## Deadlocks и monitoring

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

## Advisory и optimistic locks

Advisory lock имеет смысл только по договорённости приложения. Session-level lock переживает rollback и освобождается явно/при разрыве session; transaction-level `pg_advisory_xact_lock` автоматически освобождается в конце transaction и обычно безопаснее.

Optimistic concurrency не держит lock между чтением и записью:

```sql
UPDATE documents
SET body = $1, version = version + 1
WHERE id = $2 AND version = $3;
```

Ноль изменённых строк означает конфликт; клиент перечитывает данные или сообщает пользователю. Это не универсальная замена isolation: инварианты между несколькими строками требуют другого механизма. Продолжение: [isolation levels](isolation-levels.md) и [transactions](transactions.md).

## Источники

- [Explicit locking](https://www.postgresql.org/docs/18/explicit-locking.html)
- [Lock monitoring](https://www.postgresql.org/docs/18/view-pg-locks.html)
- [Client connection defaults and timeouts](https://www.postgresql.org/docs/18/runtime-config-client.html)
