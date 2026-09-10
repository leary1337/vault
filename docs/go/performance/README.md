---
title: Производительность Go
description: Измерение и профилирование Go-приложений.
tags:
  - go
  - performance
updated: 2026-09-10
---

# Производительность Go

Начните с [pprof](pprof.md), затем используйте [runtime trace](runtime-trace.md) для scheduler/blocking и [benchmarks](benchmarks.md) для воспроизводимого сравнения. [Escape analysis](escape-analysis.md), [race detector](race-detector.md) и [PGO](pgo.md) применяются после постановки конкретного вопроса.

Оптимизация должна опираться на измерения, а не на общие утверждения о скорости языка или отдельной конструкции.
