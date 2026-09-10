---
title: Observability в System Design
description: SLI, logs, metrics, traces и diagnostic context.
tags: [system-design, observability]
updated: 2026-09-10
---

# Observability в System Design

Observability проектируется вместе с contracts и failure modes. Цель — по внешним сигналам понять impact, bottleneck и причинную цепочку, не собирать максимум telemetry.

## Signals

- SLI: success rate, latency distribution, freshness/durability/queue age для user-visible operation.
- Metrics: traffic, errors by reason, latency, saturation; bounded-cardinality labels.
- Structured logs: timestamp, severity, service/version, operation, trace/request/event ID, outcome; без secrets/PII.
- Traces: propagation через HTTP/gRPC/queue, spans на remote calls и durable stages.
- Audit: кто изменил security/business state, отдельно от debug log.

Correlation ID не доказывает causality, но связывает путь. Message headers должны переносить trace context без использования его как idempotency key.

## Alerts

Alert привязывают к SLO burn/user impact или imminent capacity/data loss, с owner и runbook. CPU 80% без impact — diagnostic signal; быстро растущий oldest queue age — часто actionable. Multi-window burn rate отличает краткий spike от устойчивого расхода error budget.

## Cost и безопасность

Sampling сохраняет representative traces, но errors/rare critical paths требуют tail-aware policy. Cardinality user ID/URL/event ID в metric labels взрывает стоимость; оставьте их в logs/traces. Задайте retention, redaction, access и deletion для telemetry.

Перед launch проверьте dashboard write/read path, synthetic probe, deployment annotation и возможность отличить dependency error от own saturation.
