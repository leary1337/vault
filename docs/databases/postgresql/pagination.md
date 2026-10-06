---
title: Пагинация
description: OFFSET/LIMIT, keyset pagination и консистентный порядок.
tags: [databases, postgresql, api]
updated: 2026-10-06
---

# Пагинация

Пагинация делит строки на порции. Порядок должен однозначно задавать место каждой строки; к дате обычно добавляют уникальный id.

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

Keyset не даёт дешёвого произвольного номера страницы и сохраняет relative traversal, а не immutable snapshot. Если нужен строго неизменный export, используйте отдельный snapshot/job; верхняя граница сама по себе не фиксирует изменения старых строк; не держите web transaction открытой между запросами пользователя.

## Total count

Точный `COUNT(*)` на большом изменяемом наборе может быть дорогим и необязательно соответствует следующей странице при Read Committed. Рассмотрите отсутствие total, приблизительную оценку или заранее поддерживаемый counter — в зависимости от product semantics.

## Курсор при одинаковых датах

```sql
CREATE TABLE page_posts(id integer PRIMARY KEY,created_at timestamptz NOT NULL);
INSERT INTO page_posts VALUES
(1,'2026-10-01 UTC'),(2,'2026-10-01 UTC'),(3,'2026-10-02 UTC');
SELECT * FROM page_posts ORDER BY created_at DESC,id DESC LIMIT 2;
-- ids: 3,2; курсор ('2026-10-01 UTC',2)
SELECT * FROM page_posts
WHERE (created_at,id)<(timestamptz '2026-10-01 UTC',2)
ORDER BY created_at DESC,id DESC LIMIT 2;
-- id: 1
```

Новая запись выше курсора не сдвинет следующую порцию как OFFSET. Но изменение даты старой записи может перенести её через курсор: keyset не равен снимку. Верхняя граница исключает новые более высокие ключи, но не фиксирует изменения/удаления старых строк. Строгий export требует ограниченного по времени snapshot или материализации состава данных.

Для score DESC,id ASC сравнение пары через < неверно: используйте score<last_score OR (score=last_score AND id>last_id). При NULL определите порядок и условия отдельно. Курсор привяжите к фильтрам; проверка доступа выполняется на каждой странице.

## Источники

- [LIMIT and OFFSET](https://www.postgresql.org/docs/18/queries-limit.html)
- [Row constructor comparison](https://www.postgresql.org/docs/18/functions-comparisons.html)

## Проверь себя

1. **Почему одной даты недостаточно?**

   <details>
   <summary>Ответ</summary>

   При совпадении дат порядок недетерминирован без tie-breaker.

   </details>

2. **Достаточна ли верхняя граница для immutable export?**

   <details>
   <summary>Ответ</summary>

   Нет, она не предотвращает изменения и удаления старых строк.

   </details>
