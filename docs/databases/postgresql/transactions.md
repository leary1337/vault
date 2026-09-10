---
title: Транзакции
description: Границы транзакций, savepoints, ошибки и прикладные инварианты.
tags: [databases, postgresql, transactions]
updated: 2026-09-10
---

# Транзакции

Транзакция группирует операции в атомарную единицу: `COMMIT` публикует изменения, `ROLLBACK` отменяет их. Без явного `BEGIN` каждый statement работает в отдельной implicit transaction.

```sql
BEGIN;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;
```

Согласованность не возникает автоматически: ограничения (`NOT NULL`, `CHECK`, `UNIQUE`, foreign keys), isolation level, locking и код приложения вместе защищают бизнес-инварианты.

## Ошибки и savepoints

После ошибки явная транзакция остаётся в aborted state: до `ROLLBACK` или `ROLLBACK TO SAVEPOINT` дальнейшие команды не выполняются.

```sql
BEGIN;
SAVEPOINT before_optional_step;
-- операция может завершиться ошибкой
ROLLBACK TO SAVEPOINT before_optional_step;
COMMIT;
```

Savepoint не является отдельной durable transaction. Слишком глубокое или частое использование добавляет overhead и не заменяет корректную обработку ошибок.

## Практика backend-приложения

- Держите transaction короткой: не ждите внутри неё сеть или пользователя.
- Передавайте один transaction handle всем repository-операциям unit of work.
- Учитывайте неопределённый исход: если соединение оборвалось во время `COMMIT`, клиент может не знать, применился ли commit. Нужны idempotency key или проверка результата.
- Повторяйте только всю transaction при `40001` (`serialization_failure`) и `40P01` (`deadlock_detected`), с ограничением попыток и jitter.
- `statement_timeout`, `lock_timeout` и `idle_in_transaction_session_timeout` ограничивают разные виды зависания.

Большинство DDL в PostgreSQL транзакционно, но не все команды разрешены внутри transaction block, например `CREATE DATABASE` и `VACUUM`.

## Источники

- [Transactions tutorial](https://www.postgresql.org/docs/18/tutorial-transactions.html)
- [Error codes](https://www.postgresql.org/docs/18/errcodes-appendix.html)
