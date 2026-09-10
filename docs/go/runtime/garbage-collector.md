---
title: Garbage collector Go
description: Concurrent GC, Green Tea, GOGC, GOMEMLIMIT и production diagnostics.
tags:
  - go
  - runtime
  - gc
level:
  - senior
updated: 2026-09-10
created: 2024-07-27
---

# Garbage collector Go

> Go specification не требует конкретный garbage collector. Ниже описан standard Go runtime 1.27.

Runtime использует concurrent tracing mark-and-sweep collector. Roots включают stacks и globals; mark следует по pointers и определяет reachable objects, sweep делает unreachable storage доступным allocator. Короткие stop-the-world phases нужны для transitions/root coordination, основная mark work выполняется concurrently с application.

Write barrier сохраняет корректность tri-color marking, пока application меняет pointers. Collector non-moving: он не compact-ит живые objects, поэтому fragmentation и span occupancy важны для RSS.

## Green Tea

Green Tea стала default GC в Go 1.26 и используется в Go 1.27. Она сохраняет mark-sweep semantics, но организует scanning work вокруг heap pages, чтобы улучшить locality и CPU scalability, особенно для small pointer-rich objects. Это не новая гарантия языка и не фиксированное обещание ускорения для каждого workload.

## Pacer и mutator assists

Pacer пытается завершить marking около heap goal. Если allocation rate опережает GC work, allocating goroutines могут выполнять mark assists. Это проявляется как рост GC CPU и application latency даже при коротких STW pauses.

## `GOGC`

`GOGC` задаёт trade-off CPU vs heap headroom относительно live heap и GC roots. Большее значение обычно уменьшает частоту GC и увеличивает memory; меньшее — наоборот. Это target, не жёсткий предел.

Не тюньте `GOGC` по одному pause metric. Измеряйте live heap, allocation rate, GC CPU, assist time, tail latency и container memory.

## `GOMEMLIMIT`

`GOMEMLIMIT`/`debug.SetMemoryLimit` задаёт soft limit для памяти, управляемой runtime. Он не равен cgroup hard limit и не включает, например, binary mappings, многие cgo allocations и kernel memory. Оставляйте headroom.

Слишком низкий limit вызывает frequent GC/thrashing; runtime может превысить soft limit, чтобы application сохраняла progress. Это защита от spikes, а не замена capacity planning или исправления leak.

## Диагностика

```bash
GODEBUG=gctrace=1 ./service
go tool pprof http://localhost:6060/debug/pprof/heap
go tool pprof http://localhost:6060/debug/pprof/allocs
```

Смотрите:

- live heap и heap goal;
- allocation bytes/objects rate;
- GC CPU и pauses;
- goroutine stacks/root size;
- RSS относительно Go-managed memory;
- top allocators (`alloc_space`) и current retainers (`inuse_space`).

Heap profile — sampled. Один snapshot не доказывает leak; сравнивайте одинаковые traffic phases и profiles во времени.

## Что уменьшает pressure

- Устранение ненужных allocations на hot path после profile.
- Bounded caches/queues и устранение goroutine leaks.
- Reuse только для реально повторяющихся buffers с ограничением размера.
- Более компактные structures и меньше pointers, если измерения показывают scan cost.
- Streaming вместо удержания целого payload.

## Источники

- [A Guide to the Go Garbage Collector](https://go.dev/doc/gc-guide)
- [Go 1.26 Release Notes: Green Tea](https://go.dev/doc/go1.26#runtime)
- [The Green Tea Garbage Collector](https://go.dev/blog/greenteagc)
- [Go diagnostics](https://go.dev/doc/diagnostics)
