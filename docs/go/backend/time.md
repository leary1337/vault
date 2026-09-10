---
title: Time и timers
description: Deadlines, monotonic time, ticker lifecycle и clock abstraction.
tags:
  - go
  - time
updated: 2026-09-10
---

# Time и timers

`time.Time` может содержать wall clock и monotonic reading. Duration arithmetic/comparison между values, полученными из `time.Now`, использует monotonic component, защищая elapsed measurement от wall-clock adjustments. Serialization теряет monotonic component.

Используйте UTC для storage/wire и явную location для presentation. Не вычисляйте календарный «день» как `24*time.Hour` в зонах с DST.

`time.After` удобен для редких cases, но явный `Timer` позволяет stop/reset и ownership. `Ticker` нужно останавливать, когда component завершён. Для request timeouts предпочтителен context.

В тестах time-dependent logic принимайте clock/timer boundary или используйте `testing/synctest`; sleeps делают tests медленными и flaky.

## Источники

- [`time` package](https://pkg.go.dev/time)
- [`testing/synctest`](https://pkg.go.dev/testing/synctest)
