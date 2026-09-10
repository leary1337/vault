---
title: Пагинация
description: OFFSET/LIMIT, keyset pagination и консистентный порядок.
tags: [databases, postgresql, api]
updated: 2026-09-10
---

# Пагинация

Пагинация обязана иметь полный детерминированный порядок. `ORDER BY created_at` недостаточен при одинаковом времени; добавьте unique tie-breaker.

## OFFSET/LIMIT

```sql
SELECT id, created_at, title
FROM posts
ORDER BY created_at DESC, id DESC
LIMIT 50 OFFSET 5000;
```

Это просто и позволяет перейти к номеру страницы, но сервер всё равно должен найти/пропустить предыдущие rows. Большой offset растёт по стоимости, а concurrent inserts/deletes сдвигают границы: клиент может увидеть дубликаты или пропуски.

## Keyset pagination

```sql
SELECT id, created_at, title
FROM posts
WHERE (created_at, id) < ($1, $2)
ORDER BY created_at DESC, id DESC
LIMIT 50;
```

Подходящий индекс:

```sql
CREATE INDEX posts_feed_idx ON posts (created_at DESC, id DESC);
```

Cursor кодирует последнее `(created_at, id)`, направление и при необходимости версию filters; подпишите/проверьте его, если клиент не должен менять значения. Для nullable/mixed-direction keys явно определите comparison semantics — row constructor не всегда достаточно прозрачен.

Keyset не даёт дешёвого произвольного номера страницы и сохраняет relative traversal, а не immutable snapshot. Если нужен строго неизменный export, используйте отдельный snapshot/job или зафиксированную верхнюю границу; не держите web transaction открытой между запросами пользователя.

## Total count

Точный `COUNT(*)` на большом изменяемом наборе может быть дорогим и необязательно соответствует следующей странице при Read Committed. Рассмотрите отсутствие total, приблизительную оценку или заранее поддерживаемый counter — в зависимости от product semantics.

## Источники

- [LIMIT and OFFSET](https://www.postgresql.org/docs/18/queries-limit.html)
- [Row constructor comparison](https://www.postgresql.org/docs/18/functions-comparisons.html)
