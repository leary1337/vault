---
title: Репликация
description: Physical и logical replication, consistency, slots и failover.
tags: [databases, postgresql, replication]
updated: 2026-09-10
---

# Репликация PostgreSQL

Replication повышает доступность и масштабирует некоторые чтения, но сама по себе не является backup и не определяет автоматический failover.

## Physical streaming replication

Primary передаёт WAL, standby replay-ит те же физические изменения всего cluster. Версии major PostgreSQL у primary и standby должны соответствовать требованиям binary/physical compatibility; physical replica не выбирает отдельные tables.

По умолчанию streaming replication asynchronous: commit primary не ждёт standby, поэтому при аварийном promotion возможна потеря последних transactions. Synchronous replication заставляет commit ждать указанных synchronous standbys на выбранной стадии (`remote_write`, `on`/flush, `remote_apply`), повышая durability/visibility ценой latency и availability при недоступности required standbys.

Hot standby обслуживает read-only queries. Долгий query может конфликтовать с WAL replay и быть отменён; бесконечная задержка replay увеличивает lag. `hot_standby_feedback` уменьшает cleanup conflicts, но способен вызвать bloat на primary.

## Logical replication

Publisher передаёт логические row changes выбранных publications, subscriber применяет их к tables. Это удобно для subset replication, migrations и разных схем topology. DDL и sequence state не реплицируются как обычные table changes автоматически; schema и cutover требуют отдельного плана.

Logical replication обычно требует replica identity для `UPDATE`/`DELETE`. Initial table synchronization и последующий stream должны быть включены в capacity plan.

## Slots, lag и failover

Replication slot удерживает нужный WAL/row versions до подтверждения consumer. Он защищает от преждевременного удаления, но упавший consumer может заполнить disk; задавайте/наблюдайте retention limits и `pg_replication_slots`.

Измеряйте отдельно:

- send/write/flush/replay LSN lag;
- time lag и replay delay;
- replication slot retained bytes;
- conflicts/cancelled queries;
- способность standby реально promotion-нуться и принять traffic.

Failover manager, fencing старого primary, routing клиентов, data-loss policy и rejoin вынесены за пределы core streaming replication. Регулярный switchover test важнее наличия standby в dashboard.

## Источники

- [High availability and load balancing](https://www.postgresql.org/docs/18/high-availability.html)
- [Warm standby and streaming replication](https://www.postgresql.org/docs/18/warm-standby.html)
- [Logical replication](https://www.postgresql.org/docs/18/logical-replication.html)
