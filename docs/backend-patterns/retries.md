---
title: Retries
description: Bounded retry transient failures в рамках deadline.
tags: [backend, patterns, reliability]
updated: 2026-09-10
---

# Retries

## Problem

Краткий network loss, leader change или overload может завершить иначе успешную operation ошибкой.

## Mechanism

Повторяйте только классифицированные transient failures, ограниченное число раз, в рамках общего deadline и retry budget. Каждый attempt имеет timeout, между attempts — [exponential backoff с jitter](exponential-backoff-and-jitter.md). Уважайте server `Retry-After`.

## Guarantees

Retry повышает вероятность успеха при transient fault. Он не гарантирует success и не определяет исход предыдущего timed-out attempt; side effect должен быть [idempotent](idempotency.md).

## Failure modes

- retry storm умножает нагрузку на уже больной dependency;
- retries нескольких layers перемножаются;
- permanent validation/auth error повторяется бесполезно;
- общий deadline исчерпан, но новый attempt стартует;
- unsafe operation создаёт duplicates.

## Trade-offs

Success rate растёт ценой tail latency и дополнительной нагрузки. Budget резервирует небольшую долю traffic/attempts на retry и прекращает их при массовом failure.

## When not to use

Не retry-те явно permanent errors, deadline exceeded без нового budget, non-idempotent side effect без key и overload, для которого server просит не повторять. Иногда fail fast/load shedding безопаснее.

## Example

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
