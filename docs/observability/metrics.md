---
title: Metrics
description: Prometheus-модель, типы метрик, RED/USE, percentiles и cardinality.
tags: [observability, metrics, prometheus]
updated: 2026-09-10
---

# Metrics

Metric превращает множество событий в time series. В Prometheus series определяется именем метрики и полным набором labels; каждое новое значение label создаёт новую series. Поэтому labels — часть схемы и capacity planning, а не произвольный контекст.

## Типы

| Тип | Что хранит | Пример | Ограничение |
|---|---|---|---|
| Counter | монотонно растущее значение, кроме reset | requests, bytes, failures | анализировать через `rate`/`increase`, учитывать restart |
| Gauge | текущее значение, может расти и падать | queue depth, active connections | snapshot не показывает скорость изменения |
| Histogram | count/sum и cumulative buckets наблюдений | request duration, payload size | buckets умножают series, но агрегируются между instances |
| Summary | count/sum и, опционально, client-side quantiles | локальная latency | quantiles обычно нельзя корректно агрегировать |

Для latency обычно выбирают histogram. Границы buckets должны охватывать продуктовые пороги: если SLO требует `95% < 300 ms`, нужен bucket около `0.3` секунды. Classic histogram оценивает percentile через `histogram_quantile`; результат ограничен разрешением buckets. Native histograms уменьшают ручную настройку, но требуют проверки совместимости всей цепочки.

## RED и USE

RED описывает request-driven service:

- Rate — объём операций;
- Errors — доля неуспешных операций по понятной классификации;
- Duration — распределение latency, а не только average.

USE описывает ресурс:

- Utilization — доля занятого capacity;
- Saturation — очередь или отложенная работа;
- Errors — resource-level failures.

RED показывает user-visible symptom; USE помогает найти bottleneck. CPU utilization без queue/run latency не доказывает saturation.

## Labels и cardinality

Хорошие labels имеют ограниченный набор значений: route template, method, status class, dependency, error category. Не помещайте в labels user ID, request ID, полный URL, stack trace, message ID или необработанный error text. Cardinality приблизительно перемножается: 20 routes × 8 statuses × 50 tenants уже дают тысячи series на одну metric family.

Сохраняйте подробные идентификаторы в logs/traces. Нормализуйте route (`/users/{id}`), ограничивайте tenant dimensions и удаляйте label, если по нему никто не принимает решение.

## Практика

- фиксируйте unit и suffix (`_seconds`, `_bytes`, `_total`);
- считайте numerator и denominator одного SLI в одинаковой точке;
- не усредняйте percentiles и averages из уже агрегированных averages;
- записывайте ошибки по причине, но с bounded taxonomy;
- проверяйте scrape gaps, counter resets и delayed samples;
- версионируйте dashboards и recording/alerting rules рядом с кодом.

## Источники

- [Prometheus metric types](https://prometheus.io/docs/concepts/metric_types/)
- [Prometheus data model](https://prometheus.io/docs/concepts/data_model/)
- [Prometheus: histograms and summaries](https://prometheus.io/docs/practices/histograms/)
- [Google SRE: monitoring distributed systems](https://sre.google/sre-book/monitoring-distributed-systems/)

