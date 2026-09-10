---
title: Notification service
description: Preferences, fan-out, providers, retries и delivery status.
tags: [system-design, cases, messaging]
updated: 2026-09-10
---

# Notification service

## Requirements

Принять logical notification, применить preferences/consent, выбрать email/SMS/push/in-app, render template, доставить и показать status. Уточнить urgency, scheduling, dedup, quiet hours, unsubscribe, provider callback и regulatory audit.

## API и model

`POST /notifications` принимает idempotency key, recipient, template version, variables, channels и schedule. Source of truth хранит notification state machine и per-channel attempt; preference/version фиксируется по выбранной business semantics.

## Write path

API валидирует/authorizes → transaction создаёт notification + outbox → broker partition key по notification/recipient → channel orchestrator проверяет актуальный consent → render → provider call с stable provider idempotency key → сохраняет attempt/status. Callback deduplicate-ится по provider event ID.

## Retries и ordering

Transient errors получают bounded backoff/jitter; permanent invalid address уходит в terminal state. Retry queue/DLQ имеют owner и replay. Strict global order обычно не нужен; per-recipient priority/order конфликтует с parallelism и poison messages.

## Failures

Crash после provider acceptance до local commit создаёт duplicate — используйте provider idempotency/status reconciliation. Отмена после enqueue требует check перед send. Broker lag у urgent channel алертится по oldest age, не только depth. Provider outage изолируется bulkhead/circuit breaker, fallback channel разрешён только product policy.

## Scale и trade-offs

Separate queues/pools по channel/priority защищают critical traffic. Template rendering можно cache-ить по version. Exactly-once внешней доставки обычно недостижимо: обещайте at-least-once attempt/effectively-once при provider support. In-app может быть durable feed, email — irreversible side effect.

## Observability/security

Metrics accepted/sent/delivered/failed/age; trace до provider; audit consent/template. PII/secrets редактируются, payload encrypted/retained минимально.
