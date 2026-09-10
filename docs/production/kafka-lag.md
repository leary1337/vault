---
title: Kafka consumer lag
description: Диагностика backlog age, consumer throughput, rebalances и hot partitions.
tags: [production, kafka, messaging]
updated: 2026-09-10
---

# Kafka consumer lag

## Symptoms

Offset lag и, важнее, возраст oldest unprocessed event растут; freshness SLO нарушается. Lag count может расти при нормальном processing time из-за traffic burst.

## Possible causes

Arrival rate выше processing capacity, slow dependency, poison message/retry loop, rebalance churn, crashed/stalled members, too few partitions, hot partition/key, large records/batches, broker/network throttling или incorrect offset observation.

## What to measure

Produce/consume rate, lag по partition, oldest event age, process latency/outcome, poll/commit/rebalance metrics, consumer membership, dependency saturation и broker request/throttle/under-replication signals.

## Diagnostics

Проверьте, растёт ли lag на всех или одной partition. Сравните arrival и successful completion rate, затем consumer health/rebalances и process spans. Найдите самый старый record metadata без вывода sensitive payload. Отделите receive/poll от фактического business completion и commit.

## Tools

Kafka consumer-group tooling/APIs, client metrics/logs, broker metrics, traces с messaging semantics, dependency dashboards и DLQ/retry-topic inspection.

## Immediate mitigation

Устранить poison retry, pause необязательных producers/jobs, увеличить consumers до числа полезных partitions, ускорить/отключить bottleneck, применить controlled load shed или replay/DLQ policy. Не увеличивайте partitions поспешно: ordering/key distribution и later scale меняются.

## Root cause

Докажите, почему service rate стал ниже arrival rate или конкретная partition остановилась, включая trigger и missing bound. «Большой lag» — symptom; root cause находится в producer, consumer, dependency или broker path.

## Prevention

Alert на oldest age и growth, capacity headroom, bounded retries/DLQ, idempotent processing, rebalance-safe shutdown, partition/key review и load/replay exercises. См. [Kafka consumers](../messaging/kafka/consumer.md).

