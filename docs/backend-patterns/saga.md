---
title: Saga
description: Long-running workflow из local transactions и compensations.
tags: [backend, patterns, transactions]
updated: 2026-09-10
---

# Saga

## Problem

Business workflow изменяет несколько services/resources, которые нельзя включить в одну короткую ACID transaction.

## Mechanism

Saga хранит durable state machine из local transactions. После failure выполняются compensating actions для уже завершённых steps. Orchestration явно командует steps; choreography реагирует на events без центрального coordinator.

## Guarantees

При durable workflow, idempotent steps и бесконечном/операторском recovery saga со временем приходит в terminal business state. Она не даёт global isolation и не скрывает intermediate states.

## Failure modes

- crash между side effect и записью step state;
- duplicate/out-of-order command/event;
- compensation сама падает или становится невозможной;
- concurrent saga меняет тот же aggregate;
- choreography образует невидимый cycle;
- бесконечный retry блокирует business/manual resolution.

## Trade-offs

Orchestrator улучшает observability/control, но централизует workflow coupling. Choreography сохраняет autonomy, но усложняет понимание, versioning и end-to-end tracing. Compensation — новая business logic, которую нужно тестировать.

## When not to use

Если invariant можно держать в одной database transaction, saga избыточна. Если промежуточное состояние никогда нельзя показывать, нужен другой boundary/atomic protocol.

## Example

Order saga: reserve inventory → authorize payment → confirm order. При failure payment: release inventory. При failure после charge: refund — это новое действие, не стирающее audit факта оплаты. Каждый step имеет stable command ID, timeout и manual state.

Подробнее: [distributed transactions](../distributed-systems/distributed-transactions.md).
