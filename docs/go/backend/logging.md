---
title: Structured logging в Go
description: slog, ownership логирования, PII и управление cardinality/volume.
tags:
  - go
  - logging
  - observability
updated: 2026-09-10
---

# Structured logging в Go

`log/slog` записывает message + typed attributes. Logger передавайте как dependency; context version нужна для handler, которому важны context data/cancellation.

```go
logger.InfoContext(ctx, "request completed",
    "method", r.Method,
    "route", routeTemplate,
    "status", status,
    "duration_ms", duration.Milliseconds(),
)
```

Используйте route template, а не raw path/user ID как metric label; в logs high-cardinality values допустимы только при privacy/cost policy. Секреты, tokens, passwords и raw payloads не логируются. PII требует redaction, retention и access control.

Error обычно логируется один раз на boundary с operation, request/trace ID и outcome. Нижние слои wrapping-ят и возвращают error. Sampling применяйте к повторяющимся non-audit events; security/audit logs имеют отдельные гарантии доставки и integrity.

## Источники

- [`log/slog`](https://pkg.go.dev/log/slog)
- [Go blog: Structured Logging with slog](https://go.dev/blog/slog)
