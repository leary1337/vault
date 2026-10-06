---
title: Linux для backend engineer
description: Processes, memory, networking, cgroups и диагностика Linux.
tags: [linux, production]
updated: 2026-10-06
---

# Linux для backend engineer

Раздел объясняет устройство Linux для диагностики серверных программ: process/thread/syscall, file descriptors и sockets, virtual memory/page cache/RSS, CPU/load average, epoll, signals, cgroup v2 и namespaces.

Показатели Linux имеют область измерения. Host `free` и container `memory.current`, process RSS и Go heap, CPU utilization и load average отвечают на разные вопросы. Всегда фиксируйте host/container/PID/cgroup, интервал и workload.

Основные первичные источники — [Linux man-pages](https://man7.org/linux/man-pages/) и [kernel documentation](https://docs.kernel.org/).

## Темы

- [cgroups v2](cgroups.md)
- [CPU](cpu.md)
- [epoll](epoll.md)
- [File descriptors](file-descriptors.md)
- [Linux debugging workflow](debugging.md)
- [Load average](load-average.md)
- [Memory и page cache](memory.md)
- [Namespaces](namespaces.md)
- [Processes и threads](processes-and-threads.md)
- [Signals](signals.md)
- [Sockets](sockets.md)
- [System calls](system-calls.md)
- [Virtual memory](virtual-memory.md)
