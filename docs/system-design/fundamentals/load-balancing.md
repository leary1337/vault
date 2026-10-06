---
title: Load balancing
description: L4/L7 routing, health, affinity и overload behavior.
tags: [system-design, networking]
updated: 2026-10-06
---

# Load balancing

Балансировщик распределяет работу между готовыми узлами, но не увеличивает их суммарную мощность.

Load balancer распределяет connections/requests между eligible backends. Он не создаёт capacity и может скрыть перегрузку одного shard/tenant за средними метриками.

## L4 и L7

L4 маршрутизирует transport flows по address/port, сохраняет protocol transparency и обычно дешевле. L7 понимает HTTP/gRPC metadata, умеет route по host/path/header, terminate TLS, retry и enforce policy, но становится частью application semantics.

Algorithms: round-robin прост; least-connections полезен при разной duration, но число connections не равно active work при multiplexing; weighted routing отражает capacity; consistent/rendezvous hashing даёт affinity и снижает churn.

## Health и draining

Liveness (способность продолжать продвижение; у probe — жив ли процесс) отвечает «процесс жив», readiness (готовность принять новую работу) — «можно дать новую работу». Probe должен проверять критическую способность без cascade от необязательной dependency. При rollout backend сначала становится unready, прекращает новые requests и bounded (с явным конечным пределом) время drain-ит keep-alive/streams.

Session affinity упрощает local state, но ухудшает rebalance/failover; durable session храните вне instance. Connection pools/HTTP2 streams могут удерживать traffic после изменения weights, поэтому наблюдайте request-level distribution.

## Failure behavior

Retry на proxy может повторить non-idempotent (без второго эффекта при повторе одного намерения) request после ambiguous upstream outcome. Ограничьте per-try/overall timeout, retry budget и replayable body. Outlier ejection/circuit breaking требуют minimum samples и half-open recovery.

Смотрите end-to-end latency (срок ответа), backend saturation (насыщение ресурса и образование очереди), active requests, queue, errors по reason, retries и imbalance. Подробнее: [networking](../../networking/README.md).

## На конкретном примере

HTTP/2 позволяет много requests на одном connection. Least-connections может считать один перегруженный stream-канал легче ста idle connections. Поэтому для request-level нагрузки выбираем сигнал активных запросов/очереди и измеряем распределение.

При rollout узел становится unready, ждёт распространения маршрута и ограниченно завершает запросы. Старое keep-alive соединение/stream может оставаться открытым: правило прекращения новых вызовов зависит от протокола. Proxy retry безопасен только при повторяемом теле, budget и идемпотентном contract (договорённость о поведении и гарантиях). Повтор POST после потерянного ответа может создать второй ad.

## Источник механизма

[HTTP/2 streams](https://www.rfc-editor.org/rfc/rfc9113.html). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему число connections не равно числу запросов?
2. Почему readiness не заменяет drain (завершение уже принятой работы)?

<details>
<summary>Ориентиры для ответа</summary>

1. Соединения могут быть idle или мультиплексировать streams.
2. Маршрутизация обновляется не мгновенно, уже существующие запросы продолжаются.

</details>
