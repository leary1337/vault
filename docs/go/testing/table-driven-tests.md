---
title: "Табличные тесты"
description: "Таблица перечисляет классы входных данных, которые проходят одну схему подготовки, действия и проверки."
tags:
  - go
  - testing
updated: 2026-10-06
---

# Табличные тесты

Таблица перечисляет классы входных данных, которые проходят одну схему подготовки, действия и проверки. Она помогает увидеть границы: пустое, ошибочное и обычное значение. Имена случаев должны объяснять проверяемое поведение.

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

## Реализация ParseID

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

Нужны `strconv`, `errors`. Добавьте случаи `0`, `abc` и число вне int64. Для `42` ожидается 42. Отдельно решите, допустимы ли `+42` и ведущие нули: библиотечный ParseInt может разрешать больше, чем контракт API.

## Параллельность и ясность

Не превращайте таблицу в язык настройки с десятками необязательных полей. `t.Parallel` подходит только изолированным данным и ресурсам. Общие настройки, БД или схема всё ещё создают зависимость между случаями.

Захват переменной цикла зависит от объявленной версии языка. Даже отдельные переменные новых итераций не делают независимым общий объект под указателем. Выбирайте строки по классам и границам контракта, а не случайным перебором.

## Источники

- [`testing.T.Run`](https://pkg.go.dev/testing#T.Run)
- [Go Wiki: TableDrivenTests](https://go.dev/wiki/TableDrivenTests)

## Проверь себя

1. Как выбрать случаи таблицы?
2. Что проверить перед `t.Parallel`?

<details>
<summary>Ответы</summary>

1. Классы эквивалентности и граничные значения.
2. Изоляцию изменяемого состояния и достаточность ресурсов.

</details>
