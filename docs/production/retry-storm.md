---
title: Retry storm
description: Диагностика retry amplification, timeout budgets и cascading failure.
tags: [production, retries, resilience]
updated: 2026-09-10
---

# Retry storm

## Symptoms

Downstream requests значительно превышают user traffic, errors/latency и resource saturation растут после первоначальной деградации; recovery откладывается даже после устранения trigger.

## Possible causes

Retries на нескольких слоях, no backoff/jitter, одинаковые deadlines, retry non-idempotent/permanent errors, timeout короче реальной latency, queueing без budget, reconnect loop или autoscaling feedback.

## What to measure

Logical operations vs attempts, attempts per request по layer/reason, retry success, timeout budget, downstream QPS/saturation, queue age и unique idempotency keys.

## Diagnostics

Постройте amplification tree по trace/metrics: client → gateway → service → SDK. Найдите первый failure и каждый retry owner. Проверьте classification, cap, backoff/jitter и remaining deadline. Сравните user success, а не только долю успешных retry.

## Tools

Attempt-labeled bounded metrics, distributed traces/events, client/server logs, rate-limit/circuit-breaker state и dependency dashboards.

## Immediate mitigation

Отключить/ограничить retries на верхнем слое, shed/rate-limit, circuit break, увеличить backoff с jitter, вернуть fast failure или снять traffic с dependency. Не увеличивайте все timeouts: это удержит resources дольше.

## Root cause

Укажите transient trigger и control loop, который умножил load: сколько слоёв × attempts и почему budget/admission не ограничили cascade. Отделите исходный fault от amplifier.

## Prevention

Один явный retry owner, capped exponential backoff + jitter, retry budget, deadline propagation, error classification, idempotency, circuit/load shedding и fault-injection tests. См. [retries](../backend-patterns/retries.md).

