---
title: JSON в Go
description: Безопасное JSON-кодирование, decoding limits и versioning API.
tags:
  - go
  - json
updated: 2026-10-06
---

# JSON в Go

JSON — текстовый формат обмена. В Go публичный контракт задают поля и теги структуры; корректный JSON ещё не означает корректные бизнес-данные.

Определяйте transport DTO (структура данных внешнего запроса или ответа) отдельно от domain model, если API versioning/security требует независимости. Exported fields и struct tags формируют wire (передаваемый по сети) contract.

```go
type CreateRequest struct {
	Name string `json:"name"`
}

body := http.MaxBytesReader(w, r.Body, 1<<20)
dec := json.NewDecoder(body)
dec.DisallowUnknownFields()
```

После первого value убедитесь, что нет второго trailing JSON value. `DisallowUnknownFields` — policy: он полезен для strict commands, но может мешать forward compatibility у tolerant readers.

Числа, `time.Time`, `omitempty`, nil/empty slices и custom marshalers имеют wire consequences — закрепляйте contract tests. Не декодируйте untrusted payload в `map[string]any`, если schema известна; JSON numbers там по умолчанию становятся `float64`, если не вызвать `UseNumber`.

Go 1.27 добавил production `encoding/json/v2` с более строгими/configurable semantics, а legacy `encoding/json` сохраняет compatibility. Migration требует contract diff и не должна быть механической заменой import.

## Декодировать ровно один объект

Определение helper для legacy `encoding/json`; нужны `encoding/json`, `errors`, `fmt`, `io`:

```go
func decodeOne(r io.Reader, dst any) error {
	dec := json.NewDecoder(r)
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		return err
	}
	var extra any
	if err := dec.Decode(&extra); err != io.EOF {
		if err == nil {
			return errors.New("expected one JSON value")
		}
		return fmt.Errorf("trailing JSON: %w", err)
	}
	return nil
}
```

Передайте reader с ограничением размера, например `http.MaxBytesReader`. `{"name":"Ada"} {"admin":true}` отвергается: второй объект не должен быть молча проигнорирован. Пробелы после первого объекта допустимы. Отдельно проверьте обязательность и допустимую длину `name`.

Отсутствие поля и явный ноль различают через pointer или отдельную presence-модель. Legacy v1 допускает ряд неоднозначных входов, включая дубли ключей; `DisallowUnknownFields` их не запрещает. Для v2 проверьте изменения nil slices, чувствительности к регистру, дубликатов имён и недопустимого UTF-8 отдельными контрактными тестами.

## Источники

- [`encoding/json`](https://pkg.go.dev/encoding/json)
- [`encoding/json/v2`](https://pkg.go.dev/encoding/json/v2)
- [Go 1.27 Release Notes](https://go.dev/doc/go1.27)

## Проверь себя

1. Почему одного Decode недостаточно?
2. Что выбрать для поля, где 0 и отсутствие различаются?

<details>
<summary>Ориентиры для ответа</summary>

1. Он может успешно прочитать первый объект и оставить второй в том же body.
2. Явную модель присутствия, например *int; обычный int имеет общий zero value.

</details>
