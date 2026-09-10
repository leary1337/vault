---
title: Bulkhead
description: Изоляция ресурсов между workloads и dependencies.
tags: [backend, patterns, reliability]
updated: 2026-09-10
---

# Bulkhead

## Problem

Один медленный dependency, tenant или request class занимает все workers/connections и делает недоступными независимые функции.

## Mechanism

Разделите bounded resource pools и queues: отдельные HTTP/DB connection pools, semaphores, worker pools или quotas для critical/background traffic. Резервируйте capacity для health/admin/recovery paths.

## Guarantees

При корректных границах exhaustion одного compartment не забирает выделенные ресурсы другого. Pattern не гарантирует успех повреждённого compartment и не устраняет общие bottlenecks CPU/memory/network.

## Failure modes

- слишком крупный pool всё равно истощает общий resource;
- слишком мелкий простаивает и режет throughput;
- request держит ресурс одного pool, ожидая другой — cross-pool deadlock;
- high-priority traffic starves background навсегда;
- число application instances умножает database pool limit.

## Trade-offs

Изоляция снижает эффективность общего pooling и усложняет capacity planning. Нужны отдельные metrics saturation/queue/rejections по compartment и контролируемое перераспределение spare capacity.

## When not to use

Если workloads действительно имеют общий fate/resource и одинаковый priority, один простой bounded pool лучше множества искусственных partitions.

## Example

API получает 80 DB slots, batch jobs — 15, admin/recovery — 5. Каждый limit согласован с total connections всех replicas; при saturation batch получает backpressure, а не занимает API slots.
