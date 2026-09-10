---
title: Observability
description: Метрики, логи, трассировка, SLO и production-диагностика backend-систем.
tags: [observability, sre, backend]
updated: 2026-09-10
---

# Observability

Observability — способность объяснить внутреннее состояние системы по её выходным сигналам. Это не название стека и не требование «собрать всё»: полезная telemetry должна отвечать на вопросы об impact, scope и cause при ограниченных стоимости и риске утечки данных.

## Порядок изучения

1. [Metrics](metrics.md): агрегированные симптомы и capacity.
2. [Logs](logs.md): дискретные события и диагностический контекст.
3. [Tracing](tracing.md): причинный путь запроса между компонентами.
4. [OpenTelemetry](opentelemetry.md): единый instrumentation и export pipeline.
5. [SLI, SLO и SLA](sli-slo-sla.md): измеримая цель надёжности.
6. [Alerting](alerting.md): actionable notification по влиянию и burn rate.
7. [Production debugging](production-debugging.md): воспроизводимый порядок расследования.

Сигналы дополняют друг друга: metric обнаруживает рост latency, exemplar или trace показывает медленный путь, а structured log объясняет конкретный отказ. Ни один сигнал сам по себе не является источником истины о бизнес-результате.

## Минимальный контракт сервиса

- стабильные `service.name`, environment и version/deployment attributes;
- request rate, errors, latency distribution и saturation;
- trace context через HTTP, gRPC и сообщения;
- structured logs с `trace_id`, но без secrets и лишнего PII;
- SLI, SLO, owner, alert и проверенный runbook для критичных user journeys;
- retention, sampling, redaction и бюджеты cardinality/стоимости.

## Источники

- [OpenTelemetry: observability primer](https://opentelemetry.io/docs/concepts/observability-primer/)
- [Google SRE: monitoring distributed systems](https://sre.google/sre-book/monitoring-distributed-systems/)

