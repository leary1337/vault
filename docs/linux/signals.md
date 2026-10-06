---
title: Signals
description: SIGTERM, SIGKILL, handlers и graceful shutdown.
tags: [linux, signals]
updated: 2026-10-06
---

# Signals

Signal уведомляет процесс о событии. TERM предлагает завершиться корректно, KILL прекращает выполнение без возможности выполнить уборку.

Signal — asynchronous notification process/thread. Disposition: default action, ignore или user handler; mask определяет временно blocked signals. Standard signals не queue-ят произвольное число одинаковых instances, real-time signals queue-ятся.

`SIGTERM` просит завершиться и может быть пойман/обработан. `SIGINT` обычно идёт от terminal. `SIGHUP` часто переиспользуют для reload. `SIGKILL` и `SIGSTOP` нельзя catch/block/ignore: при `SIGKILL` cleanup/defer/flush не выполняются.

## Graceful termination

1. Получить `SIGTERM` через safe runtime mechanism (`signal.NotifyContext` в Go).
2. Снять readiness/перестать принимать новую работу.
3. Закрыть listeners, drain (завершение уже принятой работы) active requests/consumers в bounded deadline.
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

## Go получает сигнал через безопасный API

```go
ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
defer stop()
<-ctx.Done()
// Здесь запускается bounded shutdown с новым context.
stop() // вернуть обычную обработку последующих сигналов
```

Фрагмент функции, нужны `context`, `os`, `os/signal`, `syscall`; SIGTERM пример ориентирован на Linux. `stop` освобождает подписку и восстанавливает обработку, когда других подписчиков нет. Для нового drain нельзя использовать уже отменённый `ctx`.

Стандартные одинаковые signals могут объединяться, поэтому сигнал не является надёжным счётчиком задач. POSIX handler не может произвольно вызывать небезопасные функции; runtime API изолирует доставку от обычной логики приложения.

## Источники

- [signal(7)](https://man7.org/linux/man-pages/man7/signal.7.html)
- [kill(2)](https://man7.org/linux/man-pages/man2/kill.2.html)

## Проверь себя

1. Выполнится ли defer после SIGKILL?
2. Почему сигнал не подходит как очередь событий с точным count?

<details>
<summary>Ориентиры для ответа</summary>

1. Нет, процесс прекращён без программной уборки.
2. Одинаковые стандартные signals могут сливаться в одно pending событие.

</details>
