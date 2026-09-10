---
title: Signals
description: SIGTERM, SIGKILL, handlers и graceful shutdown.
tags: [linux, signals]
updated: 2026-09-10
---

# Signals

Signal — asynchronous notification process/thread. Disposition: default action, ignore или user handler; mask определяет временно blocked signals. Standard signals не queue-ят произвольное число одинаковых instances, real-time signals queue-ятся.

`SIGTERM` просит завершиться и может быть пойман/обработан. `SIGINT` обычно идёт от terminal. `SIGHUP` часто переиспользуют для reload. `SIGKILL` и `SIGSTOP` нельзя catch/block/ignore: при `SIGKILL` cleanup/defer/flush не выполняются.

## Graceful termination

1. Получить `SIGTERM` через safe runtime mechanism (`signal.NotifyContext` в Go).
2. Снять readiness/перестать принимать новую работу.
3. Закрыть listeners, drain active requests/consumers в bounded deadline.
4. Flush только критичного state, закрыть resources.
5. Exit; supervisor применит `SIGKILL`, если grace period истёк.

Handler POSIX C ограничен async-signal-safe functions; language runtime обычно доставляет signal в безопасный context. Не делайте сложную логику прямо в raw handler.

## Команды

```bash
kill -TERM "$PID"
kill -KILL "$PID"   # только когда graceful path исчерпан
cat /proc/$PID/status | grep -E 'Sig(Pnd|Blk|Ign|Cgt)'
```

Signal направленный process может быть доставлен одному подходящему thread; thread-directed signal — конкретной task. PID 1 имеет особые default handling/reaping responsibilities в контейнере.

## Источники

- [signal(7)](https://man7.org/linux/man-pages/man7/signal.7.html)
- [kill(2)](https://man7.org/linux/man-pages/man2/kill.2.html)
