---
title: Transactional Outbox
description: Atomic business change и intent to publish.
tags: [backend, patterns, messaging]
updated: 2026-09-10
---

# Transactional Outbox

## Problem

Database commit и message publish — dual write: crash между ними даёт потерянное событие или событие о rollback-нутом состоянии.

## Mechanism

Business row и outbox event вставляются в одной local transaction. Relay публикует rows через polling или CDC, затем продвигает durable position/mark. Event ID создаётся до transaction и остаётся тем же при retry.

## Guarantees

Committed change имеет committed intent-to-publish; rollback не оставляет event. Relay обычно доставляет at least once, поэтому duplicate остаётся частью контракта.

## Failure modes

- publish успешен, mark/offset потерян — duplicate;
- relay lag превышает SLO/retention;
- outbox table/replication slot растёт до disk exhaustion;
- несколько relays нарушают per-aggregate order;
- schema event не совместима с consumers;
- cleanup удаляет данные до replay/recovery.

## Trade-offs

Polling проще и database-heavy; CDC уменьшает queries, но добавляет connector/log operations. Outbox увеличивает write/storage и требует ownership, cleanup, lag alerts и reconciliation.

## When not to use

Kafka-to-Kafka pipeline может использовать Kafka transaction. Если событие best-effort и loss восполняется регулярной reconciliation, полный outbox может не окупиться.

## Example

В PostgreSQL transaction обновите order и вставьте `(event_id, aggregate_id, type, payload)`. Relay публикует с key=`aggregate_id`; consumer использует Inbox unique key. Подробная реализация: [Messaging / Transactional Outbox](../messaging/transactional-outbox.md).
