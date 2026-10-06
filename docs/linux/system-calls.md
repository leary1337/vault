---
title: System calls
description: User/kernel boundary, blocking и strace.
tags: [linux, syscalls]
updated: 2026-10-06
---

# System calls

Системный вызов просит ядро выполнить привилегированную операцию. Вызов обычной библиотечной функции может обходиться без syscall или содержать несколько.

System call — контролируемый вход user process в kernel для I/O, memory mapping, process, time и networking. libc часто предоставляет wrapper; не каждая library call становится syscall и один high-level call может вызвать несколько.

Syscall переводит CPU в kernel mode, проверяет arguments/permissions и выполняет работу. Если data/resource не готовы, task может sleep и scheduler запустит другую. Nonblocking FD вместо ожидания возвращает `EAGAIN/EWOULDBLOCK`; readiness (готовность к операции или к приёму новой работы в указанном контексте) API сообщает, когда повторить.

Ошибки возвращаются через `errno` convention. Short read/write не ошибка: call может обработать меньше buffer, код обязан повторить остаток. `EINTR` означает interruption signal и retry зависит от operation/частичного прогресса/library.

## strace

```bash
strace -f -tt -T -p "$PID"
strace -f -c -p "$PID"
strace -e trace=network,file -p "$PID"
```

`-f` следует descendants/threads, `-T` показывает duration syscall, `-c` агрегирует. Attach влияет на timing/throughput и может раскрыть payload/path/secrets; ограничивайте scope (область измерения: host, cgroup или process) и duration.

Высокое время в `futex` может означать lock wait или нормальное sleep, `epoll_wait` — idle event loop, `read` — disk/socket/pipe в зависимости от FD. Связывайте trace с `/proc/$PID/fd`, stack/profile и workload.

## Интерпретировать strace, а не только проценты

```text
read(7, ..., 4096) = 512
read(7, ..., 4096) = -1 EAGAIN
epoll_wait(4, ..., 128, -1) = 1
```

Это пример нормального nonblocking (операция возвращает отсутствие готовности вместо ожидания) чтения: данные закончились, процесс ждёт готовность. `512` не ошибка, хотя buffer был на 4096. Если протокол требует фиксированную длину, приложение должно собрать остаток.

Долгий `epoll_wait` при отсутствии запросов — полезный idle, а не bottleneck. Долгий `futex` может быть lock или нормальный механизм сна runtime. Сопоставьте FD/stack и time window с нагрузкой. `strace -c` агрегирует syscalls, но не объясняет бизнес-причину их количества.

## Источники

- [syscalls(2)](https://man7.org/linux/man-pages/man2/syscalls.2.html)
- [strace manual](https://man7.org/linux/man-pages/man1/strace.1.html)

## Проверь себя

1. Является ли short read ошибкой?
2. Почему долгое epoll_wait не означает медленный сервер?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет; caller должен обработать фактически прочитанные байты и собрать остаток.
2. Event loop может корректно ждать отсутствие работы.

</details>
