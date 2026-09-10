---
title: Reverse proxy и load balancing
description: L4/L7 routing, trust boundaries, health checks, draining и affinity.
tags: [networking, proxy, load-balancing]
updated: 2026-09-10
---

# Reverse proxy и load balancing

Forward proxy действует от имени client-а; reverse proxy принимает traffic от имени origin services. Load balancer выбирает backend target, но может одновременно завершать TLS, нормализовать HTTP, ограничивать нагрузку и собирать telemetry.

## L4 и L7

| Уровень | Видит | Сильные стороны | Цена/ограничение |
|---|---|---|---|
| L4 | адреса, ports, transport connection | protocol-agnostic, меньше parsing, passthrough | не маршрутизирует по HTTP route/header, coarse policy |
| L7 | application protocol/request | host/path/header routing, auth/rate limit, retries | termination/parsing cost, protocol semantics и новый failure point |

Конкретный продукт может смешивать уровни. Выбирайте по требуемой policy и encryption boundary, не по лозунгу «L7 умнее».

## Balancing и affinity

Round robin, least connections/load, hashing и locality имеют разные assumptions. Одна HTTP/2/QUIC connection несёт много requests, поэтому connection-level L4 балансировка может дать менее ровное request distribution. Sticky session уменьшает cache/session movement, но создаёт hotspots и усложняет failover; server-side shared state обычно устойчивее.

## Health и lifecycle

Liveness target-а не равна readiness обслужить новый traffic. Passive health видит реальные failures; active probe должна проверять необходимые dependencies, но не создавать cascade. При deploy: mark unready → прекратить новые connections/requests → drain in-flight до deadline → close. Keep-alive, LB deregistration delay и application shutdown согласуются.

L7 retry опасен для streaming/mutations и усиливает load; он должен знать idempotency, retryable condition и общий budget. Проксируемые `Forwarded`/`X-Forwarded-*` очищайте на public edge и доверяйте только известным hops, особенно для client IP/scheme/security policy.

## Failure modes

Load balancer не создаёт capacity: при перегрузке всех targets нужна admission/load shedding. Control-plane update, stale discovery, uneven connection age, DNS cache, NAT/port limits и correlated zone failure должны иметь metrics и rehearsal.

См. [load balancing](../../system-design/fundamentals/load-balancing.md), [retries](../../backend-patterns/retries.md) и [Kubernetes Service/Ingress](../../containers/kubernetes/networking.md).

