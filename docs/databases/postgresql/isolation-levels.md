---
title: Уровни изоляции
description: Read Committed, Repeatable Read и Serializable именно в PostgreSQL.
tags: [databases, postgresql, transactions]
updated: 2026-10-06
---

# Уровни изоляции PostgreSQL

Изоляция отвечает на вопрос: что случится, если два клиента одновременно выполнят правильные по отдельности операции? Serializable допускает только результат, возможный при некотором последовательном порядке успешно завершённых транзакций.

PostgreSQL принимает четыре SQL-названия, но `READ UNCOMMITTED` ведёт себя как `READ COMMITTED`. Реально различаются три режима.

| Уровень | Snapshot | Что важно |
| --- | --- | --- |
| Read Committed | новый на каждый statement | default; два SELECT в одной transaction могут увидеть разные данные |
| Repeatable Read | один с первого non-control statement | snapshot isolation; в PostgreSQL также не допускает phantom read, но возможны serialization anomalies |
| Serializable | как Repeatable Read + SSI | результат эквивалентен некоторому последовательному порядку или transaction получает `40001` |

## Аномалии

- Dirty read в PostgreSQL не возникает на этих уровнях.
- Non-repeatable read и phantom возможны в Read Committed, но предотвращаются PostgreSQL Repeatable Read.
- Lost update возможен как прикладной read-modify-write в Read Committed: оба клиента читают старое значение и затем записывают вычисленный результат. Атомарный `UPDATE ... SET x = x + 1`, row lock или version predicate решают разные варианты проблемы.
- Write skew возможен в Repeatable Read: транзакции меняют разные строки, совместно нарушая инвариант.
- Serializable предотвращает serialization anomaly через Serializable Snapshot Isolation (SSI), но требует retry всей transaction при `serialization_failure`.

SSI использует predicate (`SIRead`) locks для обнаружения опасных зависимостей. Они не блокируют обычные операции как pessimistic locks и могут сохраняться после commit до завершения пересекающихся транзакций.

## Выбор

Read Committed подходит, если каждый statement самодостаточен или конфликты защищены constraints/atomic updates/locks. Repeatable Read удобен для согласованного многозапросного snapshot, но не гарантирует serial execution. Serializable выбирают для сложных инвариантов, когда приложение умеет безопасно повторить transaction.

```sql
BEGIN ISOLATION LEVEL SERIALIZABLE;
-- read/check/write
COMMIT;
```

Нельзя «доповторить» только последний statement после `40001`: новый запуск должен заново прочитать состояние и выполнить всю логику.

## Write skew: оба дежурных ушли

Правило: хотя бы один врач остаётся на дежурстве.

```sql
CREATE TABLE duty(name text PRIMARY KEY,on_call boolean NOT NULL);
INSERT INTO duty VALUES ('Аня',true),('Борис',true);
```

В двух соединениях начните BEGIN ISOLATION LEVEL REPEATABLE READ и выполните SELECT count(*) FROM duty WHERE on_call до обновлений.

| Шаг | A | B |
| --- | --- | --- |
| 1 | Читает 2 дежурных | Читает 2 дежурных |
| 2 | UPDATE duty SET on_call=false WHERE name='Аня' | |
| 3 | | UPDATE duty SET on_call=false WHERE name='Борис' |
| 4 | COMMIT | COMMIT |

Обе изменяли разные строки. Конфликта одной строки нет; итог — 0 дежурных.

```mermaid
flowchart LR
    A[A читает Бориса] --> B[B выключает Бориса]
    B --> C[B читает Аню]
    C --> D[A выключает Аню]
    D --> A
```

Это цикл зависимостей чтение-запись, а не ожидания блокировок. Сбросьте строки в true и повторите обе транзакции с SERIALIZABLE: одна получит 40001 при записи или commit. Повтор её целиком увидит одного дежурного, и приложение должно отказать в уходе. Таблица сценария иллюстрирует решения приложения; SQL UPDATE сам не содержит условной проверки количества.

Альтернатива — блокировать общую строку смены всеми писателями и проверять правило после захвата. FOR UPDATE только собственной строки не помогает. SSI может отменять больше случаев, чем минимально необходимо; измеряйте частоту повторов. 40001 также бывает в Repeatable Read при конфликте обновления, а 40P01 обозначает цикл ожидания блокировок. Повторяется вся транзакция, но профилактика причин различается.

## Источники

- [Transaction isolation](https://www.postgresql.org/docs/18/transaction-iso.html)
- [Serializable consistency](https://www.postgresql.org/docs/18/applevel-consistency.html)

## Проверь себя

1. **Почему Repeatable Read не спас обоих врачей?**

   <details>
   <summary>Ответ</summary>

   Каждый читает старый согласованный снимок и пишет свою строку; правило зависит от двух строк.

   </details>

2. **Почему нельзя повторить только COMMIT после 40001?**

   <details>
   <summary>Ответ</summary>

   Транзакция отменена и чтения устарели; нужно заново проверить правило.

   </details>
