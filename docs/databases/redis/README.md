---
title: Redis
description: Data structures, caching, durability и high availability Redis.
tags: [databases, redis]
updated: 2026-09-10
---

# Redis

Redis — in-memory data store с атомарными командами, богатыми структурами данных, expiration, persistence и replication. Раздел ориентирован на Redis Open Source 8.10.1; сначала изучите [структуры](data-structures.md), [кэширование](caching.md) и [управление памятью](expiration-and-eviction.md), затем durability/HA и Cluster.

Перед выбором Redis зафиксируйте роль данных:

- воспроизводимый cache допускает eviction и потерю;
- session/rate-limit state требует определённых failure semantics;
- system of record требует отдельно доказанной durability, backup и consistency модели.

Быстрая команда не означает быстрый запрос любого размера: большие collections, replies, Lua/function execution и массовые operations могут блокировать обработку других клиентов. Проверяйте command complexity и ограничивайте объём работы.

## Источники

- [Redis Open Source documentation](https://redis.io/docs/latest/operate/oss_and_stack/)
- [Redis 8.10 release notes](https://redis.io/docs/latest/operate/oss_and_stack/stack-with-enterprise/release-notes/redisce/redisos-8.10-release-notes/)
