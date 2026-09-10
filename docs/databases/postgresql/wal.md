---
title: WAL
description: Write-ahead logging, checkpoints, recovery, archiving и PITR.
tags: [databases, postgresql, wal]
updated: 2026-09-10
---

# Write-Ahead Log

WAL реализует правило write-ahead: описание изменения должно попасть в durable log раньше изменённой data page. После crash PostgreSQL replay-ит WAL от последнего checkpoint и приводит data files к согласованному состоянию.

## Commit и durability

Backend формирует WAL records в WAL buffers. При обычном synchronous commit успешный `COMMIT` означает, что commit record flush-нут на local durable storage; data pages могут быть записаны позже. Group commit объединяет flush нескольких transactions.

`synchronous_commit = off` может уменьшить latency: transaction становится видна другим, но при crash ОС возможна потеря недавних подтверждённых commits. Это ослабляет durability, а не atomicity/consistency работающего сервера. `fsync = off` и `full_page_writes = off` имеют существенно более опасные последствия и не являются обычной tuning-рекомендацией.

## Checkpoints и full-page images

Checkpoint фиксирует позицию, до которой dirty pages должны оказаться на диске, и ограничивает recovery time. Слишком частые checkpoints усиливают I/O и WAL из-за full-page images первой изменённой page после checkpoint. Слишком редкие увеличивают recovery time и storage pressure. Наблюдайте `pg_stat_checkpointer`, WAL volume и checkpoint causes.

LSN — позиция в WAL stream. Она позволяет измерять replication lag в bytes, задавать recovery target и координировать backup/restore.

## Archiving, backup и PITR

Continuous archiving сочетает base backup и непрерывный архив WAL. Для point-in-time recovery сервер восстанавливает base backup и replay-ит WAL до timestamp, transaction ID, named restore point или LSN.

Archive command должен возвращать success только после надёжного сохранения segment. Незаполняемый архив или replication slot способен удерживать WAL до исчерпания диска; мониторьте `pg_stat_archiver`, `pg_replication_slots`, `restart_lsn` и filesystem.

WAL — не замена backup: он зависит от подходящего base backup и политики retention. Регулярно проверяйте восстановление, а не только факт создания файлов.

## Источники

- [Reliability and WAL](https://www.postgresql.org/docs/18/wal.html)
- [WAL configuration](https://www.postgresql.org/docs/18/runtime-config-wal.html)
- [Continuous archiving and PITR](https://www.postgresql.org/docs/18/continuous-archiving.html)
