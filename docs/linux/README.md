---
title: Linux для backend engineer
description: Processes, memory, networking, cgroups и диагностика Linux.
tags: [linux, production]
updated: 2026-09-10
---

# Linux для backend engineer

Раздел объясняет minimum, необходимый для чтения production signals: process/thread/syscall, file descriptors и sockets, virtual memory/page cache/RSS, CPU/load average, epoll, signals, cgroup v2 и namespaces.

Рекомендуемый порядок: process → syscall/FD/signal → memory → sockets/epoll → CPU/load → cgroups/namespaces → [diagnostic workflow](debugging.md).

Linux metrics имеют scope. Host `free` и container `memory.current`, process RSS и Go heap, CPU utilization и load average отвечают на разные вопросы. Всегда фиксируйте host/container/PID/cgroup, интервал и workload.

Основные первичные источники — [Linux man-pages](https://man7.org/linux/man-pages/) и [kernel documentation](https://docs.kernel.org/).
