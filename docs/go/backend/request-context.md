---
title: HTTP request context
description: Cancellation и deadline propagation через HTTP handlers и clients.
tags:
  - go
  - http
  - context
updated: 2026-09-10
---

# HTTP request context

`r.Context()` отменяется, когда client connection закрылась, request отменён (HTTP/2) или `ServeHTTP` вернулся. Handler должен передавать этот context в SQL, gRPC и downstream HTTP.

```go
func handler(w http.ResponseWriter, r *http.Request) {
    user, err := repo.Find(r.Context(), r.PathValue("id"))
    if err != nil {
        writeError(w, err)
        return
    }
    writeJSON(w, user)
}
```

Создавая child timeout, не увеличивайте parent deadline. Для outbound HTTP используйте `http.NewRequestWithContext`; для SQL — `QueryContext`/`ExecContext`.

Request-scoped values подходят для trace/request ID и verified principal. Dependencies передавайте явно. Detached post-response work должен иметь отдельный owner, queue limit и shutdown context; `context.WithoutCancel` сам по себе этого не создаёт.

## Источники

- [`http.Request.Context`](https://pkg.go.dev/net/http#Request.Context)
- [`context` package](https://pkg.go.dev/context)
