---
title: Производительность Go
description: Измерение и профилирование Go-приложений.
tags:
  - go
  - performance
updated: 2026-10-06
---

# Производительность Go

Производительность измеряют под конкретной нагрузкой. CPU profile показывает выполняемую работу, trace — интервалы выполнения и ожидания, heap profile — память. Benchmark сравнивает стоимость операции; перенос результата на весь сервис требует отдельной проверки.

## Темы

- [Benchmarks](benchmarks.md)
- [Escape analysis](escape-analysis.md)
- [pprof](pprof.md)
- [Profile-guided optimization](pgo.md)
- [Race detector](race-detector.md)
- [Runtime trace](runtime-trace.md)
