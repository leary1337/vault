---
title: Scheduler Go
description: Модель G-M-P, work stealing, syscalls и container-aware GOMAXPROCS.
tags:
  - go
  - runtime
  - scheduler
level:
  - senior
updated: 2026-10-06
created: 2024-07-27
---

# Scheduler Go

Scheduler выбирает, какую готовую goroutine выполнить на доступном потоке. Готовая к выполнению задача может ещё ждать очередь; это отдельная причина задержки.

> Детали этой страницы относятся к standard Go toolchain 1.27 и не являются контрактом языка.

Scheduler multiplexes runnable goroutines over OS threads. Пользователь пишет blocking-style code, а runtime координирует выполнение, network polling, syscalls, timers, preemption и garbage collection.

## G, M и P

- **G** — goroutine state: stack (стек вызовов goroutine), instruction position и scheduler metadata.
- **M** — OS thread, выполняющий Go или runtime code.
- **P** — ресурс выполнения Go code и локальное scheduler/allocator state.

M обычно нужен P, чтобы выполнять Go goroutine. Число P связано с `GOMAXPROCS`; это available parallelism, а не предел goroutines или OS threads.

## Очереди и work stealing

Runnable G попадают в per-P local queues или global queue. P ищет локальную работу, может забирать global work и steal часть работы у другого P. Точные размеры очередей, частота global checks и порядок выбора — изменяемые implementation details, а не fairness guarantees.

CPU-bound (ограниченный скоростью вычисления) goroutines конкурируют за P. I/O-bound (ограниченный ожиданием ввода-вывода) goroutines часто park, позволяя тому же P выполнять другую работу.

```mermaid
stateDiagram-v2
    [*] --> Runnable: go f()
    Runnable --> Running: scheduler выделяет M и P
    Running --> Waiting: channel, lock или network wait
    Waiting --> Runnable: событие готовности
    Running --> Runnable: preemption
    Running --> Syscall: вход в syscall
    Syscall --> Running: быстрый возврат с P
    Syscall --> Runnable: после возврата нужен P
    Running --> Done: функция завершилась
    Done --> [*]
```

Это упрощённая схема состояний standard runtime, без внутренних transitions GC/stack scanning. Возврат из ожидания делает goroutine runnable, но не гарантирует немедленное выполнение.

## Syscalls и netpoller

При blocking syscall runtime может отделить P от заблокированного M, чтобы другой M продолжил Go work. Не каждый syscall одинаков: cgo, thread-affine code и foreign libraries могут удерживать threads и требовать отдельной диагностики.

Network file descriptors в non-blocking mode интегрируются с OS poller. Goroutine park до readiness (готовность принимать новую работу), не занимая P активным ожиданием. Подробнее: [Netpoller](netpoller.md).

## Preemption и sysmon

Runtime умеет preempt long-running goroutines, чтобы GC и другие goroutines продвигались. `sysmon` помогает с timers, preemption, network polling и retaking resources после долгих syscalls. Не привязывайте reasoning к конкретному period или числу scheduler ticks.

## `GOMAXPROCS` в контейнерах

С Go 1.25 default может учитывать logical CPUs, CPU affinity и на Linux cgroup CPU bandwidth limit; runtime периодически обновляет значение при изменении environment. Для language version 1.24 и ниже по умолчанию действуют `GODEBUG=containermaxprocs=0,updatemaxprocs=0`: новая версия toolchain сама по себе не включает эти defaults для старого модуля. Проверяйте `go` directive главного модуля и GODEBUG overrides. CPU requests Kubernetes не учитываются.

В проверенной реализации Go 1.27.1 дробная quota округляется вверх; runtime обычно не выбирает значение ниже 2, если число logical CPUs и CPU affinity позволяют 2. Поэтому `GOMAXPROCS` не обязательно равен CPU limit.

Положительный `GOMAXPROCS` environment variable или вызов `runtime.GOMAXPROCS(n)` с `n > 0` задаёт ручное значение и отключает автоматические updates. Вызов с `n <= 0` только читает настройку. `runtime.SetDefaultGOMAXPROCS()` восстанавливает default behavior с учётом GODEBUG.

Это уменьшает риск, когда process на большой node считает доступными все CPUs, но container имеет малую quota и регулярно попадает под CPU throttling. Однако выставлять или не выставлять CPU limit — отдельный infrastructure trade-off; следите за throttled time, run queue, latency и utilization. Связанные уровни: [cgroups v2](../../linux/cgroups.md) и [Kubernetes resources](../../containers/kubernetes/resources.md).

## Диагностика

- CPU profile: где выполняется CPU work.
- Execution trace: runnable/blocked states, scheduler latency, syscalls, GC.
- Goroutine profile: stacks и blocking points.
- OS metrics: CPU throttling, threads, context switches.

Высокое число goroutines не доказывает scheduler problem. Сначала разделите runnable, I/O-waiting, lock-blocked и leaked goroutines.

## Связь G, M и P

```mermaid
flowchart LR
    Q["готовые G в очереди"] --> P["P: ресурс исполнения"]
    P --> M["M: поток ОС"]
    M --> G["G: сейчас выполняется"]
    G -->|"ждать сеть"| W["park: P свободен для другой G"]
```

Это иллюстрация связи, а не полный scheduler algorithm. Для диагностики стандартного runtime:

```bash
GODEBUG=schedtrace=1000,scheddetail=1 ./service
```

Пример shell Linux/macOS; в PowerShell задайте `$env:GODEBUG` отдельно. Вывод раз в секунду показывает состояние scheduler; формат не стабилен как API и logging может быть дорогим. Большие очереди runnable при высокой CPU загрузке говорят об очереди исполнения, а тысячи waiting goroutines чаще требуют проверки locks/I/O.

`GOMAXPROCS=4` не гарантирует четыре CPU-секунды за секунду внутри контейнера с quota 1 CPU. Ограничение ОС всё равно приводит к throttling. Не тюньте только число P без анализа cgroup и workload.

## Источники

- [Go blog: Container-aware GOMAXPROCS](https://go.dev/blog/container-aware-gomaxprocs)
- [Go 1.25 Release Notes: runtime](https://go.dev/doc/go1.25#runtime)
- [`runtime.GOMAXPROCS`, Go 1.27.1](https://pkg.go.dev/runtime@go1.27.1#GOMAXPROCS)
- [Go 1.27.1 scheduler source](https://github.com/golang/go/blob/go1.27.1/src/runtime/proc.go)
- [Go diagnostics](https://go.dev/doc/diagnostics)

## Проверь себя

1. Почему GOMAXPROCS не предел OS threads?
2. Что отличает runnable от running?

<details>
<summary>Ориентиры для ответа</summary>

1. Threads могут быть заблокированы в syscall/cgo; P ограничивает одновременное выполнение Go-кода.
2. Runnable готова, но ждёт выделения ресурса; running уже выполняется.

</details>
