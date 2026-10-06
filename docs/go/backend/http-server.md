---
title: HTTP server
description: Production timeouts, limits и connection lifecycle HTTP-сервера Go.
tags:
  - go
  - http
  - production
updated: 2026-10-06
---

# HTTP server

HTTP-сервер читает запрос и вызывает обработчик. Для внешних клиентов отдельно ограничивают время, размер данных и количество дорогой работы.

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

Значения — пример, не универсальная конфигурация. Они должны учитывать upload/streaming endpoints, proxy deadlines и SLO (целевой уровень качества, например доля ответов быстрее заданного срока).

## Timeouts

- `ReadHeaderTimeout` ограничивает чтение headers и защищает от slow clients.
- `ReadTimeout` охватывает чтение всего request, включая body; может быть слишком грубым для uploads.
- `WriteTimeout` ограничивает response write lifecycle (жизненный цикл от запуска до завершения), но semantics зависят от protocol и streaming.
- `IdleTimeout` ограничивает ожидание следующего keep-alive request.

Per-handler work ограничивайте request context/deadline. Для body size используйте `MaxBytesReader`; server timeouts не являются size limits.

## Connection state и overload

Server не предоставляет полноценный admission control из коробки. Ограничивайте expensive work/semaphores, connection count на proxy/OS level и наблюдайте active connections, requests, handler concurrency и rejection rate.

TLS/HTTP2 settings и `Server.Protocols` зависят от supported clients. Не отключайте protocol только ради workaround без измерения и upgrade plan.

## Ограничение размера и времени решают разные задачи

Фрагмент `ServeHTTP`; нужны `net/http`, `io`, `errors`:

```go
body := http.MaxBytesReader(w, r.Body, 1<<20)
payload, err := io.ReadAll(body)
if err != nil {
	var tooLarge *http.MaxBytesError
	if errors.As(err, &tooLarge) {
		http.Error(w, "body too large", http.StatusRequestEntityTooLarge)
		return
	}
	http.Error(w, "bad body", http.StatusBadRequest)
	return
}
_ = payload // дальше decoding/validation
```

Payload на 10 ГиБ может прийти быстро: timeout не заменяет размерный предел. Короткий payload может поступать по одному байту в секунду: предел размера не заменяет timeout. Context с timeout не прерывает handler, который его игнорирует. `WriteTimeout` ограничивает операции записи, а не гарантирует остановку CPU-вычисления.

Для streaming нельзя слепо оставить общий короткий WriteTimeout: настройте endpoint и допустимое время простоя, при необходимости через `ResponseController`. Проверьте тот же протокол и proxy, который используется в эксплуатации.

## Источники

- [`http.Server`](https://pkg.go.dev/net/http#Server)
- [Go issue/wiki: HTTP server timeouts](https://pkg.go.dev/net/http)

## Проверь себя

1. Защищает ли ReadHeaderTimeout от большого body?
2. Остановит ли WriteTimeout бесконечный CPU-loop handler?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, он ограничивает чтение headers; body нужен отдельный size/time limit.
2. Нет, timeout записи не является принудительным прерыванием вычисления.

</details>
