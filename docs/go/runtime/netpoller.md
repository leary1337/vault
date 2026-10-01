---
title: Netpoller
description: Как runtime Go ожидает network readiness без thread-per-connection.
tags:
  - go
  - runtime
  - networking
updated: 2026-10-01
---

# Netpoller

> Это описание standard Go runtime 1.27, а не гарантия language specification.

Runtime связывает сетевые операции `net` с механизмом ожидания OS. На Linux используются non-blocking sockets и epoll, на BSD/macOS — kqueue, на Windows — overlapped I/O и IOCP. Поэтому универсально описывать все платформы только через readiness неправильно.

Если операция пока не может продолжиться, goroutine park. Событие poller или истечение deadline позволяет ей снова стать runnable; это не гарантия немедленного выполнения и не признак получения целого application message.

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
- [Runtime netpoll, Go 1.27.1](https://github.com/golang/go/blob/go1.27.1/src/runtime/netpoll.go)
- [Linux epoll backend, Go 1.27.1](https://github.com/golang/go/blob/go1.27.1/src/runtime/netpoll_epoll.go)
- [Windows IOCP backend, Go 1.27.1](https://github.com/golang/go/blob/go1.27.1/src/runtime/netpoll_windows.go)
- [Go diagnostics: execution tracer](https://go.dev/doc/diagnostics#execution-tracer)
