---
title: API design
description: Contracts, errors, idempotency, pagination и evolution.
tags: [system-design, api]
updated: 2026-09-10
---

# API design

API — долгоживущий contract между failure domains. Он должен выражать resource/state transition, concurrency и retry semantics, а не отражать внутренние tables.

## Contract

- stable identifiers и tenant scope;
- schema с required/optional fields и validation limits;
- explicit error model: retryable, permanent, conflict, rate limited;
- deadline/cancellation propagation;
- authorization на object/action, а не только endpoint;
- pagination с deterministic order и cursor;
- compatibility policy и deprecation window.

Для create/side-effect command примите idempotency key. Для optimistic update используйте version/ETag и conditional write. `202 Accepted` означает принятие asynchronous job, а не завершение; верните operation ID/status endpoint.

Offset pagination проста, но нестабильна при изменениях и дорога на больших offsets. Keyset cursor кодирует sort key + unique tie-breaker и filter/version context.

## Evolution

Добавление optional field обычно совместимо, изменение смысла/типа — нет. Consumers должны игнорировать неизвестные fields, но producers не должны переиспользовать удалённое поле с новым смыслом. В event API schema evolution и retention старых событий требуют отдельной проверки.

## Failure questions

- Может ли server завершить operation после client timeout?
- Как client узнаёт status ambiguous request?
- Что произойдёт при duplicate/out-of-order call?
- Где ограничены body, fan-out и expensive filters?
- Что логируется без утечки secrets/PII?
