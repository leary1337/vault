---
title: Race detector в тестах
description: Включение -race и построение тестов, исполняющих конкурентные пути.
tags:
  - go
  - testing
  - concurrency
updated: 2026-09-10
---

# Race detector в тестах

```bash
go test -race ./...
go test -race -run TestConcurrent -count=50 ./pkg
```

`-race` обнаруживает только executed conflicting accesses. Тест должен синхронно дождаться goroutines, иначе он может завершиться до race path. Не исправляйте report sleep-ом: создайте ownership/happens-before.

Инструментация увеличивает CPU/memory и меняет timing, поэтому держите отдельный обязательный CI job и representative integration scenarios. Подробнее: [Race detector](../performance/race-detector.md) и [Data races](../concurrency/data-races.md).

## Источники

- [Data Race Detector](https://go.dev/doc/articles/race_detector)
