---
title: Table-driven tests
description: Компактная проверка классов входов и edge cases через subtests.
tags:
  - go
  - testing
updated: 2026-10-06
---

# Table-driven tests

Таблица тестов перечисляет классы входных данных. Один и тот же код проверки помогает увидеть недостающую границу: пустое, неверное, минимальное и обычное значение.

Table-driven form полезна, когда cases имеют одинаковый arrange/act/assert flow.

```go
func TestParseID(t *testing.T) {
	tests := []struct {
		name    string
		input   string
		want    int64
		wantErr bool
	}{
		{name: "valid", input: "42", want: 42},
		{name: "empty", input: "", wantErr: true},
		{name: "negative", input: "-1", wantErr: true},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got, err := ParseID(tc.input)
			if (err != nil) != tc.wantErr {
				t.Fatalf("error = %v, wantErr %v", err, tc.wantErr)
			}
			if !tc.wantErr && got != tc.want {
				t.Fatalf("got %d, want %d", got, tc.want)
			}
		})
	}
}
```

Имена subtests должны объяснять класс поведения. Не превращайте table в DSL с десятками optional fields. `t.Parallel` применяйте только если fixtures/state изолированы; loop capture semantics зависят от module language version, поэтому код должен быть понятен и без ловушек совместимости.

## Завершим пример ParseID

```go
func ParseID(s string) (int64, error) {
	n, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return 0, err
	}
	if n <= 0 {
		return 0, errors.New("id must be positive")
	}
	return n, nil
}
```

Нужны `strconv`, `errors`. К таблице выше добавьте `"0"`, `"abc"` и число за пределами int64 как ошибочные классы. Для `"42"` результат 42. Заранее решите, допустимы ли `+42` и ведущие нули: ParseInt принимает некоторые формы, но договор API может быть строже.

Параллельные subtests не должны менять один global config или общую database/schema. Даже разные tc при новой семантике цикла не устраняют shared-state зависимости.

## Источники

- [`testing.T.Run`](https://pkg.go.dev/testing#T.Run)
- [Go Wiki: TableDrivenTests](https://go.dev/wiki/TableDrivenTests)

## Проверь себя

1. Как выбрать строки таблицы без случайного перебора?
2. Что нужно проверить перед t.Parallel?

<details>
<summary>Ориентиры для ответа</summary>

1. Покрыть классы эквивалентности и границы контракта.
2. Отсутствие общего изменяемого состояния и достаточность ресурсов fixtures (подготовленные тестовые данные и зависимости).

</details>
