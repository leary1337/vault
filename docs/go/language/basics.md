---
title: Основы Go
description: Базовая семантика типов, значений, присваивания и констант в Go 1.27.
tags:
  - go
  - language
level:
  - middle
updated: 2026-09-10
created: 2024-07-25
---

# Основы Go

Go — компилируемый статически типизированный язык общего назначения. Его стандартная библиотека и tooling хорошо подходят для сетевых сервисов, но язык не гарантирует, что программа автоматически будет быстрее аналога на другом языке: результат зависит от алгоритма, I/O, allocation rate, конкуренции за ресурсы и качества реализации.

Страница ориентирована на Go 1.27. Для байтов и Unicode см. [Strings, bytes и runes](strings-bytes-runes.md).

## Типы и zero value

У каждой переменной есть статический тип. Объявленная без initializer переменная получает zero value:

| Категория | Zero value |
|---|---|
| числа | `0` |
| `bool` | `false` |
| `string` | `""` |
| pointers, functions, slices, maps, channels, interfaces | `nil` |
| array и struct | рекурсивный zero value элементов и полей |

Zero value многих библиотечных типов сразу полезен: `sync.Mutex`, `bytes.Buffer`. Но `nil` map нельзя изменять, а `nil` channel блокирует send и receive навсегда.

## `var`, short declaration и assignment

```go
var retries int          // 0
timeout := 2 * time.Second
value, ok := cache[key]  // multi-value assignment
left, right = right, left
```

`:=` объявляет хотя бы одну новую non-blank переменную в текущем scope; остальные имена слева могут быть переиспользованы. Assignment копирует значение. Для slice, map, channel, function, pointer и interface копия может ссылаться на общее underlying state — это не pass-by-reference.

## `new` и `make`

- `new(T)` выделяет zero value типа `T` и возвращает `*T`.
- `make` инициализирует только slice, map или channel и возвращает значение самого типа, не pointer.

```go
p := new(int)             // *int, *p == 0
s := make([]int, 0, 16)   // готовый slice
m := make(map[string]int) // готовая map
ch := make(chan int, 8)   // buffered channel
```

`&T{}` обычно выразительнее `new(T)`, когда нужен pointer на struct. Место фактического хранения — stack или heap — решает compiler escape analysis, а не синтаксис `new`.

## Conversion не assertion

Go не выполняет неявные numeric conversions:

```go
var n int64 = 42
small := int32(n) // explicit conversion; возможна потеря старших битов
```

Conversion `T(x)` создаёт значение типа `T`, если conversion разрешена спецификацией. Type assertion `x.(T)` применяется только к interface value и проверяет dynamic type. Interface assignment — третья отдельная операция; подробнее в [Интерфейсах](interfaces.md).

## Comparability

Операторы `==` и `!=` доступны не всем типам:

- comparable: booleans, numbers, strings, pointers, channels, interfaces, а также arrays/structs, если comparable все их элементы или поля;
- не comparable: slices, maps, functions (их можно сравнить только с `nil`).

Interface values сравнимы синтаксически, но comparison паникует, если оба dynamic values имеют одинаковый non-comparable dynamic type.

```go
var a any = []int{1}
var b any = []int{1}
// _ = a == b // panic: comparing uncomparable type []int
```

`comparable` — predeclared constraint для type parameters, а `any` — alias для `interface{}`. Они решают разные задачи.

## Constants и `iota`

Constants вычисляются на compile time и могут оставаться untyped до контекста использования. Это позволяет представлять значения с точностью, большей, чем у runtime-типа, но присваивание должно быть представимо целевым типом.

```go
const untyped = 1 << 40
const typed int64 = 1 << 40

type State uint8

const (
    StateUnknown State = iota
    StateReady
    StateClosed
)
```

Внутри `const` group `iota` — порядковый номер `ConstSpec`, начиная с нуля. Не используйте его, если числовые значения входят во внешний протокол: там стабильные значения лучше задавать явно.

## Что гарантирует язык

- Параметры и результаты функций передаются по значению.
- Порядок evaluation определён не для всех подвыражений; не стройте код на неоговорённом порядке.
- Размеры `int`, `uint` и `uintptr` implementation-specific: 32 или 64 бита.
- `string` — immutable sequence of bytes, но не гарантия валидного UTF-8.
- Layout внутренних descriptors для string/slice/map/interface не является API.

## Типичные ошибки

- Путать копирование descriptor со deep copy данных.
- Писать в nil map или ждать операции на nil channel.
- Игнорировать overflow/truncation при numeric conversion.
- Сравнивать interface values, не учитывая dynamic comparability.
- Полагаться на benchmark другого проекта или обещать фиксированный выигрыш «от переписывания на Go».

## Вопросы для самопроверки

1. Почему передача slice в функцию остаётся передачей по значению?
2. Чем `new([]byte)` отличается от `make([]byte, 0)`?
3. Когда comparison двух interface values вызывает panic?
4. Чем untyped constant отличается от переменной?

## Источники

- [The Go Programming Language Specification](https://go.dev/ref/spec)
- [Effective Go: allocation with `new` and `make`](https://go.dev/doc/effective_go#allocation_new)
- [Go 1.27 Release Notes](https://go.dev/doc/go1.27)
