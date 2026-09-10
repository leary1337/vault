---
title: HTTP testing
description: Handler, middleware и client integration tests через httptest.
tags:
  - go
  - testing
  - http
updated: 2026-09-10
---

# HTTP testing

Для isolated handler test используйте `httptest.NewRequest` и `NewRecorder`:

```go
req := httptest.NewRequest(http.MethodGet, "/users/42", nil)
rec := httptest.NewRecorder()
handler.ServeHTTP(rec, req)

res := rec.Result()
defer res.Body.Close()
if res.StatusCode != http.StatusOK { t.Fatalf("status = %d", res.StatusCode) }
```

Проверяйте status, headers и decoded semantic body, а не byte formatting JSON. Middleware chain и routing должны тестироваться собранным production router.

Для connection/TLS/streaming behavior нужен test server. В Go 1.27 `httptest.NewTestServer(t, handler)` по умолчанию использует in-memory network, совместимую с `testing/synctest`; классические `NewServer`/`NewTLSServer` используют loopback и требуют `Close`.

Не подменяйте real client retry/timeout test вызовом handler напрямую: Transport lifecycle, body close и cancellation проверяются на network boundary.

## Источники

- [`net/http/httptest`](https://pkg.go.dev/net/http/httptest)
- [`testing/synctest`](https://pkg.go.dev/testing/synctest)
