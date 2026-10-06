---
title: gRPC interceptors
description: Boundary middleware для auth, observability, recovery и policy.
tags:
  - go
  - grpc
updated: 2026-10-06
---

# gRPC interceptors

Interceptor — обёртка вокруг RPC. Она отвечает за общие правила вроде проверки прав и измерений, оставляя бизнес-операцию внутри handler.

Unary и stream interceptors оборачивают client/server RPC lifecycle (жизненный цикл от запуска до завершения). Типичные задачи: authentication/authorization, tracing, metrics, structured logging, recovery и policy enforcement.

Порядок chain важен. Recovery должен охватывать inner application; auth должна выполняться до business handler; observability должна видеть rejected и failed calls. Не помещайте domain logic в interceptor.

Stream interceptor получает wrapper stream; чтобы наблюдать каждое message, нужно корректно оборачивать `RecvMsg`/`SendMsg`. Не логируйте payload по умолчанию: он может содержать PII (персональные данные) и создавать большой cost.

Client interceptor видит logical call, но retry может создавать несколько attempts внутри gRPC. Для retry observability используйте OpenTelemetry attempt metrics/статистику, а не считайте interceptor invocation равной одному network attempt.

## Минимальный server unary interceptor

```go
func observe(
	ctx context.Context, req any,
	info *grpc.UnaryServerInfo, next grpc.UnaryHandler,
) (any, error) {
	started := time.Now()
	resp, err := next(ctx, req)
	slog.InfoContext(ctx, "rpc completed", "method", info.FullMethod,
		"code", status.Code(err).String(), "duration", time.Since(started))
	return resp, err
}
```

Нужны `context`, `time`, `log/slog`, `grpc`, `grpc/status`. На успешном RPC получится code=OK; payload не записывается. Настройка: `grpc.NewServer(grpc.ChainUnaryInterceptor(observe, auth, recovery))`, где auth/recovery — ваши функции. Первая обёртка внешняя; конкретный порядок выбирается так, чтобы rejected calls измерялись, а recovery охватывала допустимую границу panic.

Unary-обёртка не обслуживает stream RPC: для них зарегистрируйте отдельный stream interceptor и корректно оберните методы потока.

## Источники

- [gRPC interceptors guide](https://grpc.io/docs/guides/interceptors/)
- [gRPC-Go package](https://pkg.go.dev/google.golang.org/grpc)

## Проверь себя

1. Можно ли auth выполнить после next?
2. Почему число interceptor calls не равно числу network attempts?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет: бизнес-действие уже могло произойти до проверки прав.
2. Внутренняя retry-механика может выполнить несколько попыток в одном логическом вызове.

</details>
