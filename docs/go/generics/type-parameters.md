---
title: Type parameters
description: Generic functions, type arguments и type inference в Go 1.27.
tags:
  - go
  - generics
updated: 2026-09-10
---

# Type parameters

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

idx := Index(IDs{10, 20}, 20) // inferred: S=IDs, E=int64
```

`~[]E` сохраняет named slice type `S`; параметр `[]E` вернул бы обычный slice type. Compiler часто выводит type arguments из function arguments и assignment context. Если inference неоднозначна, укажите часть или все arguments: `Index[IDs](...)`.

## Ограничения

- Operations над `T` доступны только если они разрешены для каждого типа constraint.
- Type switch/assertion применяется к interface value, а не напрямую к type parameter; иногда значение временно переводят в `any`.
- Нельзя предполагать concrete representation только из type set.
- Generic abstraction не гарантирует отсутствие allocations или конкретную стратегию code generation.

## Когда generics полезны

- Контейнер или алгоритм должен сохранять concrete element type.
- Одна операция корректна для небольшого явно заданного семейства типов.
- Без generics пришлось бы дублировать type-safe code или возвращать `any`.

Interface обычно лучше, если алгоритму нужна capability из нескольких методов и concrete type результата не важен.

## Источники

- [Go specification: Type parameter declarations](https://go.dev/ref/spec#Type_parameter_declarations)
- [Go specification: Type inference](https://go.dev/ref/spec#Type_inference)
- [Tutorial: Getting started with generics](https://go.dev/doc/tutorial/generics)
