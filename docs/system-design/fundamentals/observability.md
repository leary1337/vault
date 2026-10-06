---
title: Observability в System Design
description: SLI, logs, metrics, traces и diagnostic context.
tags: [system-design, observability]
updated: 2026-10-06
---

# Observability в System Design

Наблюдаемость позволяет по данным понять, что испортилось для пользователя и где находится причина.

Observability проектируется вместе с contracts и failure modes. Цель — по внешним сигналам понять impact, bottleneck и причинную цепочку, не собирать максимум telemetry (диагностические данные: метрики, логи и traces).

## Сигналы

- SLI (измеренный показатель качества): success rate, latency (срок ответа) distribution, freshness/durability/queue age для user-visible operation.
- Metrics: traffic, errors by reason, latency, saturation (насыщение ресурса и образование очереди); bounded-cardinality (число разных значений или временных рядов) labels.
- Structured logs: timestamp, severity, service/version, operation, trace/request/event ID, outcome; без secrets/PII.
- Traces: propagation через HTTP/gRPC/queue, spans на remote calls и durable stages.
- Audit: кто изменил security/business state, отдельно от debug log.

Correlation (совпадение/связь наблюдений, ещё не доказанная причина) ID не доказывает causality, но связывает путь. Message headers должны переносить trace (связь этапов одной операции) context без использования его как idempotency key.

## Оповещения

Alert привязывают к SLO (цель качества сервиса за заданное окно) burn/user impact или imminent capacity/data loss, с owner и runbook. CPU 80% без impact — diagnostic signal; быстро растущий oldest queue age — часто actionable. Multi-window burn rate отличает краткий spike от устойчивого расхода error budget.

## Cost и безопасность

Sampling сохраняет representative traces, но errors/rare critical paths требуют tail-aware policy. Cardinality user ID/URL/event ID в metric labels взрывает стоимость; оставьте их в logs/traces. Задайте retention (срок хранения), redaction, access и deletion для telemetry.

Перед launch проверьте dashboard write/read path, synthetic probe, deployment annotation и возможность отличить dependency error от own saturation.

## На конкретном примере

Учебный incident: API p99 (время, в которое укладывается 99% наблюдений) вырос с 150 до 900 ms, DB query p99 осталось 40 ms, DB pool wait p99=700 ms, активные соединения упёрлись в limit. Это свидетельство ожидания pool, не доказательство медленного SQL. Проверяем рост числа запросов, время удержания connection и незакрытые rows/transactions.

Histogram строим с границами около SLO; среднее 50 ms не исключает p99=2 s. Метрика по `route=/ads/{id}` имеет ограниченные значения; label с каждым ad ID создаёт миллионы рядов. Для ID используем trace/log. Queue age измеряет свежесть; низкий HTTP error rate не доказывает здоровую асинхронную обработку.

## Источник механизма

[Prometheus: histograms](https://prometheus.io/docs/practices/histograms/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Как отличить slow SQL от pool starvation?
2. Почему event ID не label metric?

<details>
<summary>Ориентиры для ответа</summary>

1. Разделить время ожидания соединения и время выполнения query.
2. Он создаёт неограниченную cardinality, годится для logs/traces.

</details>
