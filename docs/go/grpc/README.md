---
title: gRPC в Go
description: Protobuf contracts, RPC lifecycle, streaming, interceptors и resilience.
tags:
  - go
  - grpc
updated: 2026-09-10
---

# gRPC в Go

Порядок: [Protobuf](protobuf.md) → [unary RPC](unary.md) → [streaming](streaming.md) → [interceptors](interceptors.md) → [errors](errors.md) → [deadlines/cancellation](deadlines-and-cancellation.md).

`grpc.ClientConn` — long-lived virtual connection/channel: она управляет name resolution, subchannels, connectivity и load-balancing policy и должна переиспользоваться. Default `pick_first` выбирает один доступный backend; `round_robin` и другие policies задаются service config. Не создавайте connection на каждый RPC.

Retries не имеют default policy: кроме узких transparent retries, application должна явно настроить retryable methods/codes, attempt budget и idempotency. Наблюдайте call-level и attempt-level metrics.

## Источники

- [gRPC documentation](https://grpc.io/docs/)
- [Service Config](https://grpc.io/docs/guides/service-config/)
- [Custom load balancing policies](https://grpc.io/docs/guides/custom-load-balancing/)
