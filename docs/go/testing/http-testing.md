---
title: "Тесты HTTP"
description: "httptest.NewRequest и NewRecorder проверяют обработчик без настоящего слушающего сокета."
tags:
  - go
  - testing
  - http
updated: 2026-10-06
---

# Тесты HTTP

`httptest.NewRequest` и `NewRecorder` проверяют обработчик без настоящего слушающего сокета. Это удобно для статуса, заголовков и смысла тела. Проверяйте декодированный JSON, а не случайный порядок его байтов.

```go
req := httptest.NewRequest(http.MethodGet, "/users/42", nil)
rec := httptest.NewRecorder()
handler.ServeHTTP(rec, req)

res := rec.Result()
defer res.Body.Close()
if res.StatusCode != http.StatusOK {
	t.Fatalf("status = %d", res.StatusCode)
}
```

## Проверка маршрута

```go
func TestUserRoute(t *testing.T) {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /users/{id}", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, r.PathValue("id"))
	})
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, httptest.NewRequest("GET", "/users/42", nil))
	if rec.Code != 200 || rec.Body.String() != "42" {
		t.Fatalf("status=%d body=%q", rec.Code, rec.Body.String())
	}
}
```

Нужны `fmt`, `net/http`, `net/http/httptest`, `testing`, Go 1.22+. `PathValue` заполняет маршрутизатор: прямой вызов функции его обходит. Поэтому проверяйте собранный рабочий mux и цепочку middleware.

## Где нужен сервер

Recorder не моделирует медленного клиента, пул, TLS и сетевую отмену. Для этого нужны клиентский Transport и тестовый сервер. В Go 1.27 `httptest.NewTestServer(t, handler)` по умолчанию использует сеть в памяти, совместимую с `testing/synctest`. Классические NewServer/NewTLSServer работают через loopback и требуют Close.

Сценарий повтора и таймаута клиента нельзя заменить прямым вызовом обработчика: он должен проверить закрытие тела и реальную границу передачи.

## Источники

- [`net/http/httptest`](https://pkg.go.dev/net/http/httptest)
- [`testing/synctest`](https://pkg.go.dev/testing/synctest)

## Проверь себя

1. Почему `PathValue` пуст при прямом вызове обработчика?
2. Когда Recorder недостаточно?

<details>
<summary>Ответы</summary>

1. Запрос не прошёл маршрутизатор, устанавливающий параметр.
2. Для TLS, соединений, пула, сетевой отмены и потокового поведения.

</details>
