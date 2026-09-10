---
title: System calls
description: User/kernel boundary, blocking и strace.
tags: [linux, syscalls]
updated: 2026-09-10
---

# System calls

System call — контролируемый вход user process в kernel для I/O, memory mapping, process, time и networking. libc часто предоставляет wrapper; не каждая library call становится syscall и один high-level call может вызвать несколько.

Syscall переводит CPU в kernel mode, проверяет arguments/permissions и выполняет работу. Если data/resource не готовы, task может sleep и scheduler запустит другую. Nonblocking FD вместо ожидания возвращает `EAGAIN/EWOULDBLOCK`; readiness API сообщает, когда повторить.

Ошибки возвращаются через `errno` convention. Short read/write не ошибка: call может обработать меньше buffer, код обязан повторить остаток. `EINTR` означает interruption signal и retry зависит от operation/частичного прогресса/library.

## strace

```bash
strace -f -tt -T -p "$PID"
strace -f -c -p "$PID"
strace -e trace=network,file -p "$PID"
```

`-f` следует descendants/threads, `-T` показывает duration syscall, `-c` агрегирует. Attach влияет на timing/throughput и может раскрыть payload/path/secrets; ограничивайте scope и duration.

Высокое время в `futex` может означать lock wait или нормальное sleep, `epoll_wait` — idle event loop, `read` — disk/socket/pipe в зависимости от FD. Связывайте trace с `/proc/$PID/fd`, stack/profile и workload.

## Источники

- [syscalls(2)](https://man7.org/linux/man-pages/man2/syscalls.2.html)
- [strace manual](https://man7.org/linux/man-pages/man1/strace.1.html)
