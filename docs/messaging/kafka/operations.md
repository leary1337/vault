---
title: Эксплуатация Kafka
description: Capacity, health signals, reassignments, upgrades и incident checks.
tags: [messaging, kafka, operations]
updated: 2026-09-10
---

# Эксплуатация Kafka

Здоровье Kafka нельзя свести к «process up». SLO зависит от produce/fetch latency, under-replication, consumer timeliness, storage headroom и controller quorum.

## Capacity

Оцените ingress и replication traffic, retention bytes, partition count, peak catch-up после outage и network egress consumers. Replication factor примерно умножает broker-side storage/replication work, compression меняет bytes, а small records повышают per-request overhead.

Partitions дают parallelism, но слишком много partitions увеличивает metadata, file handles, recovery/election/reassignment time. Распределяйте leaders, replicas, bytes и traffic с rack awareness; равное число partitions не гарантирует равную нагрузку.

## Сигналы

- offline partitions — немедленная потеря availability;
- under-replicated partitions/ISR shrink — сниженная redundancy;
- request latency/queue time, network/thread idle и throttling;
- disk usage, log flush/I/O errors, page-cache pressure;
- controller quorum leader/voter lag и metadata processing;
- producer error/retry rates;
- consumer records/time lag, rebalance rate и DLQ growth.

ISR fluctuation — симптом network/disk/GC/resource problem, а не повод автоматически ослаблять `min.insync.replicas`.

## Изменения

Reassignment и preferred leader election нагружают network/disk; ограничивайте concurrency/throttle, следите за progress и снимайте временные throttles. Topic retention или segment settings способны быстро удалить данные либо заполнить disk — применяйте через review.

Rolling upgrade требует чтения version-specific upgrade notes, проверки client/broker compatibility и feature/metadata versions. Для KRaft отдельно проверяйте controller quorum before/after каждого шага. Backup topic configs/ACLs и data replication не заменяет проверенный disaster-recovery plan.

## Incident triage

1. Определите scope: один client, partition, broker, rack или control plane.
2. Зафиксируйте offline/URP, ISR, leaders, disk/network и recent changes.
3. Не restart-ите несколько replicas одной partition одновременно.
4. Стабилизируйте capacity/connectivity, затем восстанавливайте redundancy.
5. Сверьте end-to-end loss/duplicates/lag, а не только green broker metrics.

## Источники

- [Kafka operations](https://kafka.apache.org/43/operations/)
- [Monitoring](https://kafka.apache.org/43/operations/monitoring/)
- [Topic operations](https://kafka.apache.org/43/operations/basic-kafka-operations/)
