---
title: Транзакции
description: Границы транзакций, savepoints, ошибки и прикладные инварианты.
tags: [databases, postgresql, transactions]
updated: 2026-10-06
---

# Транзакции

Транзакция сохраняет группу изменений целиком или отменяет их. Перевод должен менять оба счёта вместе; проверка достаточного остатка тоже относится к этой операции.

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

## Перевод с проверкой остатка

```sql
CREATE TABLE transfer_accounts(
    id integer PRIMARY KEY,balance bigint NOT NULL CHECK(balance>=0)
);
INSERT INTO transfer_accounts VALUES (1,500),(2,100);
BEGIN;
SELECT id FROM transfer_accounts WHERE id IN (1,2) ORDER BY id FOR UPDATE;
UPDATE transfer_accounts SET balance=balance-200
WHERE id=1 AND balance>=200 RETURNING balance;
-- продолжать только если возвращена одна строка; иначе ROLLBACK
UPDATE transfer_accounts SET balance=balance+200 WHERE id=2;
COMMIT;
SELECT * FROM transfer_accounts ORDER BY id;
-- (1,300), (2,300)
```

Для реального перевода проверьте положительную сумму, существование обоих счетов и одинаковый порядок захвата для всех writers. CHECK не исключает зачисление без списания.

В Go внутри транзакции вызывайте методы tx, а не db: иначе запрос уйдёт через другое соединение. После BeginTx запланируйте rollback при выходе и проверьте ошибку commit. Сетевая ошибка во время commit может означать неизвестный исход; уникальный ключ перевода и результат должны сохраняться в той же транзакции. Rollback не откатывает отправленное письмо и выданное значение sequence: пропуски identity допустимы.

## Источники

- [Transactions tutorial](https://www.postgresql.org/docs/18/tutorial-transactions.html)
- [Error codes](https://www.postgresql.org/docs/18/errcodes-appendix.html)

## Проверь себя

1. **Почему CHECK(balance>=0) недостаточен?**

   <details>
   <summary>Ответ</summary>

   Он не требует второй стороны перевода и не исключает повтор операции.

   </details>

2. **Что делать при потере соединения во время COMMIT?**

   <details>
   <summary>Ответ</summary>

   Проверять результат по ключу операции; слепой повтор способен выполнить перевод дважды.

   </details>
