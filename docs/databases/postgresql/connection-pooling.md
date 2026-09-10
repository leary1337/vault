---
title: Connection pooling
description: Почему соединения дороги и чем отличаются session и transaction pooling.
tags: [databases, postgresql, operations]
updated: 2026-09-10
---

# Connection pooling

Каждому прямому client connection соответствует backend process с памятью и server state. Очень высокий `max_connections` увеличивает context switching и совокупную память; pool ограничивает реальную database concurrency и повторно использует connections.

## Два уровня pool

Application pool держит ограниченное число открытых connections на process/instance. Внешний pooler может multiplex-ить много clients на меньшее число PostgreSQL sessions.

- Session pooling закрепляет server connection за client session; совместим почти со всеми session features, но multiplexing слабее.
- Transaction pooling выдаёт server connection только на время transaction; лучше multiplexing, но session state между transactions нельзя считать закреплённым.

При transaction pooling осторожны `SET` без `LOCAL`, temporary tables, session advisory locks, `LISTEN/NOTIFY`, prepared statements и другие session-scoped features — точная поддержка зависит от pooler/version/configuration.

## Настройка

Размер pool — capacity decision, а не «число CPU × магическая константа». Ограничения задают:

- допустимая active concurrency базы;
- latency и время transaction;
- число application replicas и фоновых workers;
- reserved connections для admin/migrations;
- downstream I/O и lock contention.

Суммируйте максимумы всех instances: pool 50 у 40 pods означает до 2000 connections. Небольшая bounded queue обычно лучше неограниченного открытия connections.

## Timeouts и lifecycle

Различайте timeout ожидания connection в pool, connect timeout, statement/lock timeout и context deadline запроса. При отмене SQL driver должен отправить cancel и дождаться/закрыть connection так, чтобы следующий borrower не получил незавершённый protocol state.

Наблюдайте active/idle/waiting clients, acquisition latency, connection churn, `pg_stat_activity`, transaction duration и database saturation. Pool скрывает connection setup, но не создаёт дополнительную CPU/I/O capacity.

## Источники

- [PostgreSQL server architecture](https://www.postgresql.org/docs/18/tutorial-arch.html)
- [Connections and authentication settings](https://www.postgresql.org/docs/18/runtime-config-connection.html)
- [The statistics collector](https://www.postgresql.org/docs/18/monitoring-stats.html)
