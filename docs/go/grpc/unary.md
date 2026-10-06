---
title: Unary RPC
description: Lifecycle unary gRPC-вызова, metadata и idempotency.
tags:
  - go
  - grpc
updated: 2026-10-06
---

# Unary RPC

Unary RPC — один вызов с одним запросом и одним ответом. Сетевая ошибка означает неизвестный исход, а не обязательно отсутствие действия на сервере.

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

Validate transport shape на boundary (граница ответственности между слоями), затем вызывайте domain service. Не возвращайте raw DB error. Metadata подходит для auth/tracing/request IDs, но не для больших payloads.

Даже после client cancellation server side effect мог выполниться. Для retryable create/update используйте idempotency (свойство повторной операции давать тот же эффект) key/deduplication и определите response при повторе.

## Подключение переиспользуют

Фрагмент инициализации приложения; нужны `google.golang.org/grpc` и `google.golang.org/grpc/credentials`:

```go
conn, err := grpc.NewClient("dns:///users.example:443",
	grpc.WithTransportCredentials(credentials.NewTLS(tlsConfig)),
)
if err != nil {
	return err
}
defer conn.Close()
client := pb.NewUsersClient(conn)
```

`tlsConfig` и сгенерированный пакет `pb` задаёт приложение. `NewClient` доступен с grpc-go 1.63; успешное создание channel не доказывает доступность сервера. Соединение устанавливается по мере использования, а deadline RPC ограничивает ожидание. Не подменяйте TLS публичного сервиса `insecure.NewCredentials` ради удобства.

Например, клиент послал CreateAd и получил DeadlineExceeded. Сервер мог уже записать объявление. Повтор должен иметь тот же idempotency key и вернуть ранее сохранённый результат, иначе появится второй объект.

## Источники

- [gRPC Core concepts](https://grpc.io/docs/what-is-grpc/core-concepts/)
- [gRPC metadata](https://grpc.io/docs/guides/metadata/)

## Проверь себя

1. Что гарантирует успешный grpc.NewClient?
2. Зачем ключ идемпотентности при Create?

<details>
<summary>Ориентиры для ответа</summary>

1. Корректное создание объекта channel, а не доступность сервера или успех RPC.
2. Чтобы безопасный повтор после неизвестного исхода не создал второй объект.

</details>
