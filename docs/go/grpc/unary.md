---
title: Unary RPC
description: Lifecycle unary gRPC-вызова, metadata и idempotency.
tags:
  - go
  - grpc
updated: 2026-09-10
---

# Unary RPC

Unary RPC имеет один request и один response/status. Go handler получает `context.Context`; deadline, peer cancellation и metadata доступны через него и gRPC APIs.

```go
func (s *Server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
    user, err := s.repo.Find(ctx, req.GetId())
    if err != nil {
        return nil, mapError(err)
    }
    return toProto(user), nil
}
```

Validate transport shape на boundary, затем вызывайте domain service. Не возвращайте raw DB error. Metadata подходит для auth/tracing/request IDs, но не для больших payloads.

Даже после client cancellation server side effect мог выполниться. Для retryable create/update используйте idempotency key/deduplication и определите response при повторе.

## Источники

- [gRPC Core concepts](https://grpc.io/docs/what-is-grpc/core-concepts/)
- [gRPC metadata](https://grpc.io/docs/guides/metadata/)
