---
title: HTTP request context
description: Cancellation и deadline propagation через HTTP handlers и clients.
tags:
  - go
  - http
  - context
updated: 2026-10-06
---

# HTTP request context

Context запроса соединяет жизнь клиента с работой сервера. Если клиент ушёл, незавершённая работа обычно должна перестать занимать ресурсы.

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

## Отмена на границе исходящего HTTP

```go
ctx, cancel := context.WithTimeout(r.Context(), 300*time.Millisecond)
defer cancel()
req, err := http.NewRequestWithContext(ctx, http.MethodGet, upstreamURL, nil)
if err != nil { /* вернуть внутреннюю ошибку */
	return
}
resp, err := client.Do(req)
if err != nil { /* классифицировать timeout/cancellation */
	return
}
defer resp.Body.Close()
```

Это фрагмент handler; `client` и URL — зависимости, нужны `context`, `time`, `net/http`. Если у родителя остаётся 100 мс, дочерние 300 мс не продлят этот срок. Чтение body тоже зависит от request context.

Обрыв соединения не гарантирует мгновенного обнаружения: сеть может молчать до timeout. Не отправляйте ошибку клиенту, который уже отключился, и не считайте context cancellation доказательством отката записей. Для важной постобработки используйте долговечную очередь или transactional outbox.

## Источники

- [`http.Request.Context`](https://pkg.go.dev/net/http#Request.Context)
- [`context` package](https://pkg.go.dev/context)

## Проверь себя

1. Когда отменяется server request context?
2. Можно ли использовать r.Context после return для важной доставки?

<details>
<summary>Ориентиры для ответа</summary>

1. При завершении handler, обнаруженном disconnect или отмене HTTP/2 request.
2. Он уже отменяется; нужен самостоятельный управляемый lifecycle (жизненный цикл от запуска до завершения), обычно очередь.

</details>
