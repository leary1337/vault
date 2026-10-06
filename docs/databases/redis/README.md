---
title: Redis
description: Команды в памяти, кэш, сохранение на диск и работа копий Redis.
tags: [databases, redis]
updated: 2026-10-06
---

# Redis

Redis хранит данные преимущественно в оперативной памяти и предоставляет команды для счётчиков, объектов, множеств и очередей. Материалы ориентированы на Redis Open Source 8.10.2.

Для восстанавливаемого кэша потеря ключа может быть обычным промахом. Для сессии она разлогинит пользователя. Для единственной записи оплаты потеря недопустима. Поэтому сначала определите роль данных, затем выберите сохранение на диск, репликацию и политику удаления при заполнении.

[Структуры данных](data-structures.md) объясняют операции, [кэш](caching.md) — загрузку и гонки, [Сохранение Redis на диск](persistence.md) — перезапуск, [репликация](replication.md), [Sentinel](sentinel.md) и [Cluster](cluster.md) — копии и отказы. Большое значение или долгий скрипт всё ещё может задержать другие команды: скорость зависит от объёма работы.

## Темы

- [Истечение срока и вытеснение ключей](expiration-and-eviction.md)
- [Горячие и большие ключи](hot-keys.md)
- [Сохранение Redis на диск](persistence.md)
- [Redis Cluster](cluster.md)
- [Redis Sentinel](sentinel.md)
- [Кэширование с Redis](caching.md)
- [Распределённые блокировки Redis](distributed-locks.md)
- [Репликация Redis](replication.md)
- [Структуры данных Redis](data-structures.md)

## Источники

- [Redis Open Source documentation](https://redis.io/docs/latest/operate/oss_and_stack/)
- [Redis 8.10 release notes](https://redis.io/docs/latest/operate/oss_and_stack/stack-with-enterprise/release-notes/redisce/redisos-8.10-release-notes/)

- [Архив опубликованных Redis releases: 8.10.2 от 17 сентября 2026](https://download.redis.io/releases/)
