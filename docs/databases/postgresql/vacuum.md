---
title: VACUUM и autovacuum
description: Cleanup, freeze, statistics, bloat и диагностика autovacuum.
tags: [databases, postgresql, operations]
updated: 2026-10-06
---

# VACUUM и autovacuum

VACUUM убирает версии, больше не нужные читателям, и предотвращает переполнение идентификаторов транзакций. ANALYZE собирает статистику для планов; это другая задача.

Из-за [MVCC](mvcc.md) `UPDATE` и `DELETE` оставляют старые версии строк. Обычный `VACUUM` помечает место пригодным для reuse, обновляет visibility map и замораживает старые идентификаторы транзакций. Он обычно работает параллельно с DML и не уменьшает файл до ОС.

`VACUUM FULL` переписывает relation в новый файл, возвращает свободное место ОС и требует дополнительный disk space и `ACCESS EXCLUSIVE` lock. Это аварийный/плановый rewrite, а не регулярная замена autovacuum.

## Три разные задачи

- cleanup dead tuples и index entries;
- freeze для предотвращения XID/multixact wraparound;
- `ANALYZE` для planner statistics.

`VACUUM` без `ANALYZE` не обновляет обычные planner statistics. Autovacuum принимает решения отдельно для vacuum и analyze по thresholds плюс доле изменённых tuples; большие таблицы часто требуют per-table настройки.

## Что мешает cleanup

- long-running или `idle in transaction` sessions;
- abandoned prepared transactions;
- replication slots/standbys, удерживающие горизонт;
- слишком медленный autovacuum при высоком churn;
- tables с настройками autovacuum, не соответствующими workload.

Даже если dead tuples ещё нужны старому snapshot, freeze work для других tuples может продолжаться, но space reclamation будет ограничена.

## Наблюдение

Смотрите:

- `pg_stat_user_tables`: live/dead estimates, время/count vacuum/analyze;
- `pg_stat_progress_vacuum`: текущие фазы;
- `pg_stat_activity.backend_xmin` и возраст transactions;
- `age(datfrozenxid)`/`age(relfrozenxid)` для wraparound risk;
- logs autovacuum и actual relation/index size.

`n_dead_tup` — estimate, не точный счётчик. Не выключайте autovacuum глобально: anti-wraparound vacuum всё равно критичен, а ручное обслуживание легко пропустить.

## Диагностика роста

```sql
SELECT relname,n_live_tup,n_dead_tup,last_autovacuum,last_autoanalyze
FROM pg_stat_user_tables ORDER BY n_dead_tup DESC LIMIT 10;
SELECT pid,now()-xact_start AS transaction_age,backend_xmin,state
FROM pg_stat_activity WHERE xact_start IS NOT NULL ORDER BY xact_start;
SELECT datname,age(datfrozenxid) FROM pg_database;
```

Live/dead — оценки. Сравнивайте размер, churn и журнал обслуживания. Если старая транзакция удерживает версии, более частый VACUUM их не удалит: выясните причину горизонта, включая logical slots и prepared transactions.

```mermaid
flowchart LR
    Update[UPDATE создаёт версию] --> Dead[Старая версия остаётся]
    Dead --> Needed{Нужна снимку?}
    Needed -->|Да| Keep[Сохранить]
    Needed -->|Нет| Reuse[VACUUM: место для reuse]
```

Обычный VACUUM может обрезать свободные страницы в конце файла, но не уплотняет все пустоты посередине. VACUUM FULL требует rewrite, свободное место и эксклюзивный lock. Для большой часто меняемой таблицы per-table thresholds выбирайте по churn и I/O; PostgreSQL 18 также имеет максимальный vacuum threshold и insert-driven triggers. Отсутствие dead tuples не отменяет freeze.

## Источники

- [Routine vacuuming](https://www.postgresql.org/docs/18/routine-vacuuming.html)
- [VACUUM](https://www.postgresql.org/docs/18/sql-vacuum.html)
- [Autovacuum settings](https://www.postgresql.org/docs/18/runtime-config-vacuum.html)

## Проверь себя

1. **Заменяет ли VACUUM ANALYZE?**

   <details>
   <summary>Ответ</summary>

   Нет: очистка и статистика различаются; можно выполнить обе задачи.

   </details>

2. **Почему VACUUM не уменьшил файл в десять раз?**

   <details>
   <summary>Ответ</summary>

   Обычно освобождает место внутри relation; полная перестройка имеет другую стоимость.

   </details>
