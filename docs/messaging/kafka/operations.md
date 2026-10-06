---
title: Эксплуатация Kafka
description: Capacity, health signals, reassignments, upgrades и incident checks.
tags: [messaging, kafka, operations]
updated: 2026-10-06
---

# Эксплуатация Kafka

Эксплуатация Kafka проверяет, что сообщения доходят вовремя и выдерживают нужные отказы. Зелёный process health не доказывает отсутствие потерь, задержки или дублей.

Здоровье Kafka нельзя свести к «process up». SLO зависит от produce/fetch latency, under-replication, consumer timeliness, storage headroom и controller quorum.

## Расчёт ресурсов

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

## Разбор инцидента

1. Определите scope: один client, partition, broker, rack или control plane.
2. Зафиксируйте offline/URP, ISR, leaders, disk/network и recent changes.
3. Не restart-ите несколько replicas одной partition одновременно.
4. Стабилизируйте capacity/connectivity, затем восстанавливайте redundancy.
5. Сверьте end-to-end loss/duplicates/lag, а не только green broker metrics.

## Посчитать место

При ingress 10 MB/s, retention 7 дней и RF=3 сырые данные требуют примерно `10×86400×7×3=18144000 MB`, то есть около 18.1 TB десятичных bytes. Если ingress уже измерен после compression, не применяйте коэффициент compression второй раз. Добавьте сегменты, индексы, overhead, skew и резерв на recovery/reassignment; количество brokers выбирайте по bytes **и** I/O/network.

```text
bin/kafka-topics.sh --bootstrap-server localhost:9092 \
  --describe --under-replicated-partitions
bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group ads-indexer
```

Первая команда показывает partitions с недостающими ISR, вторая позиции обработки. URP без offline partition означает сниженный запас надёжности, не обязательно уже потерянные данные. При RF3/minISR2 падение второго replica блокирует защищённые writes; снижать minISR только ради зелёного dashboard означает изменить RPO.

Time lag события важнее одного records lag: десять старых тяжёлых events могут нарушать SLO сильнее тысячи свежих. Для DLQ должен существовать ответственный, политика replay и alert. Плановый upgrade проверяет совместимость clients и metadata feature version; откат бинарника после изменения metadata не всегда разрешён.

## Источники

- [Kafka operations](https://kafka.apache.org/43/operations/)
- [Monitoring](https://kafka.apache.org/43/operations/monitoring/)
- [Topic operations](https://kafka.apache.org/43/operations/basic-kafka-operations/)

## Проверь себя

1. **Почему равное число partitions не равно равной нагрузке?**

   <details>
   <summary>Ответ</summary>

   Размеры, key skew, traffic и compression различаются.

   </details>

2. **Можно ли назвать Kafka здоровой при lag=0?**

   <details>
   <summary>Ответ</summary>

   Нет: ранний commit мог скрыть незавершённый effect; также проверяются ISR, offline partitions и end-to-end результат.

   </details>
