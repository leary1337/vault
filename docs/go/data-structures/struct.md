---
title: Struct в Go
description: Struct values, comparability, embedding, tags и layout.
tags: [go, data-structures]
created: 2024-07-30
updated: 2026-10-06
---

# Struct в Go

Struct объединяет связанные поля в одно значение. При копировании скалярные поля независимы, а ссылочные поля могут оставаться связаны с прежними данными.

Struct — sequence именованных fields. Его zero value состоит из zero values полей; это позволяет проектировать types, полезные без constructor-а. Struct value копируется целиком при assignment/argument/return, хотя поля pointers, slices и maps продолжают ссылаться на общие данные.

## Declaration и literals

```go
type User struct {
	ID   int64
	Name string
}

u := User{ID: 42, Name: "Ada"}
```

В package boundary (граница ответственности между слоями) предпочитайте keyed literals: добавление/reorder field не меняет смысл. Unkeyed literals external struct запрещает `go vet` для многих случаев и связывает caller с layout полей.

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

Unexported fields обычно недоступны encoder-у другого package. Не используйте tags как единственную security authorization policy: mass assignment/field exposure контролируются explicit DTO (структура данных внешнего запроса или ответа) и mapping.

## Layout и alignment

Compiler вставляет padding, чтобы удовлетворить alignment полей; точный layout зависит от types и target architecture. `unsafe.Sizeof`, `Alignof` и `Offsetof` дают compile-time values для конкретного build. Field reordering иногда экономит память при миллионах objects, но может ухудшить readability/cache access; измеряйте.

Нельзя сериализовать raw struct memory как portable wire/storage format: padding, endianness, pointers и layout не являются стабильным межпроцессным contract. Используйте explicit encoding.

## Embedding на маленьком примере

```go
type Address struct{ City string }
type UserWithAddress struct {
	Address
	Name string
}

// внутри main:
u := UserWithAddress{Address: Address{City: "Москва"}, Name: "Анна"}
fmt.Println(u.City) // Москва: сокращённый selector u.Address.City
```

Embedding не создаёт отношение «User является Address». При объявлении собственного `City` у внешней структуры сокращённый selector начнёт указывать на другое поле, хотя `u.Address.City` останется прежним. Публичный API через embedding требует внимания к таким конфликтам.

Если структура содержит `sync.Mutex`, методы должны работать через указатель: копия mutex защищает уже другой lock, а данные могут оставаться общими.

## Источники

- [Go specification: struct types](https://go.dev/ref/spec#Struct_types)
- [Go specification: comparison operators](https://go.dev/ref/spec#Comparison_operators)
- [`unsafe` package](https://pkg.go.dev/unsafe)

## Проверь себя

1. Почему struct с slice нельзя использовать как map key?
2. Что реально означает u.City при embedding?

<details>
<summary>Ориентиры для ответа</summary>

1. Slice не сравним, поэтому вся структура не сравнима.
2. Продвижение selector для вложенного поля, а не наследование.

</details>
