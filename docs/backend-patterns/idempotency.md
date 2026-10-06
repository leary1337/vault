---
title: Idempotency
description: Безопасный повтор одной logical operation.
tags: [backend, patterns, reliability]
updated: 2026-10-06
---

# Idempotency


Идемпотентность означает: повтор одного намерения не создаёт второй наблюдаемый эффект.

## Проблема

После timeout client не знает, применил ли server operation. Retry может повторно списать деньги, создать заказ или отправить event.

## Как работает

Client создаёт stable idempotency key один раз на logical operation. Server atomically связывает `(scope, key)` с request hash, status и result. Duplicate того же request получает сохранённый результат; тот же key с другим payload (полезное содержимое запроса или события) отклоняется.

## Гарантии и границы

При durable dedup record и атомарности с business mutation наблюдаемый database effect выполняется один раз в retention (срок хранения) window. Это не гарантирует exactly-once для внешних side effects без их участия.

## Ошибки и отказы

- marker commit-нулся отдельно от mutation;
- key генерируется заново на retry;
- record удалён раньше позднего retry/replay;
- concurrent request видит `processing` без recovery policy;
- response содержит секреты и доступен другому tenant из-за неверного scope.

## Компромиссы

Нужны storage, unique index, lifecycle (кто создаёт, останавливает и освобождает ресурс) и сохранение response/reference. Долгое retention увеличивает стоимость; короткое оживляет duplicates.

## Когда не применять

Для естественно idempotent (без второго эффекта при повторе одного намерения) read или operation с unique business key отдельная таблица может быть лишней. Если duplicate безопасен и дешевле coordination, достаточно at-least-once.

## Пример

```sql
INSERT INTO idempotency(scope, key, request_hash, status)
VALUES ($1, $2, $3, 'processing')
ON CONFLICT DO NOTHING;
```

Далее mutation и перевод в `succeeded` выполняются в той же transaction. Полная модель — в [distributed idempotency](../distributed-systems/idempotency.md).

## Разобранный пример

Для локального create транзакция вставляет ключ, создаёт объект и сохраняет ответ вместе. Если ключ уже существует, читаем сохранённый request hash и результат; конфликтующий INSERT может ждать другую незавершённую транзакцию. В PostgreSQL Read Committed `ON CONFLICT DO NOTHING` может ничего не вставить из-за строки, которой не было видно исходному снимку. Следующее чтение делаем отдельным statement с новым снимком; в другом уровне изоляции может понадобиться повтор транзакции.

Не сохраняем `processing` отдельным commit (фиксация результата, который считается подтверждённым) без recovery: после падения ключ навсегда занят. Для долгой внешней работы processing допустим, но с durable workflow, владельцем/lease и запросом результата. TTL (время жизни записи) ключа 24 h означает только 24-часовое окно защиты, а не вечное отсутствие дублей. [PostgreSQL 18 isolation](https://www.postgresql.org/docs/18/transaction-iso.html).

## Проверь себя

1. Почему новый key на retry ломает защиту?
2. Почему marker и объект пишут вместе?

<details>
<summary>Ориентиры для ответа</summary>

1. Сервер видит новое намерение и выполняет эффект снова.
2. Иначе падение между ними даёт дубль либо ложное подтверждение без объекта.

</details>
