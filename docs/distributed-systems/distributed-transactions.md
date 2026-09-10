---
title: Распределённые транзакции
description: 2PC, coordinator failure, saga и transactional messaging.
tags: [distributed-systems, transactions]
updated: 2026-09-10
---

# Распределённые транзакции

Distributed transaction пытается атомарно изменить несколько independent resource managers. Сначала спросите, можно ли colocate invariant, сделать один authoritative write и распространить события асинхронно.

## Two-phase commit

1. Prepare: coordinator просит participants подготовить transaction; каждый durable записывает решение «готов» и удерживает locks/resources.
2. Commit/abort: после всех yes coordinator durable фиксирует global decision и рассылает его.

2PC даёт atomic commit при assumptions protocol, но не является consensus. Если participant prepared и потерял coordinator/decision, он может блокироваться, пока решение не восстановлено. Coordinator log, participant recovery, heuristic outcomes и timeouts требуют operational plan.

XA/2PC подходит, когда все resources поддерживают protocol, locks короткие, latency/failure domains приемлемы и atomicity важнее availability. Он плохо сочетается с произвольными HTTP services и долгими business workflows.

## Saga

Saga — последовательность local transactions с compensating actions при failure. Orchestration хранит workflow state централизованно; choreography связывает services events и уменьшает центральную логику, но усложняет tracing/evolution.

Compensation не rollback: отправленный email не «отправить назад», refund не отменяет факт charge, а concurrent observers уже видели промежуточное состояние. Steps должны быть idempotent, state machine — durable, retry/timeout/manual resolution — явными.

## Messaging boundary

[Transactional Outbox](../messaging/transactional-outbox.md) атомарно сохраняет business change и intent-to-publish в одной БД. [Inbox](../messaging/inbox-pattern.md) deduplicate-ит consumer effect. Это даёт reliable eventual workflow, но не мгновенную global isolation.

Выбирайте по invariant, допустимому промежуточному состоянию, blocking time, availability, audit и recovery, а не по названию pattern.

## Источники

- [Gray and Lamport: Consensus on Transaction Commit](https://www.microsoft.com/en-us/research/publication/consensus-on-transaction-commit/)
- [Saga paper](https://www.cs.cornell.edu/andru/cs711/2002fa/reading/sagas.pdf)
