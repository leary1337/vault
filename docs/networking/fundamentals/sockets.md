---
title: Sockets
description: Endpoint API, listen/accept/connect, blocking modes, buffers и lifecycle.
tags: [networking, sockets, linux]
created: 2024-07-23
updated: 2026-09-10
---

# Sockets

Socket — kernel-managed communication endpoint, представленный file descriptor на Unix-like systems. Это не обычный filesystem file: похожими являются descriptor API/readiness/lifecycle, а semantics задают address family, type и protocol.

## TCP server/client

Server: `socket` → `bind` → `listen` → повторный `accept`; каждый accepted socket представляет отдельную connection. Client вызывает `connect`. `listen` socket не переносит application data accepted connection.

Backlog и accept rate ограничены; SYN/accept queues и exact Linux behavior зависят от kernel settings. Один listening port поддерживает множество connections, различаемых endpoint tuples.

UDP обычно использует `sendto`/`recvfrom`; `connect` для UDP задаёт default peer/filtering и error association, но не выполняет TCP handshake и не создаёт reliable stream.

## I/O semantics

Blocking `read` ждёт data/EOF/error/deadline; nonblocking возвращает `EAGAIN` и используется readiness poller-ом. Partial read/write нормальны. TCP read не совпадает с peer write boundaries; application protocol обязан framing.

Socket buffers ограничены. Успешный `write` обычно означает copy/acceptance local kernel-ом, не получение или business commit peer-а. Half-close (`shutdown`) закрывает направление отдельно; `close` освобождает descriptor, но TCP может продолжить protocol cleanup.

## Lifecycle

Всегда закрывайте socket/accepted connection на error paths и ставьте close-on-exec атомарно. Deadlines защищают goroutines/resources; TCP keepalive/heartbeat не заменяет operation timeout. Наблюдайте open FDs, accept/connect errors, states, buffer/queue drops и pool hold time.

Go `net` интегрирует поддерживаемые sockets с runtime poller, поэтому blocked goroutine обычно не требует отдельного OS thread. См. [netpoller](../../go/runtime/netpoller.md), [epoll](../../linux/epoll.md) и [connection lifecycle](../backend/connection-lifecycle.md).

## Источники

- [Linux socket(7)](https://man7.org/linux/man-pages/man7/socket.7.html)
- [Linux tcp(7)](https://man7.org/linux/man-pages/man7/tcp.7.html)
