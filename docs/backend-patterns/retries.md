---
title: Retries
description: Bounded retry transient failures в рамках deadline.
tags: [backend, patterns, reliability]
updated: 2026-10-06
---

# Retries


Retry — повтор запроса после ошибки; клиент не всегда знает, завершилась ли первая попытка.

## Проблема

Краткий network loss, leader (узел, координирующий запись) change или overload может завершить иначе успешную operation ошибкой.

## Как работает

Повторяйте только классифицированные transient (временный, потенциально устранимый повтором) failures, ограниченное число раз, в рамках общего deadline (крайний срок завершения) и retry budget. Каждый attempt имеет timeout, между attempts — [exponential backoff с jitter](exponential-backoff-and-jitter.md). Уважайте server `Retry-After`.

## Гарантии и границы

Retry повышает вероятность успеха при transient fault. Он не гарантирует success и не определяет исход предыдущего timed-out attempt; side effect должен быть [idempotent (без второго эффекта при повторе одного намерения)](idempotency.md).

## Ошибки и отказы

- retry storm умножает нагрузку на уже больной dependency;
- retries нескольких layers перемножаются;
- permanent validation/auth error повторяется бесполезно;
- общий deadline исчерпан, но новый attempt стартует;
- unsafe operation создаёт duplicates.

## Компромиссы

Success rate растёт ценой tail latency (срок ответа) и дополнительной нагрузки. Budget резервирует небольшую долю traffic/attempts на retry и прекращает их при массовом failure.

## Когда не применять

Не retry-те явно permanent errors, deadline exceeded без нового budget, non-idempotent side effect без key и overload, для которого server просит не повторять. Иногда fail fast/load shedding безопаснее.

## Пример

```text
deadline = now + 2s
for attempt in 1..3:
    remaining = deadline - now
    if remaining <= minimum_attempt_time: fail
    result = call(timeout=min(500ms, remaining))
    if success or permanent_error: return result
    wait(full_jitter_backoff(attempt), bounded_by=remaining)
```

Логируйте final outcome один раз, attempts — как structured fields/metrics, чтобы не создавать log storm.

## Разобранный пример

Бюджет запроса 800 ms: оставляем 50 ms на ответ, первая попытка максимум 300 ms, ожидание до 100 ms, второй вызов не больше остатка. Это пример, а не рекомендованный timeout для всех сервисов. Retry выполняется в одном слое: три попытки в API, SDK и proxy могут дать 27 downstream вызовов.

Если БД вернула serialization failure, повторяем всю отменённую транзакцию с новым снимком. Если commit (фиксация результата, который считается подтверждённым) ответил сетевым timeout, результат может быть уже сохранён: повтор после произвольной ошибки без business key опасен. Не считаем каждую 500 безопасной для повторения записи; API должен документировать поведение и стабильный key.

## Источник механизма

[Google SRE: retry amplification](https://sre.google/sre-book/addressing-cascading-failures/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Означает ли timeout отсутствие эффекта?
2. Почему retry должен иметь одного владельца?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, ответ мог потеряться после commit.
2. Чтобы вложенные уровни не умножали нагрузку.

</details>
