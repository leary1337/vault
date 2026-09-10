---
title: Thundering herd
description: Диагностика синхронных cache misses, expirations, reconnects и wake-ups.
tags: [production, cache, concurrency]
updated: 2026-09-10
---

# Thundering herd

## Symptoms

Короткие резкие пики одинаковой работы перегружают database/API/CPU после cache expiry, restart, reconnect или scheduled boundary; множество callers ждут один и тот же result.

## Possible causes

Одинаковый TTL, cold cache/deploy, hot key, cache outage, synchronized cron, reconnect без jitter, broadcast wake-up, lock expiry или retry после общего timeout.

## What to measure

Request/miss/load rate по normalized key class, concurrent fills, cache hit/eviction/expiry, downstream amplification, lock/singleflight wait, scheduled timestamps и recovery slope.

## Diagnostics

Сопоставьте spike с expiry/deploy/schedule. Определите, одинаковый ли key/work у calls и кто должен координировать fill. Проверьте, herd локален instance-у или fleet-wide; local singleflight не защищает общий backend от многих replicas.

## Tools

Cache metrics/key sampling без PII, traces producer/waiters, scheduler/deploy events, downstream QPS, Redis hot-key/latency tooling и concurrency profiles.

## Immediate mitigation

Serve stale if safe, rate/load shed, ограничить concurrent fills, singleflight/lease, постепенно warm cache, добавить jitter к refresh/reconnect и временно увеличить dependency capacity. Distributed lock без fencing/TTL design может создать новый failure.

## Root cause

Найдите общий synchronization event и отсутствие coordination/randomization/bound: какая работа дублировалась, сколько раз и почему cache/dependency получил burst.

## Prevention

TTL jitter, stale-while-revalidate, proactive refresh, negative caching с осторожностью, local + distributed request coalescing, warm-up/ramp-up, hot-key sharding и randomized schedules. См. [singleflight](../backend-patterns/singleflight.md) и [cache-aside](../backend-patterns/cache-aside.md).

