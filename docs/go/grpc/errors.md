---
title: gRPC errors
description: Status codes, domain mapping и retry classification.
tags:
  - go
  - grpc
  - errors
updated: 2026-10-06
---

# gRPC errors

Статус gRPC сообщает категорию исхода. Категория помогает клиенту выбрать действие; внутренние детали ошибки остаются в защищённом журнале.

RPC завершается status code, message и optional details. Domain error переводится в status на transport boundary (граница ответственности между слоями).

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

## Пример выбора реакции клиента

| Status | Что проверить перед следующим действием |
|---|---|
| InvalidArgument | исправить вход; такой же request не поможет |
| FailedPrecondition | исправить состояние, например открыть заказ |
| Aborted | заново прочитать данные и повторить всю транзакцию |
| Unavailable | разрешён ли безопасный retry в остатке deadline |
| DeadlineExceeded | проверить неизвестный результат команды |

`NotFound` для закрытого приватного ресурса иногда используют, чтобы не раскрывать его существование. Но это согласованная политика API, а не случайное подавление PermissionDenied. Подробности `status.WithDetails` тоже публичны: не включайте SQL, токены и stack (стек вызовов goroutine) traces.

## Источники

- [gRPC Status Codes](https://grpc.io/docs/guides/status-codes/)
- [gRPC Error handling](https://grpc.io/docs/guides/error/)

## Проверь себя

1. Чем Aborted отличается от FailedPrecondition?
2. Почему нельзя повторять любую Unavailable-команду?

<details>
<summary>Ориентиры для ответа</summary>

1. Первое требует повторить согласованную последовательность; второе — изменить состояние до повторной попытки.
2. Исход предыдущей попытки может быть неизвестен; операция должна быть идемпотентной.

</details>
