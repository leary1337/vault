---
title: Distributed tracing
description: Traces, spans, propagation, baggage, links и sampling.
tags: [observability, tracing, distributed-systems]
updated: 2026-09-10
---

# Distributed tracing

Trace представляет причинный путь операции. Span описывает одну операцию за интервал времени: имя, начало/конец, status, attributes, events и links. Parent-child связывает синхронно обусловленные операции; link подходит для batch, fan-in/fan-out и обработки сообщения отдельно от producer span.

## Context propagation

Клиент inject-ит trace context в carrier, сервер или consumer extract-ит его и создаёт дочерний span. Для HTTP/gRPC carrier — headers/metadata, для Kafka — record headers. Стандартный default OpenTelemetry использует W3C Trace Context.

Propagation нельзя считать доверительной границей. На public ingress валидируйте размеры и формат, решите, продолжать ли внешний trace или начинать новый. Не отправляйте внутренний baggage третьим сторонам без фильтрации.

## Baggage

Baggage — распространяемые key/value рядом с context; это не span attributes автоматически. Он копируется по цепочке, увеличивает headers и может утечь наружу. Не помещайте туда credentials, secrets или PII. Высококардинальные значения добавляйте к нужному span только при диагностической ценности.

## Что инструментировать

- inbound HTTP/gRPC и исходящие remote calls;
- database/cache calls без query secrets;
- Kafka send/receive/process, topic и consumer group с контролем cardinality;
- durable write, queue wait и важные business stages;
- retries как events или child spans так, чтобы видеть amplification.

Не создавайте span на каждую локальную функцию. Имена должны быть low-cardinality (`HTTP GET /ads/{id}`, а не полный URL). Error status ставят по semantic conventions: ожидаемый domain result не всегда техническая ошибка.

## Sampling

Head sampling принимает решение в начале: дёшево и согласованно, но outcome ещё неизвестен. Tail sampling решает после завершения и может сохранять errors/slow/rare traces, но Collector должен буферизовать trace и видеть все его spans. Parent-based policy сохраняет согласованность дочерних решений.

Sampling не исправляет отсутствие propagation или плохую instrumentation. Метрики остаются основой точных ratios: sampled traces не следует напрямую считать denominator SLI без статистически корректной схемы.

## Источники

- [OpenTelemetry traces](https://opentelemetry.io/docs/concepts/signals/traces/)
- [OpenTelemetry context propagation](https://opentelemetry.io/docs/concepts/context-propagation/)
- [OpenTelemetry baggage](https://opentelemetry.io/docs/concepts/signals/baggage/)
- [OpenTelemetry sampling](https://opentelemetry.io/docs/concepts/sampling/)

