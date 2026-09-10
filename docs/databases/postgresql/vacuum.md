---
title: VACUUM и autovacuum
description: Cleanup, freeze, statistics, bloat и диагностика autovacuum.
tags: [databases, postgresql, operations]
updated: 2026-09-10
---

# VACUUM и autovacuum

Из-за [MVCC](mvcc.md) `UPDATE` и `DELETE` оставляют старые tuple versions. Обычный `VACUUM` помечает место пригодным для reuse, обновляет visibility map и замораживает старые transaction IDs. Он обычно работает параллельно с DML и не уменьшает файл до ОС.

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

## Источники

- [Routine vacuuming](https://www.postgresql.org/docs/18/routine-vacuuming.html)
- [VACUUM](https://www.postgresql.org/docs/18/sql-vacuum.html)
- [Autovacuum settings](https://www.postgresql.org/docs/18/runtime-config-vacuum.html)
