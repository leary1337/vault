---
title: Backpressure
description: Передача сигнала saturation к производителю нагрузки.
tags: [backend, patterns, reliability]
updated: 2026-09-10
---

# Backpressure

## Problem

Producer создаёт работу быстрее consumer, backlog растёт без границ и переносит failure в memory, disk, latency или retention loss.

## Mechanism

Ограничьте buffer и заставьте upstream ждать, уменьшать скорость или получать явный rejection. Pull/credit protocols позволяют consumer объявлять capacity; bounded channel/semaphore ограничивает in-flight; queue задаёт quota и producer admission policy.

## Guarantees

Backpressure ограничивает накопление в выбранной границе и делает saturation видимой upstream. Он не уменьшает исходный спрос и не гарантирует, что upstream способен замедлиться.

## Failure modes

- «временная» unbounded queue заполняет RAM/disk;
- блокирующий send держит scarce request worker и создаёт deadlock;
- upstream игнорирует signal и retries;
- общий queue допускает noisy-neighbor starvation;
- backlog переживает retention/deadline и становится бесполезной работой;
- pipeline stage ограничен не там, где реальный bottleneck.

## Trade-offs

Блокирование сохраняет работу, но распространяет latency. Rejection сохраняет capacity, но требует retry/drop semantics. Buffer поглощает bursts, но увеличивает latency и memory; размер связан с service rate и допустимым queue time.

## When not to use

Если producer — внешний неконтролируемый client, используйте rate limiting/load shedding. Если событие обязано быть принято, durable queue и quota нужны до acknowledgement.

## Example

Go worker pool использует bounded channel. Handler делает non-blocking/timeout-aware enqueue; при заполнении возвращает `503` или сохраняет task в durable broker. Consumer публикует queue depth, oldest age и processing rate.
