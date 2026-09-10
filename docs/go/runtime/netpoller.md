---
title: Netpoller
description: Как runtime Go ожидает network readiness без thread-per-connection.
tags:
  - go
  - runtime
  - networking
updated: 2026-09-10
---

# Netpoller

> Это описание standard Go runtime 1.27, а не гарантия language specification.

`net` package обычно переводит поддерживаемые sockets в non-blocking mode и регистрирует их в platform poller. Goroutine, которой пока нельзя завершить read/write, park. Когда OS сообщает readiness или deadline истекает, runtime делает соответствующую goroutine runnable.

Backend consequence: тысячи mostly-idle connections не требуют тысячи одновременно работающих OS threads. Но каждая connection всё равно потребляет FD, kernel buffers, Go objects и application buffers.

## Что не покрывает модель

- Regular file I/O на многих systems не имеет такой же readiness semantics и может блокировать thread.
- DNS path зависит от resolver mode и platform; cgo resolver может использовать threads.
- cgo/foreign calls не становятся автоматически netpoller-aware.
- Readiness не означает, что весь application message уже доступен; protocol framing остаётся обязанностью caller.

## Deadlines

Network deadlines устанавливают абсолютное время для будущих и текущих I/O operations. После timeout deadline нужно обновить, если connection продолжает использоваться. Context сам по себе не отменяет произвольный `net.Conn` read; higher-level API должен связать context с deadline/close.

## Источники

- [`net` package](https://pkg.go.dev/net)
- [Runtime netpoll source](https://go.dev/src/runtime/netpoll.go)
- [Go diagnostics: execution tracer](https://go.dev/doc/diagnostics#execution-tracer)
