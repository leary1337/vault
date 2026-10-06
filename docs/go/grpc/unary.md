---
title: "Один запрос и ответ: unary RPC"
description: "Unary RPC — один вызов с одним запросом и одним ответом или статусом."
tags:
  - go
  - grpc
updated: 2026-10-06
---

# Один запрос и ответ: unary RPC

Unary RPC — один вызов с одним запросом и одним ответом или статусом. Обработчик Go получает контекст, содержащий срок и отмену. Метаданные подходят для идентификаторов, проверки личности и трассировки, а не больших тел.

```go
func (s *Server) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.User, error) {
	user, err := s.repo.Find(ctx, req.GetId())
	if err != nil {
		return nil, mapError(err)
	}
	return toProto(user), nil
}
```

Проверьте форму входа на границе, затем вызовите сервисный слой. Ошибку БД переводите в стабильную категорию, не отдавая внутренний текст.

## Переиспользование клиента

Фрагмент инициализации; нужны `google.golang.org/grpc` и `google.golang.org/grpc/credentials`:

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

`tlsConfig` и пакет `pb` задаёт приложение. `NewClient` доступен с grpc-go 1.63; успех означает создание клиентского объекта, а не доступность сервера. Подключение возникает по мере использования, срок RPC ограничивает ожидание. Не отключайте TLS публичного сервиса ради удобства.

## Неизвестный результат записи

Клиент послал CreateAd и получил DeadlineExceeded. Сервер мог уже сохранить объявление. Повтор с новым намерением создаст дубль. Для безопасного повтора нужен тот же ключ операции, проверка ранее выполненного результата и согласованный ответ. Отмена клиента сама не откатывает запись.

## Источники

- [gRPC Core concepts](https://grpc.io/docs/what-is-grpc/core-concepts/)
- [gRPC metadata](https://grpc.io/docs/guides/metadata/)

## Проверь себя

1. Что гарантирует успешный `grpc.NewClient`?
2. Зачем ключ защиты от повторов у Create?

<details>
<summary>Ответы</summary>

1. Создание клиентского объекта, но не доступность сервера.
2. Чтобы после неизвестного результата повтор вернул прежний объект, а не создал новый.

</details>
