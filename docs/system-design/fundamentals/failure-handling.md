---
title: Failure handling
description: Failure matrix, timeouts, degraded modes и recovery.
tags: [system-design, reliability]
updated: 2026-09-10
---

# Failure handling

Design считается неполным, пока не описано поведение при частичном отказе. «Retry и fallback» без boundaries создаёт каскад.

## Failure matrix

Для каждого critical dependency/zone/control plane рассмотрите:

| Failure | Detect | Immediate behavior | Data risk | Recovery |
| --- | --- | --- | --- | --- |
| timeout/slow | deadline, latency | retry/fail/shed | unknown outcome | status/idempotency |
| process/node loss | health + quorum | reroute/failover | in-flight/ack tail | restart/replay |
| network partition | quorum/lag | reject или stale mode | divergence | fence/repair |
| overload | queue/saturation | backpressure/shed | dropped/expired work | drain/scale |
| corruption/operator error | checks/audit | stop writes/isolate | incorrect replicated data | restore/reconcile |

Timeout ограничивает ожидание, cancellation best-effort. Retry только при idempotency и budget. Circuit breaker, bulkhead и load shedding защищают capacity, но должны иметь понятный user outcome.

## Recovery

Определите RPO/RTO, source of truth, backup/restore, replay order, fencing и reconciliation query. Failover без failback/rejoin procedure накапливает риск. Runbook содержит безопасные команды, preconditions и rollback.

Chaos test начинается с hypotheses и observability: kill, pause, one-way partition, disk full, stale DNS, expired cert и dependency latency. Не тестируйте разрушительно без isolation. Подробнее: [failure models](../../distributed-systems/failure-models.md).
