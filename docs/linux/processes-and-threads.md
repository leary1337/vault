---
title: Processes и threads
description: Address space, task, scheduler и context switch.
tags: [linux, processes]
updated: 2026-10-06
---

# Processes и threads

Процесс имеет адресное пространство и ресурсы, а его потоки выполняются внутри общего пространства. Goroutines Go — ещё один уровень над потоками ОС.

Process — resource container с virtual address space, file descriptor table, credentials, namespaces и signal state. Linux scheduler фактически планирует tasks; threads одного process имеют разные task IDs/stacks/registers, но разделяют address space и большинство resources.

`fork()` создаёт child с copy-on-write (общие страницы до первой записи, затем отдельная копия) view памяти и копиями descriptor references; `execve()` заменяет program image, закрывая descriptors с `FD_CLOEXEC` и обычно сохраняя остальные. `clone()`/`clone3()` позволяют явно разделять ресурсы и лежат в основе threads/containers.

## Context switch

Scheduler сохраняет register/CPU state одной runnable task и восстанавливает другую. Switch может ухудшить cache/TLB locality; его стоимость зависит от workload/CPU, поэтому фиксированного числа нет. System call mode switch user↔kernel не обязательно переключает task — это разные события.

Threads помогают параллелизму и hiding I/O latency, но создают synchronization, stack и scheduling cost. Больше threads, чем полезной parallelism, может увеличить run queue и tail latency (задержка самых медленных запросов, например p99).

## Диагностика

```bash
ps -eLf
top -H -p "$PID"
cat /proc/$PID/status
cat /proc/$PID/task/$TID/status
```

Смотрите state (`R/S/D/Z`), voluntary/nonvoluntary context switches, thread count, CPU affinity и wait channel. `D` обычно uninterruptible sleep (часто I/O), zombie уже завершился и ждёт `wait()` parent.

## Состояния говорят о разных проблемах

| State | Что это означает | Следующая проверка |
|---|---|---|
| R | выполняется или готов выполнять | CPU, run queue, throttling (принудительное ожидание после исчерпания квоты) |
| S | прерываемое ожидание | нормальный sleep, сеть, lock |
| D | непрерываемое ожидание | wchan, storage/kernel |
| Z | завершён, parent ещё не забрал status | wait/reaping, PID 1 |

Zombie уже не исполняет код и не удерживает обычный address space; он занимает запись процесса до `wait`. Отправлять ему SIGKILL бессмысленно: исправляйте родителя/reaper.

После `fork` страницы часто разделяются copy-on-write. Первая запись создаёт отдельную страницу, поэтому большой parent и активно пишущий child могут увеличить физическую память. `execve` заменяет программу; descriptors с FD_CLOEXEC закрываются, остальные обычно сохраняются.

## Источники

- [proc_pid_status(5)](https://man7.org/linux/man-pages/man5/proc_pid_status.5.html)
- [clone(2)](https://man7.org/linux/man-pages/man2/clone.2.html)

## Проверь себя

1. Чем mode switch отличается от context switch?
2. Можно ли убить zombie для освобождения?

<details>
<summary>Ориентиры для ответа</summary>

1. User↔kernel переход не обязательно меняет исполняемую task; context switch меняет.
2. Он уже завершён; parent должен выполнить wait/reaping.

</details>
