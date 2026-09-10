---
title: Benchmarks в тестах
description: B.Loop, allocations и статистическое сравнение Go benchmarks.
tags:
  - go
  - testing
  - performance
updated: 2026-09-10
---

# Benchmarks в тестах

Benchmark живёт в `_test.go`, принимает `*testing.B` и в Go 1.24+ предпочтительно использует `b.Loop`. Измеряйте одну гипотезу, запускайте `-benchmem -count=N` и сравнивайте через `benchstat`.

Setup до первого `b.Loop` не измеряется. Не смешивайте `b.N` и `b.Loop`; не подменяйте end-to-end load test microbenchmark. Полный workflow: [Benchmarks](../performance/benchmarks.md).

## Источники

- [`testing.B`](https://pkg.go.dev/testing#B)
- [`benchstat`](https://pkg.go.dev/golang.org/x/perf/cmd/benchstat)
