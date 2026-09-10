---
title: HTTP server
description: Production timeouts, limits и connection lifecycle HTTP-сервера Go.
tags:
  - go
  - http
  - production
updated: 2026-09-10
---

# HTTP server

Не используйте `http.ListenAndServe` с implicit zero-value server в public service: задайте timeouts и limits явно.

```go
server := &http.Server{
    Addr:              ":8080",
    Handler:           routes,
    ReadHeaderTimeout: 5 * time.Second,
    ReadTimeout:       15 * time.Second,
    WriteTimeout:      30 * time.Second,
    IdleTimeout:       90 * time.Second,
    MaxHeaderBytes:    1 << 20,
}
```

Значения — пример, не универсальная конфигурация. Они должны учитывать upload/streaming endpoints, proxy deadlines и SLO.

## Timeouts

- `ReadHeaderTimeout` ограничивает чтение headers и защищает от slow clients.
- `ReadTimeout` охватывает чтение всего request, включая body; может быть слишком грубым для uploads.
- `WriteTimeout` ограничивает response write lifecycle, но semantics зависят от protocol и streaming.
- `IdleTimeout` ограничивает ожидание следующего keep-alive request.

Per-handler work ограничивайте request context/deadline. Для body size используйте `MaxBytesReader`; server timeouts не являются size limits.

## Connection state и overload

Server не предоставляет полноценный admission control из коробки. Ограничивайте expensive work/semaphores, connection count на proxy/OS level и наблюдайте active connections, requests, handler concurrency и rejection rate.

TLS/HTTP2 settings и `Server.Protocols` зависят от supported clients. Не отключайте protocol только ради workaround без измерения и upgrade plan.

## Источники

- [`http.Server`](https://pkg.go.dev/net/http#Server)
- [Go issue/wiki: HTTP server timeouts](https://pkg.go.dev/net/http)
