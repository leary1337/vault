---
title: Database testing
description: Проверка SQL, migrations, transactions и connection lifecycle.
tags:
  - go
  - testing
  - databases
updated: 2026-09-10
---

# Database testing

Repository unit tests с fake проверяют domain flow; реальная PostgreSQL instance нужна для SQL syntax, constraints, types, locks, isolation, query plans и migration compatibility.

## Стратегия

1. Запустить pinned PostgreSQL version.
2. Применить production migrations с нуля.
3. Создать isolated database/schema для test.
4. Выполнить arrange/act/assert через тот же driver/config path.
5. Очистить state независимо от результата.

Rollback каждой test transaction быстрый, но не проверяет commit-time behavior и плохо моделирует code, которое открывает собственные connections/transactions. Truncate/schema recreation надёжнее, но дороже. Выбирайте по semantics.

`sql.DB` — pool, а не одна connection. Ограничьте pool в tests, закрывайте rows, проверяйте context cancellation и отслеживайте `DB.Stats`, чтобы находить leaks/exhaustion.

## Источники

- [Go database documentation](https://go.dev/doc/database/)
- [Managing database connections](https://go.dev/doc/database/manage-connections)
