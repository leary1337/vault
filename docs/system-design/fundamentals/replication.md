---
title: Replication в System Design
description: Read scale, failover и durability decisions.
tags: [system-design, replication]
updated: 2026-09-10
---

# Replication в System Design

Replication проектируют от failure domains и consistency, а не от числа копий.

## Решения

- leader, multi-leader или leaderless write path;
- synchronous acknowledgement или asynchronous lag;
- read routing и session guarantees;
- promotion authority, freshness и fencing;
- repair, backup и reconciliation;
- placement across rack/zone/region.

Synchronous cross-zone replica улучшает durability, но добавляет latency и может остановить writes при потере quorum. Asynchronous replica сохраняет availability/latency, но допускает потерю acknowledged tail и stale reads.

Read scaling работает только если workload допускает lag и replicas имеют capacity на replay плюс queries. Долгий analytical query может конфликтовать с cleanup/replay конкретной database.

## Failure review

Проиграйте leader crash до/после acknowledgement, network partition со старым leader, promotion lagging replica, loss whole zone и failed rejoin. Зафиксируйте RPO/RTO и кто принимает риск unclean failover.

Наблюдайте applied position/lag, not просто «replica connected». Регулярно тестируйте promotion, client rerouting, fencing и restore. Глубже: [replication models](../../distributed-systems/replication.md).
