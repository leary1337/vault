---
title: gRPC streaming
description: Server, client и bidirectional streaming, flow control и lifecycle.
tags:
  - go
  - grpc
  - streaming
updated: 2026-09-10
---

# gRPC streaming

- Server streaming: один request, поток responses.
- Client streaming: поток requests, один response.
- Bidirectional: два независимых ordered streams внутри RPC.

Message order сохраняется внутри отдельного stream в направлении отправки. Порядок между разными streams/RPC не гарантируется.

Flow control ограничивает bytes in flight, но application всё равно должна ограничивать message size, buffered work и concurrent streams. `Send`/`Recv` могут блокироваться; проверяйте context и не запускайте goroutine без owner.

EOF при завершении receive-side отличается от non-OK final status. Для client-streaming/bidi итоговый status может стать известен только после завершения protocol. Half-close означает, что одна сторона закончила sending, но ещё может receive.

Retries streaming RPC сложнее: уже наблюдённые/отправленные messages нельзя безусловно replay. Проектируйте resume token/sequence/idempotency на application level, если stream должен переживать reconnect.

## Источники

- [gRPC Core concepts: streaming](https://grpc.io/docs/what-is-grpc/core-concepts/)
- [gRPC flow control](https://grpc.io/docs/guides/flow-control/)
