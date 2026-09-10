---
title: gRPC interceptors
description: Boundary middleware для auth, observability, recovery и policy.
tags:
  - go
  - grpc
updated: 2026-09-10
---

# gRPC interceptors

Unary и stream interceptors оборачивают client/server RPC lifecycle. Типичные задачи: authentication/authorization, tracing, metrics, structured logging, recovery и policy enforcement.

Порядок chain важен. Recovery должен охватывать inner application; auth должна выполняться до business handler; observability должна видеть rejected и failed calls. Не помещайте domain logic в interceptor.

Stream interceptor получает wrapper stream; чтобы наблюдать каждое message, нужно корректно оборачивать `RecvMsg`/`SendMsg`. Не логируйте payload по умолчанию: он может содержать PII и создавать большой cost.

Client interceptor видит logical call, но retry может создавать несколько attempts внутри gRPC. Для retry observability используйте OpenTelemetry attempt metrics/статистику, а не считайте interceptor invocation равной одному network attempt.

## Источники

- [gRPC interceptors guide](https://grpc.io/docs/guides/interceptors/)
- [gRPC-Go package](https://pkg.go.dev/google.golang.org/grpc)
