---
title: Testcontainers for Go
description: Управление disposable dependencies в integration tests.
tags:
  - go
  - testing
  - containers
updated: 2026-09-10
---

# Testcontainers for Go

Testcontainers запускает real dependency image из Go test. Это third-party library, не standard library. Используйте module-specific `Run` API и pinned image tag, а не `latest`.

```go
ctr, err := postgres.Run(ctx,
    "postgres:17-alpine",
    postgres.WithDatabase("app"),
    postgres.WithUsername("app"),
    postgres.WithPassword("test-only"),
    postgres.BasicWaitStrategies(),
)
if err != nil { t.Fatal(err) }
testcontainers.CleanupContainer(t, ctr)
```

После readiness примените production migrations. Container start дорогой: один suite container + isolated schemas/snapshots может ускорить tests, но не допускайте state leakage. В CI учитывайте Docker availability, image registry failures, architecture и logs/artifacts.

Не используйте deprecated `RunContainer`; API/version сверяйте при upgrade dependency.

## Источники

- [Testcontainers for Go quickstart](https://golang.testcontainers.org/quickstart/)
- [PostgreSQL module](https://golang.testcontainers.org/modules/postgres/)
