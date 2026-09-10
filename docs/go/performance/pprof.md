---
title: pprof
description: Сбор и интерпретация CPU, heap, block, mutex и goroutine profiles.
tags:
  - go
  - performance
  - pprof
updated: 2026-09-10
created: 2024-07-28
---

# pprof

Profile отвечает на конкретный вопрос о resource consumption. Сначала формулируйте симптом и временное окно, затем выбирайте profile.

| Profile | Что показывает |
|---|---|
| CPU | sampled stacks во время потребления CPU |
| heap | sampled allocations, всё ещё in-use на момент snapshot |
| allocs | исторические allocations с момента старта |
| goroutine | stacks текущих goroutines |
| goroutineleak | Go 1.27: доказуемо permanently blocked goroutines на поддержанных primitives |
| mutex | contention, attributed к месту освобождения lock |
| block | время blocking на synchronization primitives |
| threadcreate | stacks, приведшие к созданию OS threads |

Mutex/block profiling имеет overhead и требует sampling configuration. Параллельный сбор diagnostics может искажать результаты.

## HTTP endpoint

```go
import _ "net/http/pprof"
```

Не выставляйте `/debug/pprof/` в публичную сеть. Используйте отдельный authenticated admin listener, loopback, service mesh policy или controlled port-forward.

```bash
go tool pprof http://127.0.0.1:6060/debug/pprof/profile?seconds=30
go tool pprof http://127.0.0.1:6060/debug/pprof/heap
go tool pprof -diff_base before.pb.gz after.pb.gz
```

В interactive pprof полезны `top`, `top -cum`, `list`, `web`. Flat cost находится в самой function; cumulative включает callees.

## Heap: in-use и allocated

- `inuse_space` ищет current retention.
- `alloc_space` ищет allocation churn/GC pressure.
- `inuse_objects`/`alloc_objects` полезны для множества маленьких objects.

Сохраняйте binary/source той же build версии, иначе symbolization и line mapping будут неверны.

## Goroutine leak profile

Go 1.27 `goroutineleak` автоматически находит subset leaks: permanently blocked operations на channels и поддержанных `sync` primitives. Он намеренно не покрывает каждую логическую leak, например object, всё ещё достижимый из global state, или зависший foreign I/O. Обычный goroutine profile и временные trends остаются нужны.

## Production workflow

1. Зафиксировать symptom, traffic и deploy version.
2. Снять baseline metrics и профиль репрезентативного окна.
3. Проверить top/cumulative stacks и сопоставить с latency/resource metrics.
4. Изменить одну гипотезу.
5. Сравнить profile/benchmark до и после.

## Источники

- [Go diagnostics](https://go.dev/doc/diagnostics)
- [`runtime/pprof`](https://pkg.go.dev/runtime/pprof)
- [`net/http/pprof`](https://pkg.go.dev/net/http/pprof)
- [Go 1.27 goroutine leak profiles](https://go.dev/blog/goroutine-leak-profiles)
