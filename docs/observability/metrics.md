---
title: Metrics
description: Prometheus-модель, типы метрик, RED/USE, percentiles и cardinality.
tags: [observability, metrics, prometheus]
updated: 2026-10-06
---

# Metrics

Метрика агрегирует события; каждый набор labels — отдельный временной ряд с ценой памяти и хранения.

Metric превращает множество событий в time series. В Prometheus series определяется именем метрики и полным набором labels; каждое новое значение label создаёт новую series. Поэтому labels — часть схемы и capacity planning, а не произвольный контекст.

## Типы

| Тип | Что хранит | Пример | Ограничение |
|---|---|---|---|
| Counter | монотонно растущее значение, кроме reset | requests, bytes, failures | анализировать через `rate`/`increase`, учитывать restart |
| Gauge | текущее значение, может расти и падать | queue depth, active connections | snapshot не показывает скорость изменения |
| Histogram | count/sum и cumulative buckets наблюдений | request duration, payload (полезное содержимое запроса или события) size | buckets умножают series, но агрегируются между instances |
| Summary | count/sum и, опционально, client-side quantiles | локальная latency (срок ответа) | quantiles обычно нельзя корректно агрегировать |

Для latency обычно выбирают histogram. Границы buckets должны охватывать продуктовые пороги: если SLO (цель качества сервиса за заданное окно) требует `95% < 300 ms`, нужен bucket около `0.3` секунды. Classic histogram оценивает percentile через `histogram_quantile`; результат ограничен разрешением buckets. Native histograms уменьшают ручную настройку, но требуют проверки совместимости всей цепочки.

## RED и USE

RED описывает request-driven service:

- Rate — объём операций;
- Errors — доля неуспешных операций по понятной классификации;
- Duration — распределение latency, а не только average.

USE описывает ресурс:

- Utilization — доля занятого capacity;
- Saturation (насыщение ресурса и образование очереди) — очередь или отложенная работа;
- Errors — resource-level failures.

RED показывает user-visible symptom; USE помогает найти bottleneck. CPU utilization без queue/run latency не доказывает saturation.

## Labels и cardinality

Хорошие labels имеют ограниченный набор значений: route template, method, status class, dependency, error category. Не помещайте в labels user ID, request ID, полный URL, stack trace (связь этапов одной операции), message ID или необработанный error text. Cardinality (число разных значений или временных рядов) приблизительно перемножается: 20 routes × 8 statuses × 50 tenants уже дают тысячи series на одну metric family.

Сохраняйте подробные идентификаторы в logs/traces. Нормализуйте route (`/users/{id}`), ограничивайте tenant dimensions и удаляйте label, если по нему никто не принимает решение.

## Практика

- фиксируйте unit и suffix (`_seconds`, `_bytes`, `_total`);
- считайте numerator и denominator одного SLI (измеренный показатель качества) в одинаковой точке;
- не усредняйте percentiles и averages из уже агрегированных averages;
- записывайте ошибки по причине, но с bounded (с явным конечным пределом) taxonomy;
- проверяйте scrape gaps, counter resets и delayed samples;
- версионируйте dashboards и recording/alerting rules рядом с кодом.

## Источники

- [Prometheus metric types](https://prometheus.io/docs/concepts/metric_types/)
- [Prometheus data model](https://prometheus.io/docs/concepts/data_model/)
- [Prometheus: histograms and summaries](https://prometheus.io/docs/practices/histograms/)
- [Google SRE: monitoring distributed systems](https://sre.google/sre-book/monitoring-distributed-systems/)

## Разбор с числами

Пример classic histogram в секундах:

```promql
# p99 по всем репликам, сохраняя route и обязательный le.
histogram_quantile(0.99,
  sum by (le, route) (rate(http_request_duration_seconds_bucket[5m]))
)

# Доля запросов не медленнее 300 ms при наличии bucket le="0.3".
sum by (route) (rate(http_request_duration_seconds_bucket{le="0.3"}[5m]))
/
sum by (route) (rate(http_request_duration_seconds_count[5m]))
```

Сначала `rate` для каждого counter, затем sum: иначе reset одной реплики искажается. Деление при нулевом трафике не даёт измеренную успешность; обрабатываем no-data отдельно. Native histogram имеет другой набор series и иной запрос; приведённая формула предназначена именно для classic.

Учебный размер: 10 routes × 5 statuses × 20 replicas × 12 bucket series = 12 000 рядов только buckets, плюс count/sum. User ID с миллионом значений увеличит порядок на миллион: это не бесплатное поле. p99 (время, в которое укладывается 99% наблюдений) разных реплик нельзя усреднять, но можно агрегировать их histogram buckets.

## Проверь себя

1. Почему сначала rate, затем sum?
2. Почему average p99 неверен?

<details>
<summary>Ориентиры для ответа</summary>

1. Counter resets определяются на отдельных рядах.
2. Percentile объединённого распределения не равен среднему локальных percentiles.

</details>
