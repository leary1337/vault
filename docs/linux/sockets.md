---
title: Sockets
description: listen, accept, connection states, buffers и limits.
tags: [linux, networking]
updated: 2026-09-10
---

# Sockets

Socket — kernel communication endpoint, представленный file descriptor. Server path: `socket` → `setsockopt` → `bind` → `listen` → `accept`; `accept` возвращает новый connected FD, listener остаётся принимать следующие.

`listen(backlog)` ограничивается kernel settings и относится к очереди установленных connections; incomplete TCP handshakes имеют отдельные механизмы/limits. Backlog saturation проявляется drops/retransmits/timeouts, а не обязательно application error.

Nonblocking `accept4(..., SOCK_NONBLOCK|SOCK_CLOEXEC)` и read/write возвращают `EAGAIN`, когда сейчас нечего выполнить. Partial reads/writes нормальны; TCP — byte stream без message boundaries.

## States и exhaustion

`TIME_WAIT` защищает новый connection tuple от старых segments; обычно его создаёт active closer. Массовые outbound short connections могут исчерпать ephemeral ports `(src IP, src port, dst IP, dst port)` — reuse pools/keep-alive важнее агрессивных sysctl hacks.

```bash
ss -lntp
ss -s
ss -tan state time-wait
lsof -nP -p "$PID" -a -i
cat /proc/$PID/net/sockstat
```

Смотрите accept rate, states, retransmits, listen drops, socket memory, FD/port limits. Socket buffer size не равен application throughput автоматически; большой buffer расходует kernel/cgroup memory.

`SO_REUSEPORT` может распределять incoming flows между listeners, но load/ordering behavior зависит от protocol/kernel/program. Не включайте без измерения.

## Источники

- [socket(7)](https://man7.org/linux/man-pages/man7/socket.7.html)
- [listen(2)](https://man7.org/linux/man-pages/man2/listen.2.html)
- [accept(2)](https://man7.org/linux/man-pages/man2/accept.2.html)
