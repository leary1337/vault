---
title: Exponential backoff и jitter
description: Разведение повторных попыток после массового сбоя.
tags: [backend, patterns, reliability]
updated: 2026-10-06
---

# Exponential backoff и jitter


Backoff увеличивает паузу между повторами, jitter случайно раздвигает попытки разных клиентов.

## Проблема

Если тысячи clients повторяют запрос через одинаковый интервал, они снова приходят одной волной и не дают dependency восстановиться.

## Как работает

Exponential cap увеличивает окно ожидания:

```text
cap_n = min(max_delay, base * 2^n)
full_jitter_delay = random(0, cap_n)
```

Full jitter хорошо рассеивает arrivals. Equal/decorrelated jitter дают другие latency/load trade-offs. Ограничьте attempts, elapsed time и общий deadline (крайний срок завершения); `Retry-After` server имеет приоритет в допустимых пределах.

## Гарантии и границы

Jitter уменьшает синхронизацию retries и peak amplification. Он не ограничивает общее число retries и не защищает dependency без budgets/concurrency limits.

## Ошибки и отказы

- overflow exponent или delay больше deadline;
- deterministic seed у всех instances повторно синхронизирует waits;
- cap слишком мал относительно recovery time;
- бесконечные retries удерживают backlog (накопившаяся необработанная работа);
- server recovery получает слишком мало probe traffic при чрезмерном backoff.

## Компромиссы

Большое окно снижает load, но увеличивает recovery latency (срок ответа). Base/cap должны соответствовать call latency и outage profile; случайность усложняет тесты, поэтому injectable RNG/clock полезны.

## Когда не применять

Для user-facing request с коротким deadline иногда нет времени даже на второй attempt. Для local optimistic conflict маленький randomized retry может быть уместнее exponential seconds.

## Пример

При base 100 ms и cap 2 s full-jitter windows: `[0,100)`, `[0,200)`, `[0,400)`, `[0,800)`... Отдельно ограничьте retry traffic, например не более 10% normal request rate.

## Источники

- [AWS Architecture Blog: Exponential Backoff and Jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)

## Разобранный пример

При 1 000 клиентов и паузе ровно 1 s получаем волну 1 000 запросов. С равномерным разбросом по секунде средняя интенсивность та же 1 000/с, но без общей точки старта. Jitter не уменьшает число повторов: нужен отдельный budget. Если осталось 150 ms, ожидание 100 ms и попытка 200 ms не укладываются в deadline; сначала пересчитываем остаток.

Предел exponent достигаем насыщением до умножения, чтобы не переполнить число. Для тестов передаём генератор случайных чисел и часы; проверяем диапазон пауз, отмену во время ожидания и отсутствие нового вызова после срока.

## Проверь себя

1. Ограничивает ли jitter число повторов?
2. Когда не начинать следующую попытку?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, он распределяет время; attempts и retry budget ограничивают число.
2. Если оставшегося срока недостаточно для минимальной полезной попытки и ответа.

</details>
