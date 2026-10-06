---
title: net/http
description: Request lifecycle, handlers, middleware, bodies и streaming в net/http.
tags:
  - go
  - http
updated: 2026-10-06
---

# `net/http`

Handler — функция обработки HTTP-запроса. Router выбирает handler, middleware добавляет общие действия до и после его вызова.

Server принимает connection, читает request и вызывает `ServeHTTP(ResponseWriter, *Request)` своего `Handler`; если Handler равен nil, используется `DefaultServeMux`. `ServeMux` — один из вариантов маршрутизации, можно передать собственный handler/router. Handler должен учитывать cancellation и не использовать `ResponseWriter` после return.

```go
type Handler interface {
	ServeHTTP(http.ResponseWriter, *http.Request)
}
```

`HandlerFunc` адаптирует function. С Go 1.22 `ServeMux` поддерживает method/host/path patterns и path wildcards; более специфичный pattern выигрывает, конфликтующие patterns вызывают panic при registration. `GODEBUG=httpmuxgo121=1` возвращает правила Go 1.21. Эти правила относятся к ServeMux, а не к любому router.

## Middleware

Middleware оборачивает handler и отвечает за одну boundary (граница ответственности между слоями)-задачу: recovery, auth, request ID, metrics, tracing, body limit. Порядок важен: recovery/observability обычно должны охватывать inner middleware.

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

Для streaming проверяйте `http.Flusher`, context cancellation и backpressure (замедление приёма, когда обработчик не успевает). Response buffering/proxy timeouts могут нивелировать flush; это end-to-end свойство.

## Минимальный маршрут с параметром

Полная программа для Go 1.22+, нужна локальная сеть для запуска:

```go
package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /users/{id}", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		fmt.Fprintf(w, "user=%s\n", r.PathValue("id"))
	})
	log.Fatal(http.ListenAndServe("127.0.0.1:8080", mux))
}
```

`GET /users/42` вернёт `200` и `user=42`; `POST` по этому пути — `405`. Pattern GET также допускает HEAD. Это учебный локальный сервер; для внешнего сервиса задайте `Server` с limits/timeouts.

Первый `Write` фиксирует окончательный HTTP-ответ. Если после частичного body произошла ошибка, заменить статус на `500` уже нельзя: логируйте проблему, прекращайте stream или проектируйте протокол с отдельным итоговым результатом. Обёртка ResponseWriter должна сохранять нужные возможности (`Flusher`/`Hijacker` или `Unwrap` для ResponseController).

## Источники

- [`net/http`](https://pkg.go.dev/net/http)
- [`http.ServeMux`](https://pkg.go.dev/net/http#ServeMux)
- [Go 1.22: enhanced routing](https://go.dev/doc/go1.22#enhanced_routing_patterns)

## Проверь себя

1. Можно ли изменить status после первого Write?
2. Почему middleware wrapper способен сломать streaming?

<details>
<summary>Ориентиры для ответа</summary>

1. Окончательный статус уже отправлен; второй WriteHeader его не заменяет.
2. Он может скрыть интерфейс flush или неправильно буферизовать данные.

</details>
