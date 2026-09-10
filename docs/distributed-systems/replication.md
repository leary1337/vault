---
title: Репликация
description: Single-leader, multi-leader и leaderless replication.
tags: [distributed-systems, replication]
updated: 2026-09-10
---

# Репликация

Replication копирует данные между failure domains ради availability, read scale и recovery. Она не заменяет backup: corruption, operator error и delete тоже реплицируются.

## Single leader

Writes идут leader, followers применяют ordered log. Synchronous acknowledgement нескольких replicas уменьшает RPO, но повышает latency и может снизить write availability; asynchronous replication быстрее, но при failover теряет acknowledged tail.

Failover требует выбрать достаточно свежий follower, fence-ить старого leader, переключить clients и восстановить replicas. Без epoch/term старый leader после partition создаёт split brain.

Read replica может быть stale. Read-your-writes достигают routing на leader, ожиданием version/LSN или session token; «подождать 100 ms» не является гарантией.

## Multi-leader

Несколько leaders принимают writes, что удобно для disconnected/multi-region operation, но concurrent changes конфликтуют. Last-write-wins зависит от clocks и теряет одно значение; merge CRDT/application rule должен соответствовать бизнес-инварианту. Уникальность и cross-object constraints особенно сложны.

## Leaderless

Client/coordinator пишет/читает несколько replicas и объединяет versions. Quorum intersection помогает увидеть новую запись, но hinted handoff, sloppy quorums, concurrent versions, clock-based LWW и failed repair ослабляют простую формулу. Нужны versioning, read repair и anti-entropy.

## Lag и repair

Измеряйте не только replica count, но применённую position/version, time/byte lag, queue growth и oldest unreplicated change. Recovery traffic конкурирует с production. Anti-entropy должен обнаруживать silent divergence, а checksum/scrub — corruption.

Выбор topology начинается с consistency model и допустимых RPO/RTO, затем учитывает latency, write conflicts, read routing, capacity при отказе и operational complexity.

## Источники

- [Amazon Dynamo paper](https://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf)
- [Google Spanner paper](https://research.google/pubs/spanner-googles-globally-distributed-database/)
