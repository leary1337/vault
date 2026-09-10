---
title: net/http
description: Request lifecycle, handlers, middleware, bodies и streaming в net/http.
tags:
  - go
  - http
updated: 2026-09-10
---

# `net/http`

Server принимает connection, читает request, выбирает handler через `ServeMux` и вызывает `ServeHTTP(ResponseWriter, *Request)`. Handler должен завершить работу при cancellation и не сохранять `ResponseWriter` после return.

```go
type Handler interface {
    ServeHTTP(http.ResponseWriter, *http.Request)
}
```

`HandlerFunc` адаптирует function. Current `ServeMux` поддерживает method/host/path patterns; более специфичный pattern выигрывает, конфликтующие patterns могут вызвать panic при registration.

## Middleware

Middleware оборачивает handler и отвечает за одну boundary-задачу: recovery, auth, request ID, metrics, tracing, body limit. Порядок важен: recovery/observability обычно должны охватывать inner middleware.

```go
func withRequestID(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        id := newRequestID()
        next.ServeHTTP(w, r.WithContext(context.WithValue(r.Context(), requestIDKey{}, id)))
    })
}
```

## Body и response

- Ограничивайте request body через `http.MaxBytesReader` до decoding.
- На server request body обычно закрывается server-ом; handler может закрыть раньше.
- Header нужно установить до `WriteHeader`/первого `Write`.
- Первый `Write` без `WriteHeader` отправляет `200 OK`.
- Не передавайте внутренние error strings клиенту.

Для streaming проверяйте `http.Flusher`, context cancellation и backpressure. Response buffering/proxy timeouts могут нивелировать flush; это end-to-end свойство.

## Sources

- [`net/http`](https://pkg.go.dev/net/http)
- [`http.ServeMux`](https://pkg.go.dev/net/http#ServeMux)
