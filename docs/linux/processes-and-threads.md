---
title: Processes и threads
description: Address space, task, scheduler и context switch.
tags: [linux, processes]
updated: 2026-09-10
---

# Processes и threads

Process — resource container с virtual address space, file descriptor table, credentials, namespaces и signal state. Linux scheduler фактически планирует tasks; threads одного process имеют разные task IDs/stacks/registers, но разделяют address space и большинство resources.

`fork()` создаёт child с copy-on-write view памяти и копиями descriptor references; `execve()` заменяет program image, сохраняя не закрытые `FD_CLOEXEC` descriptors. `clone()`/`clone3()` позволяют явно разделять ресурсы и лежат в основе threads/containers.

## Context switch

Scheduler сохраняет register/CPU state одной runnable task и восстанавливает другую. Switch может ухудшить cache/TLB locality; его стоимость зависит от workload/CPU, поэтому фиксированного числа нет. System call mode switch user↔kernel не обязательно переключает task — это разные события.

Threads помогают параллелизму и hiding I/O latency, но создают synchronization, stack и scheduling cost. Больше threads, чем полезной parallelism, может увеличить run queue и tail latency.

## Диагностика

```bash
ps -eLf
top -H -p "$PID"
cat /proc/$PID/status
cat /proc/$PID/task/$TID/status
```

Смотрите state (`R/S/D/Z`), voluntary/nonvoluntary context switches, thread count, CPU affinity и wait channel. `D` обычно uninterruptible sleep (часто I/O), zombie уже завершился и ждёт `wait()` parent.

## Источники

- [proc_pid_status(5)](https://man7.org/linux/man-pages/man5/proc_pid_status.5.html)
- [clone(2)](https://man7.org/linux/man-pages/man2/clone.2.html)
