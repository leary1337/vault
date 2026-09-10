---
title: Race detector
description: Динамический поиск data races и ограничения режима -race.
tags:
  - go
  - performance
  - testing
updated: 2026-09-10
---

# Race detector

```bash
go test -race ./...
go test -race -count=20 ./path/to/pkg
go run -race ./cmd/service
```

Detector инструментирует memory accesses и synchronization. Он имеет существенный CPU/memory overhead и находит только races в выполненных paths. Запускайте representative tests; для production-like проверки используйте безопасную ограниченную среду.

Report показывает конфликтующие accesses и goroutine creation stacks. Исправляйте ownership/happens-before, а не подавляйте timing через sleep. Детальная семантика: [Data races](../concurrency/data-races.md).

## Источники

- [Data Race Detector](https://go.dev/doc/articles/race_detector)
- [The Go Memory Model](https://go.dev/ref/mem)
