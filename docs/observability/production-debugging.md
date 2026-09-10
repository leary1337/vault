---
title: Production debugging
description: Системный порядок диагностики incidents по metrics, traces, logs и profiles.
tags: [observability, debugging, incident-response]
updated: 2026-09-10
---

# Production debugging

Диагностика начинается с user impact и времени начала, а не с любимого инструмента. Цель первой фазы — ограничить ущерб и сузить пространство гипотез, сохраняя evidence.

## Workflow

1. Подтвердить incident: какой journey, доля пользователей, регионы и типы операций затронуты.
2. Зафиксировать timeline, текущее время, SLO burn, owners и канал координации.
3. Проверить последние deploy/config/feature/data/schema/infrastructure changes.
4. Сравнить healthy и unhealthy scope: version, pod/node/AZ, tenant, route, partition.
5. Пройти RED сверху вниз, затем USE на вероятном bottleneck.
6. Взять representative slow/error trace, перейти к связанным logs и dependency metrics.
7. Сформулировать проверяемые гипотезы и для каждой указать ожидаемый сигнал.
8. Выбрать минимально рискованный mitigation: rollback, traffic shift, feature disable, load shed, capacity.
9. Проверить user-visible recovery и остановку burn, а не только исчезновение одного alert.
10. Сохранить evidence и назначить root-cause analysis после стабилизации.

## Связь сигналов

Metrics отвечают «когда и насколько», traces — «какой путь и где время», logs — «какое событие/решение», profiles — «где CPU/allocation/blocking внутри процесса». Deployment annotations и config audit связывают изменение со временем. Correlation не доказывает причину: подтверждайте controlled rollback, comparison или mechanism.

## Безопасность диагностики

Не запускайте неограниченный debug logging, full packet capture или высокочастотный profiling на всём fleet без оценки overhead и privacy. Ограничивайте scope/time, используйте read-only запросы, сохраняйте timestamps и команды. Не рестартуйте все replicas одновременно: это уничтожает volatile evidence и может усилить outage.

## Быстрый triage

| Симптом | Первые проверки |
|---|---|
| ошибки | status/error taxonomy, dependency outcomes, deploy diff |
| latency | p50/p95/p99, queue time, slow traces, saturation |
| падение traffic | ingress/DNS/TLS, client metrics, routing |
| высокая нагрузка | request amplification, retries, hot key/partition, CPU throttling |
| backlog | arrival/processing rate, oldest age, consumer health |

Конкретные сценарии продолжены в следующем разделе базы — Production runbooks.

## Источники

- [Google SRE: effective troubleshooting](https://sre.google/sre-book/effective-troubleshooting/)
- [Go diagnostics](https://go.dev/doc/diagnostics)
