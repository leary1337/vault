---
title: gRPC errors
description: Status codes, domain mapping и retry classification.
tags:
  - go
  - grpc
  - errors
updated: 2026-09-10
---

# gRPC errors

RPC завершается status code, message и optional details. Domain error переводится в status на transport boundary.

```go
switch {
case errors.Is(err, domain.ErrNotFound):
    return status.Error(codes.NotFound, "user not found")
case errors.Is(err, domain.ErrConflict):
    return status.Error(codes.Aborted, "concurrent update")
default:
    return status.Error(codes.Internal, "internal error")
}
```

Не раскрывайте raw error в message. Structured details versioned как protobuf messages и также являются public contract.

Важные различия:

- `InvalidArgument` — request некорректен независимо от state.
- `FailedPrecondition` — state нужно исправить до retry.
- `Aborted` — retry всей higher-level read-modify-write sequence.
- `Unavailable` — transient service condition; retry только если operation безопасна.
- `DeadlineExceeded` не доказывает, что server side effect не случился.
- `Unauthenticated` — нет валидной identity; `PermissionDenied` — identity есть, права недостаточны.

## Источники

- [gRPC Status Codes](https://grpc.io/docs/guides/status-codes/)
- [gRPC Error handling](https://grpc.io/docs/guides/error/)
