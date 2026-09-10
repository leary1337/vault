---
title: Generic types, aliases и methods
description: Параметризованные типы, generic aliases и generic methods Go 1.27.
tags:
  - go
  - generics
updated: 2026-09-10
---

# Generic types, aliases и methods

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

Ограничение сохраняется: method в interface не может объявлять type parameters, а generic method не реализует обычный interface method «для всех instantiations». API, который должен работать с interface dispatch, проектируйте вокруг конкретных method signatures.

## Trade-offs

- Generics уменьшают duplication и сохраняют тип результата.
- Сложные constraints ухудшают diagnostics и читаемость public API.
- Не рассчитывайте на конкретную monomorphization/dictionary implementation: это не language contract.
- Если generic abstraction используется один раз и не выражает устойчивую операцию, concrete code проще.

## Источники

- [Go specification: Type declarations](https://go.dev/ref/spec#Type_declarations)
- [Go specification: Method declarations](https://go.dev/ref/spec#Method_declarations)
- [Go 1.27 Release Notes: generic methods](https://go.dev/doc/go1.27#language)
- [Go blog: Generic Methods](https://go.dev/blog/generic-methods)
