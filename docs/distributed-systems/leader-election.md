---
title: Leader election
description: Terms, leases, fencing и безопасный failover.
tags: [distributed-systems, consensus]
updated: 2026-09-10
---

# Leader election

Leader election выбирает единственного coordinator на epoch, но одного выбора недостаточно: старый leader может быть жив в partition. Без fencing два процесса одновременно выполнят side effects.

## Consensus-backed election

Quorum protocol выдаёт новый монотонный term/epoch. Leader прикладывает epoch к writes; replicated state или downstream resource отвергает epoch ниже уже принятого. Это отличает ownership proof от «я давно не видел другого leader».

Candidate должен иметь достаточно актуальный replicated state, иначе promotion теряет committed data. Election timeout рандомизируют, чтобы кандидаты не голосовали синхронно; слишком маленький timeout вызывает churn при latency spike, слишком большой увеличивает failover time.

## Leases

Time-based lease даёт leadership на ограниченный срок. Для safety нужны bounded clock drift/uncertainty и правило, не допускающее overlap; process pause может пережить lease. Даже после локальной проверки времени downstream fencing token остаётся сильнее.

## Небезопасные варианты

- lock file на shared storage без надёжной atomicity/fencing;
- «самый маленький instance ID» без согласованного membership;
- TTL key с failover на asynchronous replica;
- health check/load balancer, который только меняет traffic и не fence-ит old leader;
- ручное promotion двух сторон network partition.

## Operations

Укажите election authority, quorum, epoch storage, readiness condition и demotion path. При incident проверяйте current term/leader, quorum reachability, last committed/applied position и старые processes. Chaos test должен включать pause, one-way partition и delayed messages, а не только kill процесса.

Для cron-like singleton часто проще сделать работу idempotent и допустить несколько workers, чем строить слабую election.

## Источники

- [Raft paper](https://raft.github.io/raft.pdf)
- [Leases: an efficient fault-tolerant mechanism](https://dl.acm.org/doi/10.1145/74850.74870)
