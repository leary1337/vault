---
title: Consumer groups
description: Membership, assignment, rebalance и актуальные group protocols.
tags: [messaging, kafka, consumer-groups]
updated: 2026-09-10
---

# Consumer groups

Обычная consumer group распределяет каждую topic partition не более чем одному member группы. Несколько групп читают topic независимо; consumers сверх числа partitions остаются idle.

## Assignment и rebalance

Coordinator хранит membership и committed offsets. При join/leave, subscription/topology change группа меняет assignment. Eager rebalance отзывает всё сразу; cooperative/incremental assignment старается перемещать только нужные partitions и уменьшает stop-the-world pause.

Assignor определяет баланс и affinity: range может создавать перекос между topics, round-robin распределяет шире, sticky сохраняет прежние assignments, cooperative sticky поддерживает incremental transfer. Проверяйте совместимость strategy при rolling change.

Rebalance callback должен:

- остановить выдачу новой работы для revoked partitions;
- дождаться/отменить bounded in-flight processing;
- commit-ить только contiguous успешно обработанный prefix;
- освободить partition-scoped state.

Static membership (`group.instance.id`) уменьшает rebalance при кратком restart, но duplicate identity fence-ится, а реальный failure всё равно ждёт timeout.

## Classic и consumer protocol

Kafka 4.x поддерживает classic protocol и новый consumer rebalance protocol. Server support нового protocol включён; Java client выбирает его через `group.protocol=consumer`. В новом protocol assignment logic находится на broker, rebalance incremental, а heartbeat/session settings в большей степени задаёт server. Default клиента и доступные assignors проверяйте для конкретной 4.x версии перед rollout.

Миграция protocol — изменение поведения: обновите clients, metrics, timeouts и проведите rolling test. Не смешивайте рекомендации по classic heartbeat settings с consumer protocol без проверки.

Kafka 4.2 также сделал production-ready share groups: несколько consumers могут обрабатывать records одной partition с individual acknowledgements и delivery attempts. Это отдельная queue-like модель, а не новый assignor обычной consumer group.

## Источники

- [Consumer rebalance protocol](https://kafka.apache.org/43/operations/consumer-rebalance-protocol/)
- [Kafka Queues and share groups](https://kafka.apache.org/43/operations/kafka-queues/)
