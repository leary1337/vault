---
title: High latency
description: Разложение end-to-end latency на queue, compute, I/O и retry time.
tags: [production, latency, observability]
updated: 2026-10-06
---

# High latency

Высокая latency (срок ответа) — вырос полный срок ответа; его нужно разложить на очередь, вычисление и ожидание.

## Симптомы

p95/p99 или доля запросов медленнее SLO (цель качества сервиса за заданное окно) растёт; timeouts увеличивают errors/retries. Average и p50 могут оставаться нормальными.

## Возможные причины

Queueing/saturation, slow dependency/query, connection/DNS/TLS establishment, lock contention, GC/scheduler delay, payload (полезное содержимое запроса или события) growth, retry amplification, hot shard (часть данных у отдельного владельца) или mixed slow cohort.

## Что измерить

Latency distribution по route/version/region/outcome, queue vs service time, dependency spans, saturation (насыщение ресурса и образование очереди), timeouts/retries и request budget. Cardinality (число разных значений или временных рядов) IDs оставляйте в traces/logs.

## Проверка гипотез

Подтвердите affected cohort и изменение traffic/deploy. Разложите representative slow trace (связь этапов одной операции) на admission, queue, compute и downstream wait. Сравните slow с healthy trace и server latency с client-observed latency. Затем проверяйте saturation конкретного компонента.

## Инструменты

Prometheus histograms/exemplars, distributed traces, structured logs, Go block/mutex/CPU profiles, database `EXPLAIN (ANALYZE, BUFFERS)` безопасно на representative query, network/DNS/TLS metrics.

## Как уменьшить ущерб

Rollback (отмена локальной транзакции или возврат старой версии), disable slow feature, shed/rate-limit expensive work, cap queue/deadlines, serve stale/cache, shift traffic или add capacity только в доказанном bottleneck. Не добавляйте retries к latency outage.

## Механизм причины

Опишите механизм critical path: какой ресурс/operation добавил queue/service time, почему control не ограничил его и как это перешло в SLO impact. Один slow span (измеряемый этап trace) — evidence, не статистическое доказательство.

## Предотвращение

Latency budgets по hop, bounded (с явным конечным пределом) concurrency/queues, representative load tests, query/index review, timeout hierarchy, trace sampling slow paths и SLO burn alerts.

## Разбор с числами

Учебный медленный trace: total 1 200 ms, admission queue 600, DB acquire 400, SQL 50, render 20, прочее 130. Растут две очереди, SQL пока быстр. Увеличить statement_timeout с 1 до 10 s не ускорит запрос: он будет дольше занимать систему. Ограничиваем вход, ищем владельца длительного ресурса и сравниваем здоровую реплику.

Другой cohort: только крупные ответы имеют p99 (время, в которое укладывается 99% наблюдений)=2 s, server пишет 30 MB клиенту, DB query=40 ms. Причина может быть bandwidth/медленный клиент; pool/индекс не объясняют объём передачи. Проверяем bytes, compression cost и server-vs-client latency.

При fan-out (раздача одного действия многим получателям) 50 независимых зависимостей с 1% вероятностью slow каждая вероятность хотя бы одной slow ≈ `1-0.99^50≈39,5%`. Это учебная независимая модель, реальная корреляция меняет результат. Уменьшение fan-out/batching может дать больше, чем локальная оптимизация одной функции.

## Источник механизма

[Google SRE: effective troubleshooting](https://sre.google/sre-book/effective-troubleshooting/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему p50 нормальна при incident?
2. Почему fan-out ухудшает tail?

<details>
<summary>Ориентиры для ответа</summary>

1. Проблема может затронуть только хвост или небольшой cohort.
2. Ответ ждёт медленнейшую из многих операций.

</details>
