---
title: Ошибки в Go
description: Error chains, классификация ошибок и ответственность слоёв.
tags:
  - go
  - errors
level:
  - middle
  - senior
updated: 2026-09-10
created: 2024-07-24
---

# Ошибки в Go

`error` — interface с методом `Error() string`. Ошибка — значение, которое вызывающий код может классифицировать, обернуть или преобразовать на boundary.

## Создание и wrapping

```go
var ErrNotFound = errors.New("not found")

func load(id string) error {
    err := query(id)
    if err != nil {
        return fmt.Errorf("load user %q: %w", id, err)
    }
    return nil
}
```

`%w` сохраняет chain для `errors.Is`/`errors.As`; `%v` оставляет только текст. Не полагайтесь на сравнение строк ошибок.

## Sentinel и typed errors

Sentinel удобен для небольшой стабильной категории (`errors.Is(err, ErrNotFound)`). Typed error переносит структурированные данные:

```go
type ValidationError struct {
    Field string
    Reason string
}

func (e *ValidationError) Error() string {
    return e.Field + ": " + e.Reason
}

var validation *ValidationError
if errors.As(err, &validation) {
    // use validation.Field
}
```

`errors.Is` и `errors.As` обходят chain через `Unwrap`; тип может определить собственные `Is`/`As` semantics. Делайте это только когда relation действительно является частью API.

## Несколько причин

`errors.Join` создаёт ошибку, которая unwrap-ится в несколько ошибок. Это полезно при независимых cleanup failures или parallel work, но порядок и policy всё равно должен определить caller.

```go
return errors.Join(closeDBErr, flushErr)
```

## Error boundaries

Хорошее разделение:

1. Infrastructure layer добавляет operation/context и сохраняет cause.
2. Domain/service layer классифицирует ожидаемые исходы: not found, conflict, invalid state, unavailable.
3. Transport boundary переводит категории в HTTP status или gRPC code и скрывает внутренние детали.

Не привязывайте domain к HTTP: `ErrOrderClosed` не должен быть `http.StatusConflict`. Mapping принадлежит transport adapter.

## Retryable и permanent

Retry — policy вызывающего, а не свойство любого `error`. Учитывайте operation idempotency, deadline, attempt budget, backoff/jitter и server signal (`Retry-After`). Ошибка timeout может быть временной, но повтор non-idempotent request способен удвоить эффект.

## Logging ownership

Обычно ошибка логируется один раз на boundary, где есть request ID, actor, operation и outcome. Нижние слои возвращают контекст через wrapping. Логирование одной chain на каждом слое создаёт дубли и искажает error rate.

Не отправляйте клиенту raw database/network error: он может раскрыть schema, адреса или секреты.

## Typed nil

```go
func validate() error {
    var err *ValidationError
    return err // non-nil interface: dynamic type присутствует
}
```

Если ошибки нет, возвращайте literal `nil`.

## Вопросы для самопроверки

1. Когда нужен sentinel, а когда typed error?
2. Чем `%w` отличается от `%v`?
3. Кто должен решать, повторять ли операцию?
4. На каком слое ошибку следует логировать?

## Источники

- [`errors` package](https://pkg.go.dev/errors)
- [`fmt.Errorf`](https://pkg.go.dev/fmt#Errorf)
- [Go blog: Working with Errors in Go 1.13](https://go.dev/blog/go1.13-errors)
