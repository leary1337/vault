---
title: Search autocomplete
description: Prefix index, ranking, freshness и abuse-resistant suggestions.
tags: [system-design, cases, search]
updated: 2026-09-10
---

# Search autocomplete

## Requirements

Вернуть top suggestions по prefix за десятки миллисекунд, с locale, typo/personalization и freshness. Уточнить corpus, QPS per keystroke, minimum prefix, unsafe terms, deletion/privacy и ranking signals.

## Data pipeline

Query/click/catalog events поступают в stream; batch/stream jobs normalize-ят text, aggregate counts, фильтруют abuse и строят versioned prefix → top-K artifact. Build публикуется атомарно через manifest/version; nodes загружают новый immutable index и держат предыдущий для rollback.

## Serving structures

- trie/FST хорошо разделяет prefixes и сжимает sorted lexicon;
- key-value `locale:prefix → top K` даёт простой lookup, но materialize-ит много prefixes;
- search engine completion index поддерживает richer analysis ценой отдельного cluster.

Держите top K на node/local cache; не сканируйте full corpus per keystroke. Shard по locale/first normalized symbols, учитывая skew пустых/коротких prefixes.

## Ranking

Score сочетает popularity decay, business quality, locale/context и optional user history. Персонализацию лучше merge-ить из малого user candidate set, чтобы не материализовать index на каждого user. Stable tie-breaker делает results детерминированными.

## Freshness и failures

Base index обновляется batch, realtime delta добавляет тренды; merge ограничивает размер delta и допускает fallback на base. Failed build не должен заменить healthy version. Cache key включает index/model version.

## Security/quality

Не показывайте редкие private queries, PII и banned suggestions. Rate limit per user/IP, minimum prefix и server debounce снижают enumeration/QPS. Наблюдайте p99, zero-result, click-through, index age/load failures и distribution prefixes.

## Trade-offs

Больше freshness/personalization повышает cost и privacy risk. Typo tolerance на очень коротком prefix резко расширяет candidates; часто её включают позже.
