---
title: "Перехватчики gRPC"
description: "Interceptor оборачивает RPC общими действиями: проверкой личности и прав, измерением, логом или восстановлением допустимой паники."
tags:
  - go
  - grpc
updated: 2026-10-06
---

# Перехватчики gRPC

**Interceptor** оборачивает RPC общими действиями: проверкой личности и прав, измерением, логом или восстановлением допустимой паники. Бизнес-операция остаётся в обработчике.

## Порядок обёрток

Проверка прав должна быть до операции: после вызова `next` изменение уже могло произойти. Измерение должно видеть отклонённые и неудачные вызовы, а восстановление — охватывать нужную границу. Первая обёртка цепочки внешняя.

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

Нужны `context`, `time`, `log/slog`, `grpc`, `grpc/status`. При успехе лог покажет `code=OK`, а тело не записывается. Пример подключения — `grpc.NewServer(grpc.ChainUnaryInterceptor(observe, auth, recovery))`; `auth` и `recovery` реализует приложение.

## Потоки и попытки

Unary-перехватчик не обрабатывает потоковый RPC. Для потока регистрируют отдельный stream interceptor. Если нужно наблюдать каждое сообщение, корректно оборачивают `RecvMsg` и `SendMsg`. По умолчанию тело не логируют: оно может содержать персональные данные и быть большим.

Клиентский interceptor видит логический вызов. Внутренние повторы gRPC могут создать несколько сетевых попыток в одном таком вызове. Для них используйте статистику попыток и подходящие метрики OpenTelemetry: число вызовов обёртки не равно числу передач по сети.

## Источники

- [gRPC interceptors guide](https://grpc.io/docs/guides/interceptors/)
- [gRPC-Go package](https://pkg.go.dev/google.golang.org/grpc)

## Проверь себя

1. Можно ли проверить права после `next`?
2. Почему число вызовов interceptor не равно числу сетевых попыток?

<details>
<summary>Ответы</summary>

1. Нет: операция уже могла выполниться.
2. Один логический вызов может иметь несколько внутренних повторов.

</details>
