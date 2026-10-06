---
title: Type parameters
description: Generic functions, type arguments и type inference в Go 1.27.
tags:
  - go
  - generics
updated: 2026-10-06
---

# Type parameters

Параметр типа выбирается при вызове общего алгоритма. В отличие от any, компилятор сохраняет информацию о конкретном типе и проверяет операции заранее.

Type parameter — placeholder для конкретного типа, выбранного при instantiation. Constraint задаёт допустимый type set и доступные операции.

```go
func Index[S ~[]E, E comparable](items S, target E) int {
	for i, item := range items {
		if item == target {
			return i
		}
	}
	return -1
}

type IDs []int64
```

```go
idx := Index(IDs{10, 20}, 20) // inferred: S=IDs, E=int64
```

`S ~[]E` позволяет вывести `S=IDs` и тип элемента `E=int64`. В этом примере `Index` возвращает `int`: результат поиска не является slice. Сохранение named slice type важно для функций, которые возвращают `S`, например `func Clone[S ~[]E, E any](s S) S`. Параметр `[]E` тоже принимает `IDs`, но возврат `[]E` не сохраняет имя `IDs`.

Compiler выводит type arguments из аргументов вызова; для присваивания самой generic function переменной подходящего function type inference также может использовать контекст. Это не означает вывод параметров вызова только из ожидаемого типа результата. Если inference неоднозначна, укажите часть или все arguments: `Index[IDs](...)`.

## Ограничения

- Operations над `T` доступны только если они разрешены для каждого типа constraint.
- Type switch/assertion применяется к interface value, а не напрямую к type parameter; иногда значение временно переводят в `any`.
- Нельзя предполагать concrete representation только из type set.
- Generic abstraction не гарантирует отсутствие allocations (выделения памяти) или конкретную стратегию code generation.

## Когда generics полезны

- Контейнер или алгоритм должен сохранять concrete element type.
- Одна операция корректна для небольшого явно заданного семейства типов.
- Без generics пришлось бы дублировать type-safe code или возвращать `any`.

Interface обычно лучше, если алгоритму нужна capability из нескольких методов и concrete type результата не важен.

## Нулевое значение обобщённого результата

```go
func First[T any](xs []T) (T, bool) {
	if len(xs) == 0 {
		var zero T
		return zero, false
	}
	return xs[0], true
}
```

`First([]int{})` вернёт `0,false`, `First([]string{"go"})` — `"go",true`. Не используйте один zero value как признак отсутствия: ноль может быть полезным сохранённым значением.

`First(nil)` не даёт вывести T, потому что untyped nil не определяет тип элементов. Нужно `First[int](nil)` или переменная `var xs []int`. Такой пример объясняет ошибку inference без запоминания внутреннего алгоритма компилятора.

## Источники

- [Go specification: Type parameter declarations](https://go.dev/ref/spec#Type_parameter_declarations)
- [Go specification: Type inference](https://go.dev/ref/spec#Type_inference)
- [Tutorial: Getting started with generics](https://go.dev/doc/tutorial/generics)

## Проверь себя

1. Когда type inference не хватает входных данных?
2. Зачем bool вместе с zero T?

<details>
<summary>Ориентиры для ответа</summary>

1. Например, First(nil): у nil нет типа элемента; нужен явный T.
2. Он различает отсутствие результата и настоящее нулевое значение.

</details>
