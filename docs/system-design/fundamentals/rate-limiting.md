---
title: Rate limiting в System Design
description: Scope, algorithm, placement и distributed state.
tags: [system-design, reliability]
updated: 2026-10-06
---

# Rate limiting в System Design

Лимит задаёт, кто сколько работы может начать за время; concurrency задаёт, сколько одновременно выполняется.

Сначала определите цель: abuse prevention, fair use, cost control или защита capacity. Один limiter редко решает все четыре.

## Scope и placement

Limit key может включать tenant, user, token, IP, endpoint и weighted cost. Edge limiter отсекает раньше, service limiter знает business cost, dependency limiter защищает downstream. Нужны global и per-tenant layers, чтобы множество малых clients не превысило total capacity.

Token bucket допускает controlled burst; sliding window точнее у границ; concurrency limiter лучше отражает дорогие длительные requests. Local state быстро, но effective global limit умножается на replicas; central atomic store точнее и добавляет dependency/latency. Token leasing даёт bounded (с явным конечным пределом) overshoot.

## Контракт

Верните `429`, machine-readable reason, limit/reset metadata и `Retry-After`, не раскрывая sensitive quotas. Решите fail-open/fail-closed при store outage. TTL/cardinality limiter keys ограничивают memory.

Load test включает synchronized burst, clock skew, hot tenant, failover limiter store и client retries. Наблюдайте allowed/rejected по scope, store latency/errors и downstream saturation (насыщение ресурса и образование очереди). Подробнее: [rate-limiting pattern](../../backend-patterns/rate-limiting.md).

## На конкретном примере

Для tenant 100 requests/s с capacity=200 получаем разрешённый burst. Если запрос длится 5 s, средняя concurrency около 500; отдельный лимит 100 active jobs защитит ресурс лучше QPS (число запросов в секунду). Большой search cost=20 отличаем от GET cost=1.

При 50 узлах local bucket 100/s даёт до 5 000/s этому tenant при распределении запросов. Для общей точности выбираем атомарную общую власть или распределяем зарезервированные порции. Fail-open при outage допускает больше работы; fail-closed делает limiter dependency доступности.

## Источник механизма

[RFC 6585: 429](https://www.rfc-editor.org/rfc/rfc6585.html#section-4). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Что защищает от медленных запросов?
2. Почему fail-open надо ограничить?

<details>
<summary>Ориентиры для ответа</summary>

1. Concurrency limit плюс deadline (крайний срок завершения).
2. Без аварийного локального потолка отказ limiter превращается в перегрузку API.

</details>
