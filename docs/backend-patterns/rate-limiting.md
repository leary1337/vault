---
title: Rate limiting
description: Ограничение частоты запросов по справедливому scope.
tags: [backend, patterns, reliability]
updated: 2026-10-06
---

# Rate limiting


Rate limiting ограничивает скорость принятия действий по конкретному клиенту/правилу.

## Проблема

Один client или общий burst превышает fair-use, cost или capacity budget и ухудшает сервис для остальных.

## Как работает

- Token bucket накапливает tokens с заданной скоростью и допускает burst до capacity.
- Leaky bucket/queue сглаживает output rate, но добавляет ожидание.
- Fixed window прост, но допускает двойной burst на границе.
- Sliding log точен и дорог; sliding-window counter аппроксимирует дешевле.

Key limiter включает tenant/user/API/region согласно fairness. Distributed limiter обновляет state атомарно и задаёт поведение при store outage.

## Гарантии и границы

Limiter ограничивает принятую частоту в выбранном scope и модели времени. Он не гарантирует, что разрешённые requests дешёвые или downstream выдержит их concurrency.

## Ошибки и отказы

- NAT/IP grouping блокирует разных users;
- cardinality (число разных значений или временных рядов) keys съедает memory;
- clock skew/window edges дают burst;
- central store становится bottleneck;
- fail-open допускает overload/abuse, fail-closed создаёт outage;
- retries клиентов игнорируют `Retry-After`.

## Компромиссы

Local limiter быстрый, но global rate примерно умножается на instances. Central limiter точнее, но добавляет latency/dependency. Leasing token batches узлам уменьшает calls ценой temporary overshoot.

## Когда не применять

Для защиты от внутренней saturation (насыщение ресурса и образование очереди) важнее concurrency limit/load shedding. Rate limit по request count не подходит, если стоимость requests отличается на порядки — используйте weighted units.

## Пример

Token bucket: 100 requests/s, burst 200 на tenant. При отказе верните `429 Too Many Requests` и осмысленный `Retry-After`; отдельно ограничьте anonymous/global traffic.

## Источники

- [RFC 6585: 429 Too Many Requests](https://www.rfc-editor.org/rfc/rfc6585.html#section-4)

## Разобранный пример

Fixed window 100/minute разрешит 100 запросов в 12:00:59 и ещё 100 в 12:01:00. Это 200 за две секунды без нарушения каждой отдельной минуты. Token bucket с rate=100/min и capacity=100 разрешает разовый запас, затем выдаёт токены постепенно.

При дорогих операциях считаем единицы стоимости: простой GET=1, большой поиск=20. Cost выше capacity никогда не разрешится, поэтому это ошибка политики. Для Redis atomic script все участвующие ключи должны удовлетворять требованиям размещения выбранной topology; multi-key операция через разные cluster slots не становится атомарной от слова Lua. Подробная арифметика: [distributed limiter](../system-design/cases/rate-limiter.md).

## Проверь себя

1. Почему fixed window даёт двойной burst?
2. Почему QPS (число запросов в секунду) недостаточно для защиты БД?

<details>
<summary>Ориентиры для ответа</summary>

1. Счётчик сбрасывается на границе, два запаса тратятся подряд.
2. Стоимость и длительность запросов различаются.

</details>
