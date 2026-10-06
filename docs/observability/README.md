---
title: "Наблюдаемость: понять, что происходит"
description: "Метрики показывают масштаб, логи — события, трассировки — путь запроса"
tags: [observability, sre, backend]
updated: 2026-10-06
---

# Наблюдаемость: понять, что происходит

Метрики показывают масштаб, логи — события, трассировки — путь запроса. Раздел объясняет, как читать эти данные и отличать возможные причины.

Открывайте нужную тему по вопросу. В статье сначала разберите механизм и пример, затем ответьте на «Проверь себя» до раскрытия ответа.

## Темы

- [Оповещения: когда нужно вмешательство](alerting.md)
- [Трассировка: где прошёл и чего ждал запрос](tracing.md)
- [Логи: записи событий, которые можно связать](logs.md)
- [Метрики: измерять поведение системы](metrics.md)
- [OpenTelemetry: общий путь диагностических данных](opentelemetry.md)
- [Диагностика работающего сервиса](production-debugging.md)
- [SLI, SLO и SLA: измерение, цель и договор](sli-slo-sla.md)

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
