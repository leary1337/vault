---
title: Backpressure
description: Передача сигнала saturation к производителю нагрузки.
tags: [backend, patterns, reliability]
updated: 2026-10-06
---

# Backpressure


Обратное давление означает: потребитель сообщает производителю, что не успевает; производитель ждёт либо получает отказ.

## Проблема

Producer создаёт работу быстрее consumer (потребитель работы или контракта), backlog (накопившаяся необработанная работа) растёт без границ и переносит failure в memory, disk, latency (срок ответа) или retention (срок хранения) loss.

## Как работает

Ограничьте buffer и заставьте upstream ждать, уменьшать скорость или получать явный rejection. Pull/credit protocols позволяют consumer объявлять capacity; bounded (с явным конечным пределом) channel/semaphore ограничивает in-flight; queue задаёт quota и producer admission policy.

## Гарантии и границы

Backpressure ограничивает накопление в выбранной границе и делает saturation (насыщение ресурса и образование очереди) видимой upstream. Он не уменьшает исходный спрос и не гарантирует, что upstream способен замедлиться.

## Ошибки и отказы

- «временная» unbounded queue заполняет RAM/disk;
- блокирующий send держит scarce request worker и создаёт deadlock;
- upstream игнорирует signal и retries;
- общий queue допускает noisy-neighbor starvation;
- backlog переживает retention/deadline и становится бесполезной работой;
- pipeline stage ограничен не там, где реальный bottleneck.

## Компромиссы

Блокирование сохраняет работу, но распространяет latency. Rejection сохраняет capacity, но требует retry/drop semantics. Buffer поглощает bursts, но увеличивает latency и memory; размер связан с service rate и допустимым queue time.

## Когда не применять

Если producer — внешний неконтролируемый client, используйте rate limiting/load shedding. Если событие обязано быть принято, durable queue и quota нужны до acknowledgement.

## Пример

Go worker pool использует bounded channel. Handler делает non-blocking/timeout-aware enqueue; при заполнении возвращает `503` или сохраняет task в durable broker. Consumer публикует queue depth, oldest age и processing rate.

## Разобранный пример

Учебный расчёт: очередь 1 000 задач, вход 500/с, обработка 300/с. Очередь заполнится за `1000/(500-300)=5 s`. При допустимом ожидании 200 ms и обработке 300/с запас около 60 задач, а не тысячи. Little’s Law описывает средние значения устойчивой системы, а не гарантирует p99 (время, в которое укладывается 99% наблюдений). При заполнении очереди не создаём дополнительную goroutine на каждую задачу: это превращает ограниченный канал в неограниченную очередь горутин.

```go
select {
case jobs <- job:
    // Задача принята в память; это не durable подтверждение.
case <-ctx.Done():
    return ctx.Err()
default:
    return ErrBusy
}
```

Фрагмент предполагает объявленные `jobs`, `job`, `ctx`, `ErrBusy`. Если producer вправе ждать, убираем `default`, но сохраняем отмену. Отмена не отзывает уже переданную задачу: consumer проверяет её срок отдельно.

## Источник механизма

[HTTP/2 flow control](https://www.rfc-editor.org/rfc/rfc9113.html#section-5.2). Числа и topology в примерах — учебные допущения, не параметры этой системы.

## Проверь себя

1. Почему очередь не исправляет длительную перегрузку?
2. Что происходит с принятой задачей при падении процесса?

<details>
<summary>Ориентиры для ответа</summary>

1. Она только хранит разность скоростей до заполнения.
2. Очередь в памяти теряется; для обещания сохранения нужен durable журнал.

</details>
