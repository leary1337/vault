---
title: Goroutine leak
description: Диагностика растущего числа goroutines, blocked stacks и lifecycle ownership.
tags: [production, goroutine-leak, go]
updated: 2026-10-06
---

# Goroutine leak

Утечка горутин — работа остаётся жить после конца операции, когда полезного пути завершения уже нет.

## Симптомы

Число goroutines растёт с uptime/requests, вместе растут stacks/memory, descriptors или latency (срок ответа); shutdown не завершается. Goroutines часто blocked, а не потребляют CPU.

## Возможные причины

Send/receive без counterpart, потерянная cancellation, worker ждёт незакрытую queue, `time.Ticker`/subscription не остановлен, HTTP body/stream не закрыт, retry loop без exit или `WaitGroup` ждёт работу, которая не завершится.

## Что измерить

Goroutine count/rate, stack states и повторяющиеся creation/blocked sites, active requests/streams, queue depth, open FDs, cancellation/deadline outcomes и shutdown duration.

## Проверка гипотез

Сравните goroutine profiles при одинаковой нагрузке через интервал. Сгруппируйте stacks, найдите растущую signature и её owner. Проследите start → stop contract (договорённость о поведении и гарантиях) и все return paths. Подтвердите fix soak-тестом до plateau и graceful shutdown.

## Инструменты

Go goroutine profile с `debug=1/2`, block profile, execution trace (связь этапов одной операции), runtime metrics, goleak-style test tooling и race detector для сопутствующих races.

## Как уменьшить ущерб

Остановить создание leaking work, cancel affected operations, отключить feature, shed load или rolling restart после capture profiles. Увеличение memory только отложит отказ.

## Механизм причины

Укажите недостающую termination condition или нарушенное ownership (владение данными или ответственность за ресурс): кто создал goroutine, кто обязан cancel/close/join и почему сигнал не дошёл. «Blocked on channel» — симптом, не причина.

## Предотвращение

Structured concurrency, context deadlines, owner closes channel, bounded (с явным конечным пределом) worker pools, shutdown tests, baseline goroutine assertions и review каждого `go` statement. См. [concurrency lifecycle (кто создаёт, останавливает и освобождает ресурс)](../go/concurrency/goroutines.md).

## Разбор с числами

Иллюстративный профиль: после каждой тысячи отменённых запросов число горутин увеличивается на тысячу. Повторяется stack `mapStage → chan send`; CPU низкая. Это не «медленный scheduler»: producer ждёт consumer (потребитель работы или контракта), который уже ушёл после отмены.

```go
select {
case out <- value:
case <-ctx.Done():
    return
}
```

Фрагмент закрывает путь отправки; чтение входа тоже должно ждать через `select`, иначе пустой незакрытый input оставит stage навсегда. Владелец producer закрывает output после остановки всех senders. Тест отменяет пустой input и заблокированный output отдельно, затем ждёт join с ограничением времени.

Неостановленный Ticker не следует автоматически называть heap leak в современном Go: неиспользуемые timers/tickers могут быть собраны GC. Но горутина, бесконечно читающая `ticker.C`, остаётся; `Ticker.Stop` канал не закрывает. Для выхода нужен context/явный stop signal.

## Источник механизма

[Go time.Ticker: Stop не закрывает канал](https://pkg.go.dev/time#Ticker.Stop). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему CPU может быть низкой при leak?
2. Почему Ticker.Stop не завершает range по C?

<details>
<summary>Ориентиры для ответа</summary>

1. Горутины спят на channel/I/O, удерживая state.
2. Он прекращает ticks, но не закрывает канал.

</details>
