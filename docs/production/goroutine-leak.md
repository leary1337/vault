---
title: Goroutine leak
description: Диагностика растущего числа goroutines, blocked stacks и lifecycle ownership.
tags: [production, goroutine-leak, go]
updated: 2026-09-10
---

# Goroutine leak

## Symptoms

Число goroutines растёт с uptime/requests, вместе растут stacks/memory, descriptors или latency; shutdown не завершается. Goroutines часто blocked, а не потребляют CPU.

## Possible causes

Send/receive без counterpart, потерянная cancellation, worker ждёт незакрытую queue, `time.Ticker`/subscription не остановлен, HTTP body/stream не закрыт, retry loop без exit или `WaitGroup` ждёт работу, которая не завершится.

## What to measure

Goroutine count/rate, stack states и повторяющиеся creation/blocked sites, active requests/streams, queue depth, open FDs, cancellation/deadline outcomes и shutdown duration.

## Diagnostics

Сравните goroutine profiles при одинаковой нагрузке через интервал. Сгруппируйте stacks, найдите растущую signature и её owner. Проследите start → stop contract и все return paths. Подтвердите fix soak-тестом до plateau и graceful shutdown.

## Tools

Go goroutine profile с `debug=1/2`, block profile, execution trace, runtime metrics, goleak-style test tooling и race detector для сопутствующих races.

## Immediate mitigation

Остановить создание leaking work, cancel affected operations, отключить feature, shed load или rolling restart после capture profiles. Увеличение memory только отложит отказ.

## Root cause

Укажите недостающую termination condition или нарушенное ownership: кто создал goroutine, кто обязан cancel/close/join и почему сигнал не дошёл. «Blocked on channel» — симптом, не причина.

## Prevention

Structured concurrency, context deadlines, owner closes channel, bounded worker pools, shutdown tests, baseline goroutine assertions и review каждого `go` statement. См. [concurrency lifecycle](../go/concurrency/goroutines.md).

