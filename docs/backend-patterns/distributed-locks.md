---
title: Distributed locks
description: Leases, ownership tokens и fencing для внешних side effects.
tags: [backend, patterns, distributed-systems]
updated: 2026-09-10
---

# Distributed locks

## Problem

Несколько processes должны координировать редкую critical section или singleton ownership, а local mutex не охватывает replicas.

## Mechanism

Linearizable coordination service выдаёт lease/lock с unique ownership и monotonic fencing token. Holder прикладывает token к downstream mutation; downstream отклоняет token ниже уже принятого. TTL ограничивает liveness при crash, но не заменяет fencing.

## Guarantees

Guarantee зависит от backend protocol, quorum, clock assumptions и downstream validation. Lock без fencing может допустить concurrent side effects после pause/partition, даже если key уже принадлежит новому holder.

## Failure modes

- process pause дольше lease и продолжает работу;
- asynchronous replica failover теряет lock;
- release удаляет lock нового owner;
- renewal loop жив, а protected work зависла;
- lock order создаёт deadlock;
- coordinator unavailable блокирует progress.

## Trade-offs

Strong coordinator добавляет latency и availability dependency. Lease ускоряет recovery, но создаёт uncertainty window. Часто optimistic concurrency, database unique constraint или idempotency проще и сильнее соответствует invariant.

## When not to use

Не используйте lock для маскировки non-idempotent handler, долгого workflow или correctness-critical external action без fencing. Для cache stampede best-effort singleflight/lease имеет более мягкие требования.

## Example

Worker получает `(resource, lease_expiry, fencing_token=57)`. Storage сохраняет max token; поздняя запись holder 56 отвергается. Release compare-ит ownership token. Redis-specific ограничения и Redlock trade-offs: [Redis distributed locks](../databases/redis/distributed-locks.md).
