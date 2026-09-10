---
title: Rate limiting в System Design
description: Scope, algorithm, placement и distributed state.
tags: [system-design, reliability]
updated: 2026-09-10
---

# Rate limiting в System Design

Сначала определите цель: abuse prevention, fair use, cost control или защита capacity. Один limiter редко решает все четыре.

## Scope и placement

Limit key может включать tenant, user, token, IP, endpoint и weighted cost. Edge limiter отсекает раньше, service limiter знает business cost, dependency limiter защищает downstream. Нужны global и per-tenant layers, чтобы множество малых clients не превысило total capacity.

Token bucket допускает controlled burst; sliding window точнее у границ; concurrency limiter лучше отражает дорогие длительные requests. Local state быстро, но effective global limit умножается на replicas; central atomic store точнее и добавляет dependency/latency. Token leasing даёт bounded overshoot.

## Contract

Верните `429`, machine-readable reason, limit/reset metadata и `Retry-After`, не раскрывая sensitive quotas. Решите fail-open/fail-closed при store outage. TTL/cardinality limiter keys ограничивают memory.

Load test включает synchronized burst, clock skew, hot tenant, failover limiter store и client retries. Наблюдайте allowed/rejected по scope, store latency/errors и downstream saturation. Подробнее: [rate-limiting pattern](../../backend-patterns/rate-limiting.md).
