---
title: "JSON в Go"
description: "JSON — текстовый формат передачи данных."
tags:
  - go
  - json
updated: 2026-10-06
---

# JSON в Go

JSON — текстовый формат передачи данных. Экспортируемые поля и метки структуры задают внешний контракт. Синтаксически допустимый JSON ещё нужно проверить по правилам приложения: обязательность, длина и значения полей.

```go
type CreateRequest struct {
	Name string `json:"name"`
}

body := http.MaxBytesReader(w, r.Body, 1<<20)
dec := json.NewDecoder(body)
dec.DisallowUnknownFields()
```

Для внешних данных при необходимости определяйте отдельную структуру, чтобы изменения внутренней модели не раскрывали поля API. `DisallowUnknownFields` запрещает неизвестные поля, но может мешать клиентам будущих версий; это осознанная политика.

## Ровно один объект

Функция для `encoding/json`; нужны `encoding/json`, `errors`, `fmt`, `io`:

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

Reader должен иметь ограничение размера, например `http.MaxBytesReader`. После первого объекта `Decode` может оставить второй: `{"name":"Ada"} {"admin":true}` необходимо отклонить. Пробелы после объекта допустимы.

## Особенности контракта

Пустой и отсутствующий срез, `omitempty`, время и собственные кодировщики влияют на передаваемый формат. Отсутствие числа и явный ноль различают указателем или моделью присутствия. В `map[string]any` числа по умолчанию становятся `float64`; `UseNumber` меняет это. При известной схеме структура обычно лучше.

Legacy v1 допускает неоднозначности, включая повторные ключи: `DisallowUnknownFields` их не запрещает. Go 1.27 добавил рабочий `encoding/json/v2` с более строгими настраиваемыми правилами, сохранив старую библиотеку для совместимости. Переход не сводится к замене импорта: отдельно проверяйте дубли имён, регистр, неверный UTF-8 и представление nil-срезов.

## Источники

- [`encoding/json`](https://pkg.go.dev/encoding/json)
- [`encoding/json/v2`](https://pkg.go.dev/encoding/json/v2)
- [Go 1.27 Release Notes](https://go.dev/doc/go1.27)

## Проверь себя

1. Почему одного `Decode` недостаточно для тела запроса?
2. Как различить отсутствие поля и число 0?

<details>
<summary>Ответы</summary>

1. Он может прочитать лишь первый объект.
2. Через указатель или отдельную модель присутствия.

</details>
