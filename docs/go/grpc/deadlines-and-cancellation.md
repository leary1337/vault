---
title: gRPC deadlines и cancellation
description: Deadline budgets, propagation и остановка server work.
tags:
  - go
  - grpc
  - context
updated: 2026-09-10
---

# gRPC deadlines и cancellation

По умолчанию deadline может отсутствовать, и client способен ждать неограниченно. Каждый production caller задаёт реалистичный budget из end-to-end SLO и remaining parent deadline.

Go gRPC propagates incoming context deadline в downstream RPC при использовании того же/child context; elapsed time учитывается при wire timeout conversion. Server context отменяется после client cancellation/deadline, но application обязана передать context в DB/HTTP и прекратить spawned work.

```go
ctx, cancel := context.WithTimeout(parent, 800*time.Millisecond)
defer cancel()
resp, err := client.GetUser(ctx, req)
```

Не выделяйте каждому downstream полный parent timeout: оставляйте budget для local work, fallback и response. Retry attempts делят общий deadline; каждый новый attempt уменьшает оставшееся время.

Cancellation — signal, не rollback. Side effect мог committed до того, как client получил status. Для commands нужны idempotency/dedup и queryable operation state.

## Источники

- [gRPC Deadlines](https://grpc.io/docs/guides/deadlines/)
- [gRPC Cancellation](https://grpc.io/docs/guides/cancellation/)
- [`context` package](https://pkg.go.dev/context)
