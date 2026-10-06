---
title: Graceful shutdown HTTP-сервера
description: Drain HTTP traffic и завершение background components в ограниченный срок.
tags:
  - go
  - http
  - production
updated: 2026-10-06
---

# Graceful shutdown HTTP-сервера

HTTP-серверу нужно прекратить приём запросов, закончить уже принятые и выйти до срока остановки процесса. Фоновые задачи требуют отдельного ожидания.

`Server.Shutdown(ctx)` закрывает listeners и idle connections, затем ждёт active connections. Она не закрывает hijacked connections и не останавливает произвольные background goroutines.

Порядок: убрать readiness (готовность принимать новую работу) → учесть propagation delay → вызвать `Shutdown` с deadline → остановить owned workers/dependencies → при timeout зафиксировать и завершить. Общий протокол: [Graceful shutdown](../concurrency/graceful-shutdown.md).

`ListenAndServe` после `Shutdown` возвращает `http.ErrServerClosed`; это ожидаемый outcome, а не incident.

## Ожидаемый возврат сервера и реальное завершение

Фрагмент координации; `srv` — заранее созданный `*http.Server`, `shutdownCtx` — новый context с timeout:

```go
serveErr := make(chan error, 1)
go func() { serveErr <- srv.ListenAndServe() }()

// После сигнала остановки; main остаётся жить до окончания Shutdown.
if err := srv.Shutdown(shutdownCtx); err != nil {
	_ = srv.Close() // принудительно закрыть обычные connections
	return err
}
if err := <-serveErr; err != nil && !errors.Is(err, http.ErrServerClosed) {
	return err
}
```

Это фрагмент функции, возвращающей error; нужны `errors` и `net/http`. В реальном `main` надо также сразу обрабатывать ошибку запуска, например занятый порт, а не ждать только сигнала. Если вернуть `main` сразу после `ErrServerClosed`, запущенная отдельно goroutine с `Shutdown` не успеет закончить drain (завершение уже принятой работы после остановки приёма). WebSocket после hijack, subscribers и workers зарегистрируйте отдельно. `Close` тоже не закрывает hijacked connections.

## Источники

- [`http.Server.Shutdown`](https://pkg.go.dev/net/http#Server.Shutdown)

## Проверь себя

1. Значит ли ErrServerClosed, что все handlers завершились?
2. Какие соединения Shutdown не обслуживает автоматически?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, Serve возвращается после закрытия listener; нужно дождаться Shutdown.
2. Hijacked, например многие WebSocket-соединения, и собственные фоновые ресурсы.

</details>
