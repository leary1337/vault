---
title: Graceful shutdown HTTP-сервера
description: Drain HTTP traffic и завершение background components в ограниченный срок.
tags:
  - go
  - http
  - production
updated: 2026-09-10
---

# Graceful shutdown HTTP-сервера

`Server.Shutdown(ctx)` закрывает listeners и idle connections, затем ждёт active connections. Она не закрывает hijacked connections и не останавливает произвольные background goroutines.

Порядок: убрать readiness → учесть propagation delay → вызвать `Shutdown` с deadline → остановить owned workers/dependencies → при timeout зафиксировать и завершить. Общий протокол: [Graceful shutdown](../concurrency/graceful-shutdown.md).

`ListenAndServe` после `Shutdown` возвращает `http.ErrServerClosed`; это ожидаемый outcome, а не incident.

## Источники

- [`http.Server.Shutdown`](https://pkg.go.dev/net/http#Server.Shutdown)
