---
title: MVCC
description: Версии строк, snapshots, visibility и цена долгих транзакций.
tags: [databases, postgresql, mvcc]
updated: 2026-09-10
---

# MVCC

Multi-Version Concurrency Control позволяет читателям видеть согласованный snapshot, пока другие транзакции создают новые версии строк. Поэтому обычный `SELECT` обычно не блокирует `UPDATE`, а `UPDATE` — обычный `SELECT`; исключения связаны с DDL, explicit locks и другими конфликтами.

## Версии и visibility

`UPDATE` обычно не переписывает tuple на месте: он помечает старую версию и создаёт новую. Концептуально системные поля означают:

- `xmin` — ID транзакции, создавшей версию;
- `xmax` — ID транзакции, удалившей/заменившей её либо участвующей в row locking;
- snapshot — множество границ и активных transaction IDs, по которым определяется видимость.

Одних чисел `xmin/xmax` недостаточно: сервер также учитывает состояние транзакций и hint bits. Не стройте прикладной протокол на системных колонках — их смысл содержит внутренние детали.

## Dead tuples и VACUUM

Старая версия не удаляется сразу: она может быть видна старому snapshot. Когда она больше никому не нужна, `VACUUM` освобождает место для повторного использования; autovacuum автоматизирует cleanup, freeze и `ANALYZE`. Обычный `VACUUM` обычно не возвращает место ОС, а `VACUUM FULL` переписывает таблицу и берёт `ACCESS EXCLUSIVE` lock.

Долгая или забытая `idle in transaction` транзакция удерживает старый snapshot. Результат — накопление dead tuples, index/table bloat, рост WAL и риск transaction ID wraparound. Наблюдайте `pg_stat_activity`, `pg_stat_all_tables`, возраст `relfrozenxid` и прогресс vacuum.

## HOT updates

Heap-only tuple update может не создавать новые index entries, если индексируемые столбцы не изменились и новая версия помещается на той же heap page. Это уменьшает write amplification, но зависит от свободного места (`fillfactor`) и фактической нагрузки.

## Источники

- [MVCC introduction](https://www.postgresql.org/docs/18/mvcc-intro.html)
- [Routine vacuuming](https://www.postgresql.org/docs/18/routine-vacuuming.html)
- [System columns](https://www.postgresql.org/docs/18/ddl-system-columns.html)
