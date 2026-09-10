---
title: Circuit breaker
description: Быстрый отказ при устойчивой неисправности dependency.
tags: [backend, patterns, reliability]
updated: 2026-09-10
---

# Circuit breaker

## Problem

Продолжение вызовов failing/slow dependency тратит threads, connections и deadline, вызывая cascading failure.

## Mechanism

Closed пропускает calls и считает outcomes в rolling window. При достаточном sample и превышении threshold переходит Open и fail-fast. После cooldown Half-open пропускает ограниченные probes; успех закрывает breaker, failure снова открывает.

## Guarantees

Breaker ограничивает часть бесполезных calls и ускоряет failure response. Он не восстанавливает dependency и не гарантирует снижение нагрузки, если instances независимо отправляют слишком много probes.

## Failure modes

- низкий traffic даёт шумный процент ошибок;
- один breaker смешивает разные endpoints/tenants и блокирует здоровые paths;
- slow calls не считаются failures;
- fallback возвращает опасно stale/default data;
- Open скрывает recovery из-за отсутствия корректных probes.

## Trade-offs

Threshold, window, minimum sample, slow-call duration и cooldown требуют tuning. Per-instance breaker прост и отказоустойчив, но не имеет глобального view; central breaker добавляет собственную dependency.

## When not to use

Для local deterministic validation и calls, уже защищённых строгим concurrency limit/short timeout, breaker может не дать пользы. Не ставьте его вокруг memory/CPU code path без внешнего failure mode.

## Example

Разделите breakers по dependency operation class, ограничьте half-open probes и публикуйте state transitions, rejected calls, latency и outcome reason. Сочетайте с [bulkhead](bulkhead.md), bounded retries и полезным fallback, если он действительно существует.
