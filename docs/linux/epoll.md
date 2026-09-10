---
title: epoll
description: Linux readiness notification, LT/ET и nonblocking I/O.
tags: [linux, networking, epoll]
updated: 2026-09-10
---

# epoll

`epoll` следит за interest set file descriptors и возвращает ready events без линейного сканирования всего набора при каждом wait. Это readiness, не завершение I/O: после event операция всё ещё может дать `EAGAIN` из-за race/другого consumer.

## API

- `epoll_create1(EPOLL_CLOEXEC)` создаёт instance FD;
- `epoll_ctl` добавляет/изменяет/удаляет interest;
- `epoll_wait`/`epoll_pwait` ждёт ready list.

Level-triggered (default) повторяет event, пока condition остаётся. Edge-triggered (`EPOLLET`) сообщает изменение readiness; FD должен быть nonblocking, а handler обязан accept/read/write до `EAGAIN`, иначе данные могут остаться без нового edge.

`EPOLLONESHOT` отключает FD после event до rearm и помогает передавать connection worker-у без concurrent handling. `EPOLLRDHUP`, errors и hangup всё равно нужно корректно обработать и закрыть FD.

## Common loop

```text
wait events
for listener readable: accept until EAGAIN
for connection readable: read until EAGAIN/EOF/error
buffer writes; enable EPOLLOUT only while pending
```

Постоянный `EPOLLOUT` на writable socket создаёт busy loop. Slow client требует bounded output buffer/backpressure; readiness не ограничивает memory.

Go runtime netpoller использует OS readiness mechanisms, поэтому goroutine-per-connection не означает thread-per-connection. Implementation details могут меняться; application всё равно задаёт deadlines и limits.

## Источники

- [epoll(7)](https://man7.org/linux/man-pages/man7/epoll.7.html)
