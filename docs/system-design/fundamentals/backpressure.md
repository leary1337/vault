---
title: Backpressure в System Design
description: Bounded queues, flow control и overload propagation.
tags: [system-design, reliability]
updated: 2026-10-06
---

# Backpressure в System Design

Если обработчик не успевает, скорость производителя должна уменьшиться либо лишняя работа должна получить отказ.

Для каждого asynchronous/synchronous boundary сравните arrival и service rate. Если producer быстрее надолго, никакой конечный buffer не решает проблему.

## Механизмы

- bounded (с явным конечным пределом) in-memory queue + block/reject;
- pull-based consumption и explicit credits;
- HTTP/gRPC concurrency limits;
- broker quota/producer throttling;
- pause/resume Kafka partitions при заполненном worker pool;
- durable queue с size/age quota и admission control.

Размер buffer определяется допустимым queue latency (срок ответа) и burst, не свободной RAM. Little's Law связывает average in-flight, throughput (скорость успешной обработки) и time; oldest item age часто важнее depth.

## Передача сигнала

Downstream saturation (насыщение ресурса и образование очереди) должен дойти до origin как slower send, `429/503`, reduced concurrency или stopped intake. Если request нельзя принять, не подтверждайте его до durable enqueue. Если client неконтролируем, добавьте load shedding/rate limit.

Проверьте shutdown и cancellation: заблокированный producer должен разблокироваться по context, consumers — drain (завершение уже принятой работы) только в bounded срок. Dead-letter queue не является бесконечным overflow buffer.

Наблюдайте queue depth/age, enqueue wait/reject, processing rate, in-flight, downstream latency и dropped/expired work. Подробнее: [backpressure pattern](../../backend-patterns/backpressure.md).

## На конкретном примере

Вход 1 200 jobs/s, обработка 1 000/s: backlog (накопившаяся необработанная работа) растёт на 200/s. Запас 10 000 jobs заполнится за 50 s. После двух минут сбоя backlog=144 000; при восстановлении обработчик 1 500/s и вход 1 200/s догонит за 480 s, не за время одного job.

Важно измерять возраст очереди: 10 000 старых задач со сроком 30 s могут уже быть бесполезны. Пауза чтения Kafka partitions ограничивает местную RAM, но не останавливает общий рост retained log; нужен quota/retention и admission у производителя.

## Источник механизма

[Google SRE: Handling Overload](https://sre.google/sre-book/handling-overload/). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Как посчитать время заполнения?
2. Почему после восстановления backlog может не исчезнуть?

<details>
<summary>Ориентиры для ответа</summary>

1. Размер свободной очереди разделить на разницу входной и обработанной скорости.
2. Если service rate не выше текущего входа, запас не уменьшается.

</details>
