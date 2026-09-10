---
title: Exponential backoff и jitter
description: Разведение повторных попыток после массового сбоя.
tags: [backend, patterns, reliability]
updated: 2026-09-10
---

# Exponential backoff и jitter

## Problem

Если тысячи clients повторяют запрос через одинаковый интервал, они снова приходят одной волной и не дают dependency восстановиться.

## Mechanism

Exponential cap увеличивает окно ожидания:

```text
cap_n = min(max_delay, base * 2^n)
full_jitter_delay = random(0, cap_n)
```

Full jitter хорошо рассеивает arrivals. Equal/decorrelated jitter дают другие latency/load trade-offs. Ограничьте attempts, elapsed time и общий deadline; `Retry-After` server имеет приоритет в допустимых пределах.

## Guarantees

Jitter уменьшает синхронизацию retries и peak amplification. Он не ограничивает общее число retries и не защищает dependency без budgets/concurrency limits.

## Failure modes

- overflow exponent или delay больше deadline;
- deterministic seed у всех instances повторно синхронизирует waits;
- cap слишком мал относительно recovery time;
- бесконечные retries удерживают backlog;
- server recovery получает слишком мало probe traffic при чрезмерном backoff.

## Trade-offs

Большое окно снижает load, но увеличивает recovery latency. Base/cap должны соответствовать call latency и outage profile; случайность усложняет тесты, поэтому injectable RNG/clock полезны.

## When not to use

Для user-facing request с коротким deadline иногда нет времени даже на второй attempt. Для local optimistic conflict маленький randomized retry может быть уместнее exponential seconds.

## Example

При base 100 ms и cap 2 s full-jitter windows: `[0,100)`, `[0,200)`, `[0,400)`, `[0,800)`... Отдельно ограничьте retry traffic, например не более 10% normal request rate.

## Источники

- [AWS Architecture Blog: Exponential Backoff and Jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
