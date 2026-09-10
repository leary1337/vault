---
title: Idempotency в System Design
description: Logical operation identity через API, queue и storage.
tags: [system-design, reliability]
updated: 2026-09-10
---

# Idempotency в System Design

Проследите одну logical operation через client retry, proxy retry, queue redelivery и consumer restart. На каждой границе должен сохраняться stable identity.

## Design

- Client/API idempotency key scoped by tenant + operation.
- Request fingerprint запрещает reuse key с другим payload.
- Durable state `processing/succeeded/failed` задаёт concurrent/ambiguous behavior.
- Database unique key или version transition делает mutation atomic с marker.
- Event ID не меняется при outbox/producer retry.
- Consumer inbox/business key deduplicate-ит redelivery.
- External provider получает тот же key или обрабатывается reconciliation.

Retention покрывает максимальный offline retry, broker retention/replay и restore window. Если это слишком долго, естественный business ID/state machine лучше временной dedup table.

## Review

Тестируйте crash до и после каждого durable point и потерю response. Определите response duplicate запроса в `processing`, permanent failure и payload conflict. Не храните sensitive full response без access/retention policy.

Идемпотентность не означает отсутствие concurrent conflict: две разные keys могут менять один aggregate. Нужны constraints, optimistic version или isolation. Подробнее: [idempotency pattern](../../backend-patterns/idempotency.md).
