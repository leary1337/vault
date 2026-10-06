---
title: Escape analysis
description: Как читать compiler diagnostics и уменьшать allocations на измеренных hot paths.
tags:
  - go
  - performance
  - compiler
updated: 2026-10-06
---

# Escape analysis

Escape analysis решает, может ли память остаться в локальном stack (стек вызовов goroutine) frame. Возвращаемый адрес не должен стать недействительным после выхода функции.

Compiler решает, может ли storage жить в stack frame. Если значение переживает frame, его адрес/содержимое уходит в неизвестный lifetime или размер нельзя удобно разместить, оно может escape (выход срока жизни объекта за пределы локального stack frame) в heap (куча, область хранения объектов с управляемым временем жизни).

```bash
go build -gcflags="all=-m=2" ./...
```

Сообщения `escapes to heap` и `leaking param` объясняют compiler decision. Они меняются между версиями и после inlining; это не API и не автоматическая задача «исправить всё».

Частые причины: возврат pointer, interface/closure capture, storing в heap object, слишком большой/dynamic object. Но compiler может оставить pointer-referenced value на stack, если lifetime доказан.

Workflow: profile allocations (выделения памяти) → найдите hot allocator → подтвердите benchmark `-benchmem` → измените representation/lifetime → сравните. Не увеличивайте copying или complexity ради единичной cold allocation (выделение памяти).

## Один синтаксис — разные решения

```go
func pointer() *int { n := 42; return &n }
func value() int    { n := 42; return n }
```

Вызов pointer может требовать хранения вне frame, но после inlining компилятор иногда доказывает короткий lifetime на месте вызова. Для понятного первого эксперимента `go build -gcflags='-m=2 -l'` отключает inlining только у выбранного пакета. Затем проверьте обычную оптимизированную сборку: её решение ближе к эксплуатации.

`leaking param` может означать, что указатель или вложенная ссылка передаётся дальше, а не что каждая такая функция безусловно выделяет новую память. Читайте сообщение вместе с кодом и измеряйте `-benchmem`. Не превращайте compiler diagnostic в самостоятельную цель исправления.

## Источники

- [`cmd/compile`](https://pkg.go.dev/cmd/compile)
- [Escape analysis invariants, Go 1.27.1](https://github.com/golang/go/blob/go1.27.1/src/cmd/compile/internal/escape/escape.go)

## Проверь себя

1. Почему pointer receiver не равен heap allocation?
2. Зачем сравнить вывод с inlining и без?

<details>
<summary>Ориентиры для ответа</summary>

1. Размещение зависит от доказанного lifetime, а не только от типа получателя.
2. Чтобы увидеть исходное решение и влияние оптимизации в реальном caller.

</details>
