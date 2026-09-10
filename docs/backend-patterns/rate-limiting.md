---
title: Rate limiting
description: Ограничение частоты запросов по справедливому scope.
tags: [backend, patterns, reliability]
updated: 2026-09-10
---

# Rate limiting

## Problem

Один client или общий burst превышает fair-use, cost или capacity budget и ухудшает сервис для остальных.

## Mechanism

- Token bucket накапливает tokens с заданной скоростью и допускает burst до capacity.
- Leaky bucket/queue сглаживает output rate, но добавляет ожидание.
- Fixed window прост, но допускает двойной burst на границе.
- Sliding log точен и дорог; sliding-window counter аппроксимирует дешевле.

Key limiter включает tenant/user/API/region согласно fairness. Distributed limiter обновляет state атомарно и задаёт поведение при store outage.

## Guarantees

Limiter ограничивает принятую частоту в выбранном scope и модели времени. Он не гарантирует, что разрешённые requests дешёвые или downstream выдержит их concurrency.

## Failure modes

- NAT/IP grouping блокирует разных users;
- cardinality keys съедает memory;
- clock skew/window edges дают burst;
- central store становится bottleneck;
- fail-open допускает overload/abuse, fail-closed создаёт outage;
- retries клиентов игнорируют `Retry-After`.

## Trade-offs

Local limiter быстрый, но global rate примерно умножается на instances. Central limiter точнее, но добавляет latency/dependency. Leasing token batches узлам уменьшает calls ценой temporary overshoot.

## When not to use

Для защиты от внутренней saturation важнее concurrency limit/load shedding. Rate limit по request count не подходит, если стоимость requests отличается на порядки — используйте weighted units.

## Example

Token bucket: 100 requests/s, burst 200 на tenant. При отказе верните `429 Too Many Requests` и осмысленный `Retry-After`; отдельно ограничьте anonymous/global traffic.

## Источники

- [RFC 6585: 429 Too Many Requests](https://www.rfc-editor.org/rfc/rfc6585.html#section-4)
