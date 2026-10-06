---
title: Retries в System Design
description: Placement, budgets, idempotency и deadline allocation.
tags: [system-design, reliability]
updated: 2026-10-06
---

# Retries в System Design

Повтор помогает при кратком сбое, но добавляет нагрузку и может повторить уже выполненный эффект.

Retry — дополнительная нагрузка и latency (срок ответа), поэтому его placement входит в architecture. Три attempts на каждом из трёх вложенных layers могут породить до 27 downstream attempts.

## Политика

- retry только transient/retriable outcome;
- одна logical operation сохраняет idempotency key;
- один ответственный layer, остальные возвращают классифицированную ошибку;
- per-attempt timeout укладывается в propagated overall deadline (крайний срок завершения);
- exponential backoff + jitter + `Retry-After`;
- max attempts/elapsed time и global retry budget;
- circuit breaker/load shedding при массовом failure.

Hedged request снижает tail чтения, отправляя дополнительный attempt после percentile delay, но умножает load и требует cancel loser; не применяйте к unsafe writes.

## Ambiguous outcome

Timeout означает «client перестал ждать», не «server отменил». Для create/payment нужны idempotency/status lookup. Для DB serialization/deadlock повторяют всю transaction после rollback (отмена локальной транзакции или возврат старой версии), а не один последний statement.

Наблюдайте attempts per logical request, recovered success, added latency/load и final errors. Chaos/load test должен доказать, что retry policy помогает при небольшом fault и выключается при outage. Подробнее: [retries pattern](../../backend-patterns/retries.md).

## На конкретном примере

100 requests/s с тремя попытками могут стать 300 downstream calls/s. При трёх вложенных слоях по три — до 2 700. Retry budget 10% normal traffic ограничивает дополнительные попытки, но требует явно определить, что считаем normal и за какое окно.

Hedge чтения отправляем после задержки только для дешёвого повторяемого запроса, учитывая budget. Отмена проигравшего не доказывает, что сервер немедленно прекратил I/O. Записи с внешним эффектом нельзя hedge без строгой защиты одного намерения.

## Источник механизма

[Google SRE: каскадные отказы](https://sre.google/sre-book/addressing-cascading-failures/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Когда повторять DB transaction?
2. Почему timeout опасен для записи?

<details>
<summary>Ориентиры для ответа</summary>

1. После rollback для известных retryable conflicts, целиком с новым снимком.
2. Результат неизвестен, а повтор без ID может создать второй эффект.

</details>
