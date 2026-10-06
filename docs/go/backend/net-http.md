---
title: "`net/http`"
description: "Сервер принимает соединение и вызывает ServeHTTP обработчика."
tags:
  - go
  - http
updated: 2026-10-06
---

# `net/http`

Сервер принимает соединение и вызывает `ServeHTTP` обработчика. Маршрутизатор выбирает нужный обработчик, а middleware оборачивает его общими действиями. При `Handler: nil` используется `DefaultServeMux`, но можно передать собственный маршрутизатор.

```go
type Handler interface {
	ServeHTTP(http.ResponseWriter, *http.Request)
}
```

`HandlerFunc` превращает функцию в обработчик. С Go 1.22 ServeMux поддерживает методы, имена и шаблоны пути. Более конкретный шаблон выигрывает, конфликтующие вызывают панику при регистрации. `GODEBUG=httpmuxgo121=1` возвращает старые правила; они не относятся автоматически к сторонним маршрутизаторам.

## Middleware

```go
func withRequestID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		id := newRequestID()
		next.ServeHTTP(w, r.WithContext(context.WithValue(r.Context(), requestIDKey{}, id)))
	})
}
```

Порядок обёрток определяет, что попадёт под восстановление паники, проверку прав и измерения. Обычно внешние обёртки должны видеть ошибки внутренних. Каждый слой должен иметь понятную ответственность.

## Тело и ответ

До декодирования ограничьте тело через `http.MaxBytesReader`. Сервер обычно закрывает тело входящего запроса; обработчик может сделать это раньше. Заголовки задаются до `WriteHeader` или первой записи. `Write` без заданного статуса начинает ответ `200`.

После возврата обработчика нельзя пользоваться `ResponseWriter`. Внутренние ошибки не отправляйте клиенту текстом. Для потокового ответа нужны возможность flush, отмена и предел буфера; прокси может всё равно буферизовать данные.

## Маршрут на примере

Полная программа для Go 1.22+:

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

`GET /users/42` даёт `200` и `user=42`; `POST` — `405`. Шаблон GET допускает HEAD. Это локальный пример; внешний сервер требует явных настроек.

После отправки окончательного статуса нельзя заменить его на `500`, если позже произошла ошибка. Логируйте и прекращайте поток либо задавайте отдельный итоговый результат в протоколе. Обёртка ResponseWriter должна сохранять необходимые возможности `Flusher`, `Hijacker` или `Unwrap` для ResponseController.

## Источники

- [`net/http`](https://pkg.go.dev/net/http)
- [`http.ServeMux`](https://pkg.go.dev/net/http#ServeMux)
- [Go 1.22: enhanced routing](https://go.dev/doc/go1.22#enhanced_routing_patterns)

## Проверь себя

1. Можно ли заменить окончательный статус после первой записи тела?
2. Как обёртка может сломать потоковый ответ?

<details>
<summary>Ответы</summary>

1. Нет: заголовки уже отправлены.
2. Скрыть возможность flush или неправильно буферизовать данные.

</details>
