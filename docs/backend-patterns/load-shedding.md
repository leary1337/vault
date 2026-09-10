---
title: Load shedding
description: Ранний отказ от работы, которую система не успеет выполнить.
tags: [backend, patterns, reliability]
updated: 2026-09-10
---

# Load shedding

## Problem

Когда arrival rate выше service rate, очередь растёт, latency превышает deadlines, retries добавляют load и система падает каскадом.

## Mechanism

Отклоняйте лишнюю работу как можно раньше по bounded concurrency/queue, deadline feasibility, priority и текущей saturation. Adaptive concurrency меняет limit по latency/queue feedback. Requests с уже истёкшим deadline не должны занимать downstream.

## Guarantees

Shedding сохраняет ресурсы для принятой/приоритетной работы и ограничивает queueing latency. Он явно снижает success rate; правильный результат — controlled partial availability, а не отсутствие ошибок.

## Failure modes

- слишком поздний reject после дорогого parse/auth/DB call;
- все replicas решают одинаково и oscillate;
- health/readiness probes shed-ятся и вызывают restart storm;
- приоритет starvation-ит low class;
- clients немедленно retry-ят и возвращают load;
- stale saturation signal режет здоровый traffic.

## Trade-offs

Нужно выбрать admission signal и fairness. Короткая queue поглощает microburst, длинная скрывает overload. Local decision быстрый, но не знает global capacity.

## When not to use

Работу, которую нельзя потерять, принимайте только после durable enqueue с bounded producer backpressure; silent drop недопустим. Shedding не заменяет capacity и устранение bottleneck.

## Example

API при заполнении 100 concurrent slots не ставит request в бесконечную очередь, а быстро возвращает `503` с bounded retry hint. Critical checkout получает reserved bulkhead, analytics shed-ится первой.
