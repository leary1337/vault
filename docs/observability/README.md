---
title: Observability
description: Метрики, логи, трассировка, SLO и production-диагностика backend-систем.
tags: [observability, sre, backend]
updated: 2026-09-10
---

# Observability

Observability — способность объяснить внутреннее состояние системы по её выходным сигналам. Это не название стека и не требование «собрать всё»: полезная telemetry должна отвечать на вопросы об impact, scope и cause при ограниченных стоимости и риске утечки данных.

Сигналы дополняют друг друга: metric обнаруживает рост latency, exemplar или trace показывает медленный путь, а structured log объясняет конкретный отказ. Ни один сигнал сам по себе не является источником истины о бизнес-результате.


## Темы

- [Alerting](alerting.md)
- [Distributed tracing](tracing.md)
- [Logs](logs.md)
- [Metrics](metrics.md)
- [OpenTelemetry](opentelemetry.md)
- [Production debugging](production-debugging.md)
- [SLI, SLO и SLA](sli-slo-sla.md)

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
