---
title: Load shedding
description: Ранний отказ от работы, которую система не успеет выполнить.
tags: [backend, patterns, reliability]
updated: 2026-10-06
---

# Load shedding


Load shedding — раннее отклонение лишней работы, чтобы уже принятая работа успела завершиться.

## Проблема

Когда arrival rate выше service rate, очередь растёт, latency (срок ответа) превышает deadlines, retries добавляют load и система падает каскадом.

## Как работает

Отклоняйте лишнюю работу как можно раньше по bounded (с явным конечным пределом) concurrency/queue, deadline (крайний срок завершения) feasibility, priority и текущей saturation (насыщение ресурса и образование очереди). Adaptive concurrency меняет limit по latency/queue feedback. Requests с уже истёкшим deadline не должны занимать downstream.

## Гарантии и границы

Shedding сохраняет ресурсы для принятой/приоритетной работы и ограничивает queueing latency. Он явно снижает success rate; правильный результат — controlled partial availability (доступность заявленной операции), а не отсутствие ошибок.

## Ошибки и отказы

- слишком поздний reject после дорогого parse/auth/DB call;
- все replicas решают одинаково и oscillate;
- health/readiness probes shed-ятся и вызывают restart storm;
- приоритет starvation-ит low class;
- clients немедленно retry-ят и возвращают load;
- stale saturation signal режет здоровый traffic.

## Компромиссы

Нужно выбрать admission signal и fairness. Короткая queue поглощает microburst, длинная скрывает overload. Local decision быстрый, но не знает global capacity.

## Когда не применять

Работу, которую нельзя потерять, принимайте только после durable enqueue с bounded producer backpressure; silent drop недопустим. Shedding не заменяет capacity и устранение bottleneck.

## Пример

API при заполнении 100 concurrent slots не ставит request в бесконечную очередь, а быстро возвращает `503` с bounded retry hint. Critical checkout получает reserved bulkhead, analytics shed-ится первой.

## Разобранный пример

При 1 000 запросов/с и среднем времени 100 ms ожидаем около 100 активных запросов. Зависимость замедлилась до 2 s: без ограничения их станет около 2 000. Лимит 150 не восстанавливает поставщика, зато ограничивает занятые слоты и позволяет быстро отказать остальным. Число 150 — учебный выбор, подтверждаемый нагрузочным тестом.

Возвращаем 503 для временной общей перегрузки, 429 для превышения квоты клиента. Отдельный резерв для управляющих операций предотвращает ситуацию, когда полный рабочий пул мешает самой диагностике. Если очередь содержит уже просроченную задачу, её пропускаем, а не выполняем бесполезный DB запрос.

## Источник механизма

[Google SRE: Handling Overload](https://sre.google/sre-book/handling-overload/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему отказ должен быть ранним?
2. Чем 429 отличается от 503?

<details>
<summary>Ориентиры для ответа</summary>

1. После дорогой работы ресурсы уже потрачены.
2. Квота клиента против временной недоступности/перегрузки сервиса.

</details>
