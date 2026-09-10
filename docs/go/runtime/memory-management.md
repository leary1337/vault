---
title: Управление памятью Go
description: Escape analysis, stacks, heap, allocator, scavenger и RSS.
tags:
  - go
  - runtime
  - memory
level:
  - senior
updated: 2026-09-10
created: 2024-07-27
---

# Управление памятью Go

> Детали allocator относятся к standard Go runtime 1.27. Язык гарантирует корректный lifetime значений, но не конкретное размещение в stack/heap.

## Stack и heap

Goroutine stacks grow и могут перемещаться. Compiler размещает значение на stack, если докажет, что оно не переживёт frame и placement корректно; иначе значение escapes в heap.

Возврат pointer на local variable безопасен:

```go
func newCounter() *int {
    n := 0
    return &n // compiler обеспечит lifetime; вероятный escape
}
```

`new`, composite literal или pointer receiver сами по себе не определяют placement. Проверяйте решение compiler:

```bash
go build -gcflags="all=-m=2" ./...
go test -bench=. -benchmem ./...
```

Escape diagnostic — объяснение решения конкретного compiler/version, не performance verdict. Heap allocation может быть дешёвой, а попытка убрать её — ухудшить code.

## Allocator

Current runtime группирует small objects по size classes и использует per-P/local caching, central spans и heap pages, чтобы уменьшать global contention. Large objects обрабатываются иначе. Названия внутренних structs и точные thresholds меняются; прикладной вывод — allocation size, pointer density, lifetime и rate определяют GC/allocator cost.

## Scavenger, RSS и virtual memory

После sweep свободная память может остаться в runtime для reuse или быть возвращена OS scavenger-ом. Поэтому падение live heap не обязано немедленно уменьшить RSS.

- Heap profile показывает sampled Go heap, а не весь RSS.
- RSS включает resident stack/pages, runtime metadata и часть mappings.
- cgo, `mmap`, kernel socket buffers и page cache могут не входить в Go heap metrics.
- VSS часто велик из-за reserved address space и плохо отражает физическую память Go process.

Сопоставляйте `runtime/metrics`, heap profiles, RSS/cgroup working set и внешние allocations.

## Memory retention и fragmentation

Частые причины высокого RSS:

- live cache действительно вырос;
- маленький subslice удерживает большой array;
- goroutine leak удерживает object graph;
- pool сохраняет слишком крупные buffers;
- allocator spans частично заняты и не могут быть возвращены;
- non-Go memory/cgo/mmap.

`debug.FreeOSMemory` форсирует collection и aggressive return как диагностический/редкий operational инструмент, но не лечит retention и обычно не должен вызываться на request path.

## `sync.Pool`

Pool хранит временные interchangeable objects и может быть очищен runtime в любой момент. Он уменьшает allocations только при подходящем workload; большие редкие buffers способны увеличить retained memory. Ограничивайте размер objects, возвращаемых в pool.

## Источники

- [Go GC guide](https://go.dev/doc/gc-guide)
- [`runtime/metrics`](https://pkg.go.dev/runtime/metrics)
- [`runtime/debug`](https://pkg.go.dev/runtime/debug)
- [Go compiler diagnostics](https://pkg.go.dev/cmd/compile)
