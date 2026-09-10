---
title: HTTP client и Transport
description: Connection pooling, timeouts, body lifecycle и безопасные retries HTTP-клиента Go.
tags:
  - go
  - http
  - production
level:
  - senior
updated: 2026-09-10
---

# HTTP client и Transport

`http.Client` и `http.Transport` безопасны для concurrent use и должны переиспользоваться. Client на каждый request разрушает pooling; Transport на каждый request создаёт новые pools и sockets.

```go
transport := http.DefaultTransport.(*http.Transport).Clone()
transport.MaxIdleConns = 200
transport.MaxIdleConnsPerHost = 50
transport.MaxConnsPerHost = 100
transport.IdleConnTimeout = 90 * time.Second
transport.TLSHandshakeTimeout = 5 * time.Second
transport.ResponseHeaderTimeout = 3 * time.Second

client := &http.Client{
    Transport: transport,
    Timeout:   5 * time.Second,
}
```

Цифры — пример. Настройка должна следовать concurrency, upstream instances, latency SLO и ephemeral-port/FD budget.

## Границы timeout

- `Client.Timeout` охватывает redirects, connection, headers и чтение response body.
- Request context позволяет caller задать меньший deadline/cause.
- `Dialer.Timeout` — connection establishment.
- `TLSHandshakeTimeout` — TLS handshake.
- `ResponseHeaderTimeout` — ожидание headers после отправки request.
- `IdleConnTimeout` — lifetime idle pooled connection, не request deadline.

Ноль часто означает отсутствие limit. Budget downstream call должен укладываться в remaining caller deadline и оставлять время на response/cleanup.

## Response body и reuse

Caller обязан закрыть non-nil `resp.Body`. Для HTTP/1.x connection reuse обычно нужно дочитать body до EOF; если payload не нужен, прочитайте ограниченный остаток или закройте и примите потерю reuse. Никогда не читайте unlimited hostile body.

## Pool controls

- `MaxIdleConns` — общий idle pool.
- `MaxIdleConnsPerHost` — idle connections на host; default мал для многих high-concurrency services.
- `MaxConnsPerHost` — dialing + active + idle; при достижении новые dials ждут.

Слишком низкий pool создаёт queueing; слишком высокий — overload upstream и исчерпание FDs/ports. Измеряйте connect rate, reuse, wait duration, active/idle, errors и upstream saturation. `httptrace` помогает разобрать DNS/connect/TLS/first-byte phases.

## Retries

Transport делает только ограниченные transparent retries и не гарантирует повтор любого request. Application retry требует:

- idempotent operation или idempotency key;
- replayable body (`GetBody`);
- общий deadline/attempt budget;
- exponential backoff + jitter;
- ограничение retry amplification;
- классификацию status/error до чтения unlimited body.

Даже `GET` может иметь плохой server-side implementation; idempotency — контракт системы, а не только HTTP method label.

## DNS, proxy и HTTP/2

Transport использует resolver и proxy configuration (`ProxyFromEnvironment` в default transport). DNS caching в основном зависит от resolver/OS; connection reuse скрывает часть lookups. HTTP/2 multiplexes streams over fewer connections, поэтому connection-count tuning и failure blast radius отличаются от HTTP/1.1.

## Источники

- [`http.Client`](https://pkg.go.dev/net/http#Client)
- [`http.Transport`](https://pkg.go.dev/net/http#Transport)
- [Transport retry source](https://go.dev/src/net/http/transport.go)
- [`net/http/httptrace`](https://pkg.go.dev/net/http/httptrace)
