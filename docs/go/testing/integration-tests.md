---
title: Integration tests
description: Проверка реальных protocol и storage boundaries без flaky shared state.
tags:
  - go
  - testing
  - integration
updated: 2026-09-10
---

# Integration tests

Integration test проверяет взаимодействие с реальной implementation boundary: PostgreSQL, Redis, Kafka, filesystem, HTTP/gRPC server. Он нужен там, где fake не моделирует wire/schema/transaction semantics.

## Изоляция

- Используйте отдельную database/schema/topic/namespace на test run.
- Применяйте те же migrations, что production.
- Фиксируйте dependency image/version.
- Ждите readiness condition, а не sleep.
- Cleanup должен выполняться через `t.Cleanup`, даже после failure.
- Не полагайтесь на порядок tests и shared leftover state.

Parallelization ограничивайте capacity CI host и dependency. Failure report должен содержать seed, dependency logs/version и request correlation, но не secrets.

Отделяйте быстрый default suite от более дорогого integration suite build tag/CI job, однако запускайте оба как обязательные checks для затронутых boundaries.

## Источники

- [`testing` package](https://pkg.go.dev/testing)
- [Testcontainers for Go](https://golang.testcontainers.org/)
