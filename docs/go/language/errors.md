---
title: Ошибки в Go
description: Error chains, классификация ошибок и ответственность слоёв.
tags:
  - go
  - errors
level:
  - middle
  - senior
updated: 2026-10-06
created: 2024-07-24
---

# Ошибки в Go

Ошибка в Go — обычное значение. Возвращайте её тому, кто может решить, что делать: показать ответ, повторить безопасную операцию или остановить процесс.

`error` — interface с методом `Error() string`. Ошибка — значение, которое вызывающий код может классифицировать, обернуть или преобразовать на boundary (граница ответственности между слоями).

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
	Field  string
	Reason string
}

func (e *ValidationError) Error() string {
	return e.Field + ": " + e.Reason
}
```

Фрагмент обработки внутри функции, где `err` уже получена:

```go
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

Retry — policy вызывающего, а не свойство любого `error`. Учитывайте operation idempotency (свойство повторной операции давать тот же эффект), deadline, attempt budget, backoff/jitter и server signal (`Retry-After`). Ошибка timeout может быть временной, но повтор non-idempotent request способен удвоить эффект.

## Logging ownership (ответственность за изменение данных и завершение работы)

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

## Цепочка ошибок сохраняет смысл

Фрагмент внутри `main`, нужны `errors` и `fmt`:

```go
missing := errors.New("missing")
wrapped := fmt.Errorf("load user: %w", missing)
fmt.Println(wrapped == missing)           // false
fmt.Println(errors.Is(wrapped, missing))  // true
fmt.Println(errors.Join(nil, nil) == nil) // true
```

Сравнение `==` видит конкретное значение обёртки; `errors.Is` ищет категорию в дереве причин. Оборачивание делает внутреннюю ошибку доступной вызывающему и может закрепить её как часть API. Если слой не должен раскрывать конкретный драйвер, переведите его ошибку в свою устойчивую категорию.

## Источники

- [`errors` package](https://pkg.go.dev/errors)
- [`fmt.Errorf`](https://pkg.go.dev/fmt#Errorf)
- [Go blog: Working with Errors in Go 1.13](https://go.dev/blog/go1.13-errors)

## Проверь себя

1. Зачем Is вместо сравнения текста?
2. Гарантирует ли timeout отсутствие записи в БД?

<details>
<summary>Ориентиры для ответа</summary>

1. Текст изменяется и не описывает структуру причин; Is проходит по обёрткам.
2. Нет: запись могла завершиться, а ответ потеряться. Нужна идемпотентность или проверка результата.

</details>
