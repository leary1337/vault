---
title: gRPC deadlines и cancellation
description: Deadline budgets, propagation и остановка server work.
tags:
  - go
  - grpc
  - context
updated: 2026-10-06
---

# gRPC deadlines и cancellation

Deadline ограничивает весь вызов, включая ожидание соединения. Отмена сообщает серверу остановить лишнюю работу, но не отменяет уже завершённый побочный эффект.

По умолчанию deadline может отсутствовать, и client способен ждать неограниченно. Каждый production caller задаёт реалистичный budget из end-to-end SLO (целевой уровень качества, например доля ответов быстрее заданного срока) и remaining parent deadline.

Go gRPC propagates incoming context deadline в downstream RPC при использовании того же/child context; elapsed time учитывается при wire (передаваемый по сети) timeout conversion. Server context отменяется после client cancellation/deadline, но application обязана передать context в DB/HTTP и прекратить spawned work.

```go
ctx, cancel := context.WithTimeout(parent, 800*time.Millisecond)
defer cancel()
resp, err := client.GetUser(ctx, req)
```

Не выделяйте каждому downstream полный parent timeout: оставляйте budget для local work, fallback и response. Retry attempts делят общий deadline; каждый новый attempt уменьшает оставшееся время.

Cancellation — signal, не rollback. Side effect мог committed до того, как client получил status. Для commands нужны idempotency/dedup и queryable operation state.

## Разделение общего бюджета

Запросу оставлено 500 мс. Локальная проверка занимает 50 мс, на ответ и cleanup оставляем 50 мс; downstream можно дать не более 400 мс. Если первая попытка заняла 250 мс, следующей нельзя выдавать новый полный timeout 400 мс: она остаётся внутри общего parent deadline.

Проверяйте `ctx.Err()` в длинных циклах и передавайте context драйверу БД. Для CPU-операции проверка раз в разумное число итераций дешевле отдельного таймера на каждый элемент. На сервере обработайте отмену, закройте собственные ресурсы и дождитесь дочерних workers. Нет default deadline, пригодного для всех методов: длительный stream и короткий lookup требуют разных контрактов.

## Источники

- [gRPC Deadlines](https://grpc.io/docs/guides/deadlines/)
- [gRPC Cancellation](https://grpc.io/docs/guides/cancellation/)
- [`context` package](https://pkg.go.dev/context)

## Проверь себя

1. Зачем parent deadline, если у каждого attempt timeout?
2. Доказывает ли Canceled отсутствие side effect?

<details>
<summary>Ориентиры для ответа</summary>

1. Без общего срока цепочка retries может многократно увеличить задержку.
2. Нет: действие могло завершиться до получения отмены.

</details>
