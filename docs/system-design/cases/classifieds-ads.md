---
title: Classifieds ads
description: Lifecycle объявления, media, moderation, search и consistency.
tags: [system-design, cases, search]
updated: 2026-09-10
---

# Classifieds ads

## Requirements

Создать draft, загрузить photos, отправить на moderation, publish/pause/sell/expire; искать и фильтровать по category/location/price; открыть detail; связаться с seller. Уточнить paid promotion, fraud, geo, legal retention и freshness search.

## Domain model

Authoritative relational model хранит ad aggregate, owner, category attributes, price/currency, location, lifecycle version и media references. State machine запрещает переходы в обход moderation. Search document и caches — rebuildable projections.

## Write path

API authorizes seller и idempotently меняет draft → media upload service проверяет files → moderation workflow (automated/manual) → transaction публикует state + outbox → indexer строит search document → cache/CDN invalidation. Event содержит ad ID/version; projection игнорирует старую version.

## Read/search path

Search engine выполняет text/filter/geo/ranking и возвращает IDs + summary/version. Detail service batch/point читает authoritative/cache data и обязательно проверяет текущий status/visibility. Cursor содержит score/sort key + ID + query/index version.

## Scale

Partition primary data по ad/owner region согласно access и compliance. Category-specific attributes можно моделировать typed tables/JSON with validated schema; бесконтрольный EAV усложняет constraints/query planning. Images идут object storage/CDN, не через DB blobs.

## Failures и consistency

Index lag означает, что новый ad позже появится, а снятый может временно остаться candidate; final detail filter не позволяет открыть запрещённое. Outbox закрывает dual write, DLQ/reindex/reconciliation восстанавливают projection. Moderation/provider outage оставляет explicit pending, не публикует fail-open.

## Trade-offs/security

Denormalized search ускоряет discovery ценой eventual consistency. Real-time indexing дороже batch. Защитите contact data, rate-limit scraping/spam, проверяйте ownership/media/price changes, audit moderation. Метрики: publish-to-search age, stale candidate rate, moderation queue, zero-result/search p99 и fraud signals.
