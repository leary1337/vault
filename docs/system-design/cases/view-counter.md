---
title: View counter
description: Exact vs approximate counts, dedup и hot-content scaling.
tags: [system-design, cases]
updated: 2026-09-10
---

# View counter

## Requirements

Считать page/video/ad views и показывать total. Сначала определить view: request, authenticated user/day, watch duration, bot-filtered impression? Нужны exact billing numbers или approximate social proof, и как быстро обновление видно?

## Alternatives

- atomic counter в DB/Redis: просто, но viral item — hot key;
- sharded counters `(content_id, shard)` с sum on read/materialization;
- append events в Kafka, stream aggregation и durable rollups;
- probabilistic distinct counter для unique users с известной ошибкой.

## Design

Edge/API валидирует event и stable impression ID → broker partitioned по content ID или hash → consumers deduplicate в bounded window → aggregate minute/hour buckets → query service складывает durable rollup + recent delta/cache.

Partition по content ID сохраняет order, но один viral content перегружает partition. Добавление random subshard распределяет writes, ценой merge и отсутствия единого order. Exact dedup требует хранить каждый impression ID; approximate Bloom/HLL уменьшают storage и добавляют error.

## Failures

At-least-once broker даёт duplicates, producer timeout — ambiguous acceptance, late events приходят после закрытия bucket. Определите lateness/watermark и correction path. Потеря cache не должна терять durable count; rebuild из retained events/rollups проверяется.

## Trade-offs

Для UI допускается eventual approximate count и batching. Для billing нужен immutable event/audit, строгая identity, reconciliation и часто отдельный pipeline. Не заставляйте один counter удовлетворять обеим semantics.

## Observability

Event acceptance/drop/duplicate rate, consumer lag, hot partitions, correction volume и расхождение raw sample с rollups.
