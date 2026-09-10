---
title: Favorites
description: Идемпотентная user-item связь, listings и counters.
tags: [system-design, cases]
updated: 2026-09-10
---

# Favorites

## Requirements

Добавить/удалить item из favorites, проверить состояние, вывести список с pagination и optional count. Уточнить privacy, ordering, item deletion, folders/tags и read-after-write.

## API и model

Идемпотентный resource contract:

```text
PUT    /users/{u}/favorites/{item}
DELETE /users/{u}/favorites/{item}
GET    /users/{u}/favorites?cursor=...
```

Table `favorites(user_id, item_id, created_at)` имеет primary/unique `(user_id, item_id)` и index для listing `(user_id, created_at DESC, item_id DESC)`. Server берёт user из authenticated subject, не доверяет path без authorization.

## Paths

Write использует `INSERT ... ON CONFLICT DO NOTHING`/`DELETE`, затем outbox обновляет derived total/recommendations. Read keyset-страничит relation и batch hydrate-ит current item data, фильтруя deleted/inaccessible items.

## Scale

Shard по `user_id` для основного listing. Reverse query «сколько users добавили item» требует отдельного index/aggregate и может быть hot для popular item. Exact synchronous counter создаёт contention; eventual sharded counter обычно достаточен для UI.

## Failures

Retry PUT/DELETE безопасен по resource semantics. Crash после DB commit до event закрывает outbox. Item deletion оставляет tombstone/async cleanup; read path не должен показывать его из stale cache. Reconciliation пересчитывает derived counts.

## Trade-offs

Strong read-after-write направляет session на primary/минимальную version, eventual replica/cache дешевле. Хранить snapshot item в favorite ускоряет read, но создаёт stale duplication; чаще hydrate authoritative item.

## Observability/security

Write conflict/error, listing p99, hydrate miss, projection lag и cleanup backlog. Favorites — пользовательские данные: export/delete/retention и access audit входят в design.
