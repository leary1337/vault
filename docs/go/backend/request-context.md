---
title: "Контекст HTTP-запроса"
description: "Контекст связывает работу с жизнью запроса."
tags:
  - go
  - http
  - context
updated: 2026-10-06
---

# Контекст HTTP-запроса

Контекст связывает работу с жизнью запроса. Если клиент ушёл или обработчик завершился, результат обычно уже не нужен. `r.Context()` отменяется при обнаруженном закрытии соединения, отмене запроса HTTP/2 или возврате `ServeHTTP`.

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

Передавайте этот контекст в SQL, gRPC и исходящий HTTP. Дочерний таймаут может сократить, но не продлить родительский срок. Для HTTP есть `NewRequestWithContext`, для SQL — `QueryContext` и `ExecContext`.

## Исходящий запрос

Фрагмент обработчика; `client` и URL — зависимости. Нужны `context`, `time`, `net/http`:

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

Если осталось 100 мс, дочерние 300 не добавят времени. Чтение тела ответа тоже связано с контекстом исходящего запроса. Обрыв сети может обнаружиться лишь после ожидания: мгновенная отмена не гарантирована.

## Работа после ответа

Данные контекста подходят для идентификатора запроса и проверенной идентичности. Зависимости передавайте явно. `WithoutCancel` не создаёт владельца, очередь или срок для фоновой работы.

Важную доставку после ответа переносите в управляемую долговечную очередь или transactional outbox. Контекст запроса после возврата уже отменяется. Отмена также не доказывает откат записи: операция могла выполниться, а ответ потеряться.

## Источники

- [`http.Request.Context`](https://pkg.go.dev/net/http#Request.Context)
- [`context` package](https://pkg.go.dev/context)

## Проверь себя

1. Когда отменяется контекст серверного запроса?
2. Почему он не подходит для важной доставки после ответа?

<details>
<summary>Ответы</summary>

1. При возврате обработчика, обнаруженном отключении или отмене HTTP/2.
2. Он уже отменяется; работе нужен отдельный управляемый жизненный цикл, часто очередь.

</details>
