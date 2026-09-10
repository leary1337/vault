---
title: Load balancing
description: L4/L7 routing, health, affinity и overload behavior.
tags: [system-design, networking]
updated: 2026-09-10
---

# Load balancing

Load balancer распределяет connections/requests между eligible backends. Он не создаёт capacity и может скрыть перегрузку одного shard/tenant за средними метриками.

## L4 и L7

L4 маршрутизирует transport flows по address/port, сохраняет protocol transparency и обычно дешевле. L7 понимает HTTP/gRPC metadata, умеет route по host/path/header, terminate TLS, retry и enforce policy, но становится частью application semantics.

Algorithms: round-robin прост; least-connections полезен при разной duration, но число connections не равно active work при multiplexing; weighted routing отражает capacity; consistent/rendezvous hashing даёт affinity и снижает churn.

## Health и draining

Liveness отвечает «процесс жив», readiness — «можно дать новую работу». Probe должен проверять критическую способность без cascade от необязательной dependency. При rollout backend сначала становится unready, прекращает новые requests и bounded время drain-ит keep-alive/streams.

Session affinity упрощает local state, но ухудшает rebalance/failover; durable session храните вне instance. Connection pools/HTTP2 streams могут удерживать traffic после изменения weights, поэтому наблюдайте request-level distribution.

## Failure behavior

Retry на proxy может повторить non-idempotent request после ambiguous upstream outcome. Ограничьте per-try/overall timeout, retry budget и replayable body. Outlier ejection/circuit breaking требуют minimum samples и half-open recovery.

Смотрите end-to-end latency, backend saturation, active requests, queue, errors по reason, retries и imbalance. Подробнее: [networking](../../networking/README.md).
