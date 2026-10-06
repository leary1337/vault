---
title: Context
description: Cancellation, deadlines, causes и request-scoped values в Go.
tags:
  - go
  - concurrency
  - context
updated: 2026-10-06
---

# Context

Context сообщает работе, что ждать уже не нужно, и задаёт срок. Он не убивает goroutine: выполняемая функция должна проверить сигнал и прекратить работу.

`context.Context` переносит cancellation signal, deadline и request-scoped values через call tree. Он не является универсальным контейнером зависимостей или mutable state.

## API

- `Background` — корень для main/init/test top-level work.
- `TODO` — временная отметка, когда правильный parent ещё не определён.
- `WithCancel`, `WithTimeout`, `WithDeadline` — child context + cancel function.
- `WithCancelCause`, `WithDeadlineCause`, `WithTimeoutCause` и `Cause` — cancellation с диагностической причиной.
- `AfterFunc` — запускает function после cancellation.
- `WithoutCancel` — отделяет child от parent cancellation; использовать только при явном новом lifecycle (жизненный цикл от запуска до завершения).

Всегда вызывайте возвращённый cancel, даже если ожидаете timeout: это освобождает связанные ресурсы раньше.

```go
ctx, cancel := context.WithTimeout(parent, 2*time.Second)
defer cancel()

if err := repository.Load(ctx, id); err != nil {
	return fmt.Errorf("load %s: %w", id, err)
}
```

## Правила API

- `ctx` — первый параметр, обычно с именем `ctx`.
- Не храните Context в struct без специальной причины.
- Не передавайте nil; используйте `context.TODO`, если parent неизвестен.
- Values — только для request-scoped data, проходящей process/API boundary (граница ответственности между слоями): trace ID, auth principal. Не храните config, logger как dependency, optional arguments или mutable accumulator.
- Key должен быть private comparable type, чтобы избежать collisions.

## Propagation

HTTP server отменяет `Request.Context` при disconnect/завершении обработки; client request принимает context через `NewRequestWithContext`. `database/sql` методы `QueryContext`/`ExecContext` передают cancellation driver-у, но скорость фактической отмены зависит от driver/protocol. gRPC переносит deadline/cancellation через RPC context.

Kafka message не получает Context «автоматически»: trace/correlation metadata нужно сериализовать в headers, а processing lifecycle связать с consumer shutdown/rebalance.

Продолжение по boundaries: [HTTP request context](../backend/request-context.md), [SQL cancellation](../testing/database-testing.md), [gRPC deadlines](../grpc/deadlines-and-cancellation.md) и [OpenTelemetry propagation](../../observability/opentelemetry.md).

## `WithoutCancel`

Detached work часто становится leak. Если audit/log delivery должна пережить request, передайте её owned bounded (с явным пределом времени, количества или размера) worker-у с собственным shutdown context, queue limit и observability. `WithoutCancel` не создаёт owner и не добавляет timeout.

## Cancellation cause

`ctx.Err()` возвращает только `Canceled` или `DeadlineExceeded`. `context.Cause(ctx)` даёт сохранённую domain/operational cause. Не отправляйте эту причину внешнему клиенту без sanitization.

## Причина отмены и обычная ошибка

Фрагмент внутри `main`, нужны `context`, `errors`, `fmt`:

```go
ctx, cancel := context.WithCancelCause(context.Background())
cancel(errors.New("owner stopped"))
fmt.Println(ctx.Err())          // context canceled
fmt.Println(context.Cause(ctx)) // owner stopped
```

Отмена родителя идёт детям, а отмена ребёнка не отменяет родителя. Несколько независимых операций можно связать одним родительским context, но ошибку одной операции нужно явно превратить в отмену остальных, например через `errgroup.WithContext`.

`WithoutCancel` сохраняет values, но убирает deadline, Done и ошибку отмены родителя. Для фоновой задачи добавьте отдельный timeout и владельца. Вызов возвращённого stop из `AfterFunc` не ждёт уже начавшуюся функцию: совместное изменение состояния всё ещё требует синхронизации.

## Источники

- [`context` package](https://pkg.go.dev/context)
- [Go blog: Context](https://go.dev/blog/context)
- [Go blog: Pipelines and cancellation](https://go.dev/blog/pipelines)

## Проверь себя

1. Остановит ли cancel бесконечный цикл без проверки context?
2. Может ли child timeout продлить parent deadline?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, отмена кооперативная; код должен заметить сигнал.
2. Нет: ребёнок отменится вместе с родителем, даже если его собственный срок позже.

</details>
