---
title: Redis Cluster
description: Hash slots, client redirects, resharding и consistency trade-offs.
tags: [databases, redis, cluster]
updated: 2026-09-10
---

# Redis Cluster

Redis Cluster распределяет keyspace между primary nodes и выполняет failover их replicas. Он использует 16 384 hash slots: `CRC16(key) mod 16384`. Cluster-aware client хранит mapping slot → node и обрабатывает redirects.

## Routing и hash tags

`MOVED` сообщает постоянного владельца slot и обычно служит поводом обновить topology. `ASK` временно направляет command во время migration и требует сначала послать `ASKING` target node.

Multi-key command, transaction или Lua script обычно требует, чтобы все keys находились в одном slot. Hash tag заставляет хэшировать только содержимое `{...}`:

```text
cart:{user-42}
cart-items:{user-42}
```

Tags возвращают atomic multi-key operations, но чрезмерное объединение создаёт hot slot и мешает равномерному sharding.

## Availability и consistency

Replicas получают данные asynchronously. При failover возможно потерять acknowledged writes; в minority partition окно риска больше. Cluster прекращает обслуживание, если недоступно достаточно primary slots/majority для failover согласно configuration — это осознанный trade-off, а не linearizable consensus database.

Чтение с replicas требует явного opt-in клиента и допускает staleness. `WAIT` уменьшает риск, но не делает Cluster strongly consistent.

## Resharding

Slots можно переносить online между nodes. Во время migration clients должны корректно обрабатывать `ASK`/`MOVED`, а network и обе стороны — выдерживать traffic копирования. Большой key делает миграцию одного slot долгой и увеличивает pause/timeout risk.

Планируйте:

- минимум три primary для осмысленного sharding/majority и replicas в независимых zones;
- cluster bus connectivity и корректные announced addresses;
- равномерность slots, bytes, commands и hot keys — count slots сам по себе не отражает load;
- backup/restore, failover и rolling upgrade отдельно.

Cluster поддерживает только database 0; namespace задавайте prefixes/ACL, а не `SELECT` databases.

## Источники

- [Scale with Redis Cluster](https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/)
- [Redis Cluster specification](https://redis.io/docs/latest/operate/oss_and_stack/reference/cluster-spec/)
