---
title: Consistent hashing
description: Rings, virtual nodes, rendezvous hashing и ограничения.
tags: [distributed-systems, sharding]
updated: 2026-09-10
---

# Consistent hashing

Обычный `hash(key) mod N` перемещает почти все keys при изменении N. Consistent hashing стремится переместить только долю keyspace, связанную с добавленным/удалённым node.

## Hash ring

Keys и node positions отображаются на кольцо. Key принадлежит следующему node clockwise. Один physical node получает много virtual nodes (tokens), что сглаживает distribution и позволяет weight по capacity.

При добавлении node ему переходят intervals соседей; при удалении — следующему owner. Replication выбирает несколько distinct owners дальше по ring с учётом failure domains.

Virtual nodes не гарантируют баланс workload: hash может распределять keys равномерно, но один key имеет половину QPS/bytes. Больше tokens улучшает статистический balance, но увеличивает routing metadata и migration fragments.

## Rendezvous hashing

Highest Random Weight вычисляет score для пары `(key, node)` и выбирает node с максимальным score. Он прост для clients, хорошо поддерживает weights и top-K replicas, но naive routing вычисляет score для каждого node; оптимизации нужны при большом membership.

## Operational requirements

- membership должен иметь version/epoch и согласованно распространяться;
- old/new clients во время change могут отправлять key разным owners;
- ownership transfer требует copy/catch-up protocol, сам hashing данные не переносит;
- replication обязана выбирать разные zones, а не только соседние tokens одного host;
- hot key требует split/replication/cache, не новой hash function.

Consistent hashing полезен для caches, object placement и sharded stores, но не заменяет consensus для authoritative membership и не сохраняет cross-key transactions.

## Источники

- [Consistent Hashing and Random Trees](https://www.cs.princeton.edu/courses/archive/fall09/cos518/papers/chash.pdf)
- [Rendezvous hashing](https://www.eecs.umich.edu/techreports/cse/96/CSE-TR-316-96.pdf)
