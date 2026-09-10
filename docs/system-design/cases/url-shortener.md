---
title: URL shortener
description: Проектирование коротких ссылок, redirects и abuse controls.
tags: [system-design, cases]
updated: 2026-09-10
---

# URL shortener

## Requirements

Создать short code для valid destination, быстро redirect-ить, поддержать expiry/revoke и optional custom alias. Уточнить redirect status (`301` cache-ится агрессивно, `302/307` позволяет менять target), privacy, click analytics и abuse/takedown.

## Capacity

Read/write ratio обычно высокий. Оцените links/day × retention × bytes и peak redirect QPS; hot viral code важнее average. Redirect p99 и availability — primary SLO, analytics может отставать.

## Model и API

`links(code PK, owner, destination, created_at, expires_at, status, version)`. `POST /links` принимает idempotency key; `GET /{code}` возвращает redirect; revoke — conditional update. Не позволяйте open redirect использовать внутренние/private schemes/addresses без policy.

## Code generation alternatives

- random Base62: decentralized, collision проверяется unique insert; длина задаёт пространство и enumeration risk;
- sequence/Snowflake → Base62: нет collision, но коды предсказуемы и нужен ID allocation;
- hash URL: одинаковый URL может давать один code, но collisions, ownership и mutable options усложняют contract.

## Paths

Write валидирует → генерирует code → authoritative DB commit → cache fill/invalidate. Read edge/service проверяет cache → DB → status/expiry → redirect. Click event публикуется asynchronous с sampling/idempotency; не блокирует redirect.

## Scale и failures

Cache-aside защищает DB, local/CDN cache — hot codes; revoke требует короткого max-stale или versioned purge. Shard по code hash, но custom aliases требуют той же unique authority. При cache outage ограничьте DB concurrency. DB failover должен сохранять confirmed creations; ambiguous create возвращается по idempotency key.

## Trade-offs

Longer code уменьшает collision, но хуже UX. Strong revoke снижает cacheability. Exact click counter дороже event log/approximate analytics. Не храните секретный access control только в непредсказуемости URL.
