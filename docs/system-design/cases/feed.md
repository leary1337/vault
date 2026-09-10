---
title: Feed
description: Fan-out, ranking, pagination и privacy changes.
tags: [system-design, cases]
updated: 2026-09-10
---

# Feed

## Requirements

Показать posts от подписок/рекомендаций с ranking, cursor pagination, privacy/delete и freshness. Уточнить chronological vs ranked, follow graph scale, celebrity accounts, ads, read history и consistency после unfollow/delete.

## Fan-out alternatives

- Fan-out on write: при publish вставить post ID в inbox каждого follower. Read быстрый, write amplification огромен у celebrities, delete/privacy требуют массовой correction.
- Fan-out on read: запрос собирает recent posts followees и rank-ит. Writes дешёвые, reads fan-out/merge дорогие.
- Hybrid: обычные authors push, celebrities pull и merge при read.

## Architecture

Post service commit-ит content + outbox. Fan-out workers обновляют per-user feed candidates idempotently. Read service получает candidates, фильтрует текущую visibility/block/delete, hydrate-ит posts, rank-ит и возвращает opaque cursor с ranking/version context.

Feed cache хранит IDs/score, не копии всей сущности. Source posts и graph остаются authoritative. Final visibility check нужен, потому что асинхронная projection отстаёт.

## Pagination и ranking

Offset нестабилен при новых posts. Cursor содержит score/time + unique ID и, для reproducibility, model/session epoch. Строго стабильная страница конфликтует со свежестью; выберите snapshot-like session или разрешите controlled duplicates/gaps.

## Failures/scale

At-least-once fan-out создаёт duplicate candidate — unique `(user, post)`/version. Queue lag ухудшает freshness, но не должен ломать publish. Celebrity event разделяется на batches с checkpoints/backpressure. Rebuild feed из post log/follow graph должен быть возможен.

## Trade-offs

Precompute снижает read latency ценой storage/write. Online ranking свежее и дороже. Наблюдайте publish-to-visible latency, candidate/hydration misses, fan-out lag, hot authors и privacy correction time.
