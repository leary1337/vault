---
title: Уровни изоляции
description: Read Committed, Repeatable Read и Serializable именно в PostgreSQL.
tags: [databases, postgresql, transactions]
updated: 2026-09-10
---

# Уровни изоляции PostgreSQL

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

## Источники

- [Transaction isolation](https://www.postgresql.org/docs/18/transaction-iso.html)
- [Serializable consistency](https://www.postgresql.org/docs/18/applevel-consistency.html)
