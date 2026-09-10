---
title: Constraints и type sets
description: any, comparable, unions и underlying type terms в Go generics.
tags:
  - go
  - generics
updated: 2026-09-10
---

# Constraints и type sets

Constraint — interface, чей type set ограничивает допустимые type arguments.

```go
type Integer interface {
    ~int | ~int8 | ~int16 | ~int32 | ~int64 |
        ~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 | ~uintptr
}

func Sum[T Integer](values []T) T {
    var total T
    for _, value := range values {
        total += value
    }
    return total
}
```

`~int64` означает все типы с underlying type `int64`, включая `type UserID int64`. Union `A | B` объединяет type sets. Terms в non-interface unions не должны пересекаться.

## `any` и `comparable`

`any` — alias для `interface{}` и не разрешает никаких type-specific операций кроме общих для всех типов. `comparable` разрешает `==`/`!=` и нужен, например, для map key.

Interface type может удовлетворять `comparable`, но comparison interface values всё ещё может panic, если их dynamic values имеют non-comparable type. Generic код с interface type argument должен учитывать эту границу.

## Basic и non-basic interfaces

Basic interface полностью задаётся методами и может быть обычным runtime type. Interface с type terms/unions обычно non-basic и используется только как constraint (или элемент другого constraint), а не как тип variable.

```go
type Stringish interface {
    ~string
}

// var x Stringish // invalid: interface contains type constraints
```

## Дизайн constraints

- Начинайте с минимального набора операций.
- Не перечисляйте concrete types, если достаточно method constraint.
- `~T` используйте, когда named types с тем же underlying type семантически допустимы.
- Экспортируемый constraint — часть API; расширение или сужение type set может повлиять на callers.

## Источники

- [Go specification: General interfaces](https://go.dev/ref/spec#General_interfaces)
- [Go specification: Satisfying a type constraint](https://go.dev/ref/spec#Satisfying_a_type_constraint)
- [Go blog: An Introduction to Generics](https://go.dev/blog/intro-generics)
