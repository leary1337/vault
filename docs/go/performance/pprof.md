---
title: pprof
description: Сбор и интерпретация CPU, heap, block, mutex и goroutine profiles.
tags:
  - go
  - performance
  - pprof
updated: 2026-10-06
created: 2024-07-28
---

# pprof

Profile показывает, где расходуется выбранный ресурс. CPU profile ищет выполняемую работу, heap (куча, область хранения объектов с управляемым временем жизни) — память, block/mutex — ожидание синхронизации.

Profile отвечает на конкретный вопрос о resource consumption. Сначала формулируйте симптом и временное окно, затем выбирайте profile.

| Profile | Что показывает |
|---|---|
| CPU | sampled stacks во время потребления CPU |
| heap | sampled allocations (выделения памяти), всё ещё in-use на момент snapshot (снимок состояния) |
| allocs | исторические allocations с момента старта |
| goroutine | stacks текущих goroutines |
| goroutineleak | Go 1.27: доказуемо permanently blocked goroutines на поддержанных primitives |
| mutex | contention (конкуренция за один ресурс, например lock), attributed к месту освобождения lock |
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

- `inuse_space` ищет current retention (удержание достижимых данных в памяти).
- `alloc_space` ищет allocation (выделение памяти) churn/GC pressure.
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

## Как читать top без неверного вывода

Иллюстративный вывод CPU profile:

```text
flat  flat%   cum  cum%  function
0.1s    5%  1.5s   75%  handleRequest
1.2s   60%  1.2s   60%  encodePayload
```

`handleRequest` мало работает сам, но вызывает дорогой encoder; переписывать handler ради его 75% обычно бессмысленно. Для heap один и тот же участок может иметь высокий alloc_space и низкий inuse_space: он создаёт временные объекты, а не удерживает их.

`import _ "net/http/pprof"` регистрирует handlers в DefaultServeMux; собственный admin mux требует явной регистрации. Не путайте регистрацию с запуском listener: HTTP-сервер всё равно нужно создать. Сбор block/mutex профиля включите через runtime API с осознанной частотой и выключите/снизьте после эксперимента.

## Источники

- [Go diagnostics](https://go.dev/doc/diagnostics)
- [`runtime/pprof`](https://pkg.go.dev/runtime/pprof)
- [`net/http/pprof`](https://pkg.go.dev/net/http/pprof)
- [Go 1.27 goroutine leak profiles](https://go.dev/blog/goroutine-leak-profiles)

## Проверь себя

1. Чем flat отличается от cumulative?
2. Что означает высокий alloc_space при стабильном inuse_space?

<details>
<summary>Ориентиры для ответа</summary>

1. Flat — стоимость внутри функции; cumulative добавляет вызванные ею функции.
2. Вероятен allocation churn; это не обязательно утечка памяти.

</details>
