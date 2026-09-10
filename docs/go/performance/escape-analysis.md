---
title: Escape analysis
description: Как читать compiler diagnostics и уменьшать allocations на измеренных hot paths.
tags:
  - go
  - performance
  - compiler
updated: 2026-09-10
---

# Escape analysis

Compiler решает, может ли storage жить в stack frame. Если значение переживает frame, его адрес/содержимое уходит в неизвестный lifetime или размер нельзя удобно разместить, оно может escape в heap.

```bash
go build -gcflags="all=-m=2" ./...
```

Сообщения `escapes to heap` и `leaking param` объясняют compiler decision. Они меняются между версиями и после inlining; это не API и не автоматическая задача «исправить всё».

Частые причины: возврат pointer, interface/closure capture, storing в heap object, слишком большой/dynamic object. Но compiler может оставить pointer-referenced value на stack, если lifetime доказан.

Workflow: profile allocations → найдите hot allocator → подтвердите benchmark `-benchmem` → измените representation/lifetime → сравните. Не увеличивайте copying или complexity ради единичной cold allocation.

## Источники

- [`cmd/compile`](https://pkg.go.dev/cmd/compile)
- [Go blog: Allocating on the Stack](https://go.dev/blog/all#allocating-on-the-stack)
