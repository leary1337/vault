---
title: Distributed rate limiter
description: Scope, token bucket, placement и failover limiter state.
tags: [system-design, cases]
updated: 2026-09-10
---

# Distributed rate limiter

## Requirements

Ограничить tenant/user/API по requests или weighted cost, допустить controlled burst, вернуть решение за малую latency. Уточнить global accuracy, fairness, fail-open/closed, config propagation и analytics.

## Contract

Input: identity, rule, cost, timestamp/context. Output: allowed, remaining estimate, reset/retry time и reason. Policy хранится versioned; decision state scoped так, чтобы один tenant не влиял на другого.

## Algorithm alternatives

- token bucket: refill rate + capacity, хороший default для burst;
- fixed/sliding window: проще reporting, разные boundary/space costs;
- concurrency limit: защищает длительную работу лучше request rate;
- hierarchical limiter: global → tenant → endpoint.

## Architecture

Edge local bucket даёт низкую latency, но global overshoot пропорционален instances. Central Redis atomic script/function точнее, но добавляет network hop/hot key. Token leasing выделяет каждому node порцию global budget и ограничивает overshoot ценой менее точного использования.

## Failures

При Redis/coordination outage security/cost rule может fail-closed, availability rule — bounded fail-open с local emergency limit. Clock skew не должен позволять отрицательный/огромный refill; server-side time или monotonic local lease уменьшает риск. Config rollout включает version, а не instant mutation без audit.

## Scale

Shard state по limiter key, отдельно решая global cap. TTL удаляет inactive keys; cardinality/attack на новые identities ограничивается. Наблюдайте allowed/rejected, decision latency, overshoot estimate, hot keys и downstream saturation.

## Trade-offs

Абсолютно точный global limit требует coordination и снижает availability. Для capacity часто достаточно bounded overshoot; для финансовой quota может требоваться authoritative reservation ledger.
