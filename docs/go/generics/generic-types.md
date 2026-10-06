---
title: Generic types, aliases и methods
description: Параметризованные типы, generic aliases и generic methods Go 1.27.
tags:
  - go
  - generics
updated: 2026-10-06
---

# Generic types, aliases и methods

Параметризованный тип сохраняет один алгоритм для разных конкретных типов. Alias — другое имя того же типа, а defined type создаёт отдельный тип.

## Generic type

```go
type Set[T comparable] map[T]struct{}

func (s Set[T]) Add(value T) {
	s[value] = struct{}{}
}
```

Receiver generic type объявляет соответствующие type parameter names. Здесь `Add` использует параметр `T` самого `Set`; это поддерживается с Go 1.18.

## Generic aliases

С Go 1.24 alias может иметь type parameters:

```go
type StringSet = Set[string]
type Lookup[K comparable, V any] = map[K]V
```

Alias не создаёт новый defined type: alias и его target идентичны. Generic alias нужно instantiate при использовании. Используйте alias для совместимости и постепенного refactoring, а не чтобы скрыть важную доменную семантику.

## Generic methods

Go 1.27 разрешает методу объявлять собственные type parameters:

```go
type Stream[T any] []T

func (s Stream[T]) Map[R any](fn func(T) R) Stream[R] {
	out := make(Stream[R], len(s))
	for i, value := range s {
		out[i] = fn(value)
	}
	return out
}
```

Это generic method, потому что `R` принадлежит методу, а не receiver type. До Go 1.27 такую операцию приходилось оформлять generic function.

Ограничение сохраняется: method в interface не может объявлять type parameters, а generic method не реализует обычный interface method «для всех instantiations». API, который должен работать с interface dispatch (выбор и вызов реализации метода), проектируйте вокруг конкретных method signatures.

## Trade-offs

- Generics уменьшают duplication и сохраняют тип результата.
- Сложные constraints ухудшают diagnostics и читаемость public API.
- Не рассчитывайте на конкретную monomorphization/dictionary implementation: это не language contract.
- Если generic abstraction используется один раз и не выражает устойчивую операцию, concrete code проще.

## Создание и результат

После деклараций выше внутри `main`:

```go
s := make(Set[string])
s.Add("go")
s.Add("go")
fmt.Println(len(s)) // 1

out := Stream[int]{1, 2}.Map(func(n int) string { return strconv.Itoa(n) })
fmt.Println(out) // [1 2], тип Stream[string]
```

Нужны `fmt`, `strconv`, language version Go 1.27 для Map. Нулевой `Set[T]` — nil map: `Add` на нём паникует. Решите, должен ли нулевой контейнер быть рабочим; для lazy initialization потребуется другой API, который может заменить map у владельца.

Для проекта с `go 1.26` метод с собственным параметром `R` не является переносимым. Старый совместимый вариант — отдельная `Map[T,R](s Stream[T], fn func(T)R)`; границу версии отмечайте прямо в публичных примерах.

## Источники

- [Go specification: Type declarations](https://go.dev/ref/spec#Type_declarations)
- [Go specification: Method declarations](https://go.dev/ref/spec#Method_declarations)
- [Go 1.27 Release Notes: generic methods](https://go.dev/doc/go1.27#language)
- [Go blog: Generic Methods](https://go.dev/blog/generic-methods)

## Проверь себя

1. Почему zero Set нельзя сразу Add?
2. Чем метод Add[T receiver] отличается от Map[R method]?

<details>
<summary>Ориентиры для ответа</summary>

1. Underlying map равна nil; её сначала инициализируют.
2. Первый использует параметр типа, второй объявляет свой параметр метода; второй доступен с Go 1.27.

</details>
