---
title: Chat
description: Realtime delivery, per-conversation order, sync и presence.
tags: [system-design, cases, realtime]
updated: 2026-09-10
---

# Chat

## Requirements

1:1/group messages, realtime online delivery, offline sync, delivery/read receipts, edit/delete, attachments и push. Уточнить member count, per-conversation ordering, retention/search, multi-device и encryption.

## API/model

Client создаёт stable `client_message_id`; server возвращает `(conversation_id, sequence/message_id)`. Membership/role и message log — authoritative. Cursor sync запрашивает records после last acknowledged sequence, а не полагается только на WebSocket.

## Write path

Gateway authenticates persistent connection → chat service checks membership/idempotency → assigns order в conversation shard/partition → durable append → ack sender → fan-out event online gateways, unread projection и push service. Ack до durable append рискует потерять message.

## Ordering и sharding

Total global order не нужен; one ordered writer/partition per conversation проще. Hot giant room ограничивает partition: можно shard fan-out/read delivery, сохраняя message sequence у authority. Client reorders/buffers по sequence и умеет gap sync.

## Presence и fan-out

Presence — ephemeral lease/heartbeat и допускает staleness; не храните её как durable truth. Online connection registry маршрутизирует по user/device. Для малых groups fan-out on write; для огромных channels subscribers pull/fan-out hierarchy, иначе write amplification огромен.

## Failures

Reconnect повторяет unacked message с тем же ID. Duplicate delivery безопасна. Gateway crash восстанавливается через cursor. Push может прийти после realtime delivery; collapse/dedup — UX optimization. Edit/delete — новые versioned events, offline clients должны их применить.

## Trade-offs/security

Read receipts создают write amplification и privacy choices. End-to-end encryption меняет server search/moderation/multi-device key management. Наблюдайте connection count, send queue/backpressure, append latency, delivery gap и sync lag.
