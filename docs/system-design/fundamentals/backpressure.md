---
title: Backpressure в System Design
description: Bounded queues, flow control и overload propagation.
tags: [system-design, reliability]
updated: 2026-09-10
---

# Backpressure в System Design

Для каждого asynchronous/synchronous boundary сравните arrival и service rate. Если producer быстрее надолго, никакой конечный buffer не решает проблему.

## Mechanisms

- bounded in-memory queue + block/reject;
- pull-based consumption и explicit credits;
- HTTP/gRPC concurrency limits;
- broker quota/producer throttling;
- pause/resume Kafka partitions при заполненном worker pool;
- durable queue с size/age quota и admission control.

Размер buffer определяется допустимым queue latency и burst, не свободной RAM. Little's Law связывает average in-flight, throughput и time; oldest item age часто важнее depth.

## Propagation

Downstream saturation должен дойти до origin как slower send, `429/503`, reduced concurrency или stopped intake. Если request нельзя принять, не подтверждайте его до durable enqueue. Если client неконтролируем, добавьте load shedding/rate limit.

Проверьте shutdown и cancellation: заблокированный producer должен разблокироваться по context, consumers — drain только в bounded срок. Dead-letter queue не является бесконечным overflow buffer.

Наблюдайте queue depth/age, enqueue wait/reject, processing rate, in-flight, downstream latency и dropped/expired work. Подробнее: [backpressure pattern](../../backend-patterns/backpressure.md).
