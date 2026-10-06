---
title: Database testing
description: Проверка SQL, migrations, transactions и connection lifecycle.
tags:
  - go
  - testing
  - databases
updated: 2026-10-06
---

# Database testing

Тест с настоящей БД проверяет то, чего нет у map-fake: SQL, constraints, блокировки и commit. Его данные должны быть изолированы от других тестов.

Repository unit tests с fake проверяют domain flow; реальная PostgreSQL instance нужна для SQL syntax, constraints, types, locks, isolation, query plans и migration compatibility.

## Стратегия

1. Запустить pinned PostgreSQL version.
2. Применить production migrations с нуля.
3. Создать isolated database/schema для test.
4. Выполнить arrange/act/assert через тот же driver/config path.
5. Очистить state независимо от результата.

Rollback каждой test transaction быстрый, но не проверяет commit-time behavior и плохо моделирует code, которое открывает собственные connections/transactions. Truncate/schema recreation надёжнее, но дороже. Выбирайте по semantics.

`sql.DB` — pool, а не одна connection. Ограничьте pool в tests, закрывайте rows, проверяйте context cancellation и отслеживайте `DB.Stats`, чтобы находить leaks/exhaustion.

## Проверить не только успешную запись

Пример сценария для таблицы с `UNIQUE(idempotency_key)`:

```sql
INSERT INTO orders (idempotency_key, amount_minor) VALUES ('test-42', 100);
INSERT INTO orders (idempotency_key, amount_minor) VALUES ('test-42', 100);
-- вторая запись нарушает UNIQUE: сервис должен вернуть прежний результат
```

Для конкурентного теста нужны два независимых соединения/transactions и barrier, который запускает действия в нужном порядке. После ошибки PostgreSQL transaction может требовать rollback; «продолжим следующую команду» не всегда допустимо.

В Go цикл rows должен закрывать `Rows` и проверять `rows.Err()` после итерации. `db.SetMaxOpenConns(1)` может выявить утечку, но также блокирует второй запрос, пока первый Rows открыт. Используйте этот режим осознанно, а не как универсальную настройку integration suite.

## Источники

- [Go database documentation](https://go.dev/doc/database/)
- [Managing database connections](https://go.dev/doc/database/manage-connections)

## Проверь себя

1. Почему rollback одного test не проверяет commit constraints?
2. Зачем rows.Err после цикла?

<details>
<summary>Ориентиры для ответа</summary>

1. Некоторые ограничения/эффекты возникают на commit, который тест не выполняет.
2. Ошибка чтения может появиться после нескольких успешных rows и завершить iteration.

</details>
