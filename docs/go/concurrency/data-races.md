---
title: Data races
description: Причины, диагностика и устранение data races в Go.
tags:
  - go
  - concurrency
  - testing
updated: 2026-09-10
---

# Data races

Data race — concurrent conflicting access к одной memory location без happens-before, где хотя бы один access является write и accesses не atomic.

```go
var n int
go func() { n++ }()
fmt.Println(n) // race, даже если «обычно успевает»
```

Исправление должно задавать ownership или synchronization: mutex, channel handoff, atomic operation либо immutable copy. Добавление sleep не создаёт happens-before.

## Race detector

```bash
go test -race ./...
go test -race -run TestName -count=20 ./path/to/pkg
```

Detector динамический: он находит только races на выполненных путях. Увеличивайте покрытие concurrent scenarios и запускайте representative integration/load tests с `-race`, учитывая overhead. Отсутствие отчёта не является доказательством отсутствия race.

## Частые источники

- Общая map с concurrent writer.
- Захваченный mutable state в goroutines.
- Slice copies с общим backing array.
- Переиспользование buffer после передачи другому owner.
- Поля struct, часть которых atomic, а часть читается обычно.

## Источники

- [The Go Memory Model](https://go.dev/ref/mem)
- [Data Race Detector](https://go.dev/doc/articles/race_detector)
