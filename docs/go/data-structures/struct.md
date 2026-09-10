---
title: Struct в Go
description: Struct values, comparability, embedding, tags и layout.
tags: [go, data-structures]
created: 2024-07-30
updated: 2026-09-10
---

# Struct в Go

Struct — sequence именованных fields. Его zero value состоит из zero values полей; это позволяет проектировать types, полезные без constructor-а. Struct value копируется целиком при assignment/argument/return, хотя поля pointers, slices и maps продолжают ссылаться на общие данные.

## Declaration и literals

```go
type User struct {
    ID   int64
    Name string
}

u := User{ID: 42, Name: "Ada"}
```

В package boundary предпочитайте keyed literals: добавление/reorder field не меняет смысл. Unkeyed literals external struct запрещает `go vet` для многих случаев и связывает caller с layout полей.

## Comparability

Struct comparable, только если comparable все его fields. Тогда `==` сравнивает поля по порядку и type можно использовать как map key. Наличие slice, map или function делает struct non-comparable. Для semantic equality (например, игнорировать cache/time metadata) реализуйте named method/function, а не полагайтесь на raw `==`.

## Methods и pointer receivers

Value receiver получает копию struct; pointer receiver может менять original и избегает копирования крупного value. Выбор влияет на method set/interface implementation. Не копируйте после первого использования types с `sync.Mutex` и другой no-copy state; `go vet copylocks` помогает находить такие случаи.

## Embedding

Anonymous field promotes fields/methods для selector convenience, но это не inheritance. Embedded type остаётся отдельным field; promoted method может быть shadowed, а interface satisfaction зависит от method sets value/pointer. Embedding публичного foreign type раскрывает его methods как часть API — используйте осознанно.

## Tags

Tag — string metadata доступная через reflection. Convention конкретной library определяет смысл (`json`, validation, DB mapper). Tag участвует в type identity (с оговорками assignability) и должен быть syntactically корректным; `go vet` проверяет распространённые ошибки.

```go
type Request struct {
    Name string `json:"name"`
}
```

Unexported fields обычно недоступны encoder-у другого package. Не используйте tags как единственную security authorization policy: mass assignment/field exposure контролируются explicit DTO и mapping.

## Layout и alignment

Compiler вставляет padding, чтобы удовлетворить alignment полей; точный layout зависит от types и target architecture. `unsafe.Sizeof`, `Alignof` и `Offsetof` дают compile-time values для конкретного build. Field reordering иногда экономит память при миллионах objects, но может ухудшить readability/cache access; измеряйте.

Нельзя сериализовать raw struct memory как portable wire/storage format: padding, endianness, pointers и layout не являются стабильным межпроцессным contract. Используйте explicit encoding.

## Источники

- [Go specification: struct types](https://go.dev/ref/spec#Struct_types)
- [Go specification: comparison operators](https://go.dev/ref/spec#Comparison_operators)
- [`unsafe` package](https://pkg.go.dev/unsafe)
