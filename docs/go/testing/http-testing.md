---
title: HTTP testing
description: Handler, middleware и client integration tests через httptest.
tags:
  - go
  - testing
  - http
updated: 2026-10-06
---

# HTTP testing

Handler test проверяет HTTP-ответ без настоящего listener. Test server нужен для поведения клиента, соединений, deadlines и transport.

Для isolated handler test используйте `httptest.NewRequest` и `NewRecorder`:

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

Проверяйте status, headers и decoded semantic body, а не byte formatting JSON. Middleware chain и routing должны тестироваться собранным production router.

Для connection/TLS/streaming behavior нужен test server. В Go 1.27 `httptest.NewTestServer(t, handler)` по умолчанию использует in-memory network, совместимую с `testing/synctest`; классические `NewServer`/`NewTLSServer` используют loopback и требуют `Close`.

Не подменяйте real client retry/timeout test вызовом handler напрямую: Transport lifecycle (жизненный цикл от запуска до завершения), body close и cancellation проверяются на network boundary (граница ответственности между слоями).

## Полный тест маршрута

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

Нужны `fmt`, `net/http`, `net/http/httptest`, `testing`, Go 1.22+. Если вызвать handler напрямую, PathValue не устанавливается router. Поэтому для проверки маршрутизации используйте именно собранный mux. Recorder не моделирует медленного клиента и сеть: для этого используйте transport и server.

## Источники

- [`net/http/httptest`](https://pkg.go.dev/net/http/httptest)
- [`testing/synctest`](https://pkg.go.dev/testing/synctest)

## Проверь себя

1. Почему PathValue может быть пустым в isolated handler test?
2. Когда NewRecorder недостаточно?

<details>
<summary>Ориентиры для ответа</summary>

1. Запрос не прошёл через router, который устанавливает параметры пути.
2. Для pooling, TLS, реальной cancellation сети и потокового поведения.

</details>
